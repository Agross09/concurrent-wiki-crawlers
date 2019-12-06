import json
import networkx as nx
import matplotlib.pyplot as plt

def main():
    json_file = open('graph_smaller.json')
    data = json.load(json_file)

    for node in data.keys():
        for i in range(len(data[node])):
            data[node][i] = (data[node][i].split("/wiki/"))[1]
        data[node.split("/wiki/")[1]] = data.pop(node)
    G=nx.from_dict_of_lists(data)
    # nx.draw_networkx_labels(G, font_color='r')
    nx.draw(G, with_labels=True, edge_color='grey')
    plt.show()

if __name__ == '__main__':
    main()
