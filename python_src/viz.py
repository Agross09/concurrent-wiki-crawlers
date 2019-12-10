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
    # Generate graph from json file
    json_file = open(file_name)
    adjacency_matrix = json.load(json_file)
    G = nx.from_dict_of_lists(adjacency_matrix)

    color_map = set_node_colors(G)
    labels = label_important(G)
    # Generate and show visualization
    pos = nx.spring_layout(G)
    nx.draw(
        G, with_labels=False,
        node_color=color_map, node_size=150,
        edge_color='grey', alpha=0.3,
        pos=pos
    )
    nx.draw_networkx_labels(G,pos=pos,labels=labels)
    plt.show()

def label_important(G):
    """Only add page labels for nodes with > 20 neighbors"""
    labels = {}
    for node in G:
        if len(G[node]) > 20:
            labels[node] = node.split("wiki/")[1]
    return labels

def set_node_colors(G):
    """Set node color based on the number of neighbors it has"""
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
    return color_map

if __name__ == '__main__':
    main(sys.argv[1])
