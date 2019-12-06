#!/usr/bin/env python
#--------------------------------------------------------------
#
#  File name: viz.py
#
#  Description: Implementation of graph visualization using 
#  NetworkX package
#  
#---------------------------------------------------------------
import sys
import json
import networkx as nx
import matplotlib.pyplot as plt

def main(file_name):
    json_file = open(file_name)
    adjacency_matrix = json.load(json_file)
    G = nx.from_dict_of_lists(adjacency_matrix)
    
    color_map = []
    for node in G:
        if len(G[node]) < 2:
            color_map.append('#7fad79')
        elif len(G[node]) < 4:
            color_map.append('#09b06a')
        elif len(G[node]) < 10:
            color_map.append('#036487')
        elif len(G[node]) < 20:
            color_map.append('#0000ff')
        else:
            color_map.append('#ff0000')

    nx.draw(
        G, with_labels=False, 
        node_color=color_map, node_size=150,
        edge_color='grey', alpha=0.3
    )
    plt.show()

if __name__ == '__main__':
    main(sys.argv[1])
