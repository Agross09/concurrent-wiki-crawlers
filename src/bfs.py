#!/usr/bin/env python
#--------------------------------------------------------------
#
#  File name: bfs.py
#
#  Description: Breath-first search implementation on the graphs
#  of crawled website
#  
#--------------------------------------------------------------
import json
import sys

# Constants
BASE_URL          = "https://en.wikipedia.org/wiki/"

# Exit status
EXIT_FAILURE      = 1
EXIT_SUCCESS      = 0

def validate_args(args):
    if len(args) != 3:
        sys.stderr.write("Usage: ./bfs <graph.json> <start> <end>\n")
        exit(EXIT_FAILURE)
    return (args[0], args[1], args[2])

def back_trace(parent, start, end):
    path = [end]
    while path[-1] != start:
        path.append(parent[path[-1]])
        print(path)
    path.reverse()
    return path


def bfs(graph, start, end):
    start_url = BASE_URL + start
    end_url   = BASE_URL + end

    if start_url not in graph:
        sys.stderr.write("Wiki links do not exist in crawled graph\n")
        exit(EXIT_FAILURE)

    queue = []
    visited = set()
    parent = dict()

    queue.append(start_url)

    while queue:
        curr_link = queue.pop(0)

        if curr_link == end_url:
            path = back_trace(parent, start_url, end_url)

            print("="*80)
            print("Path between " + start + " and " + end )
            print("="*80)

            for url in path:
                print("> " + url)
            exit(EXIT_SUCCESS)

        visited.add(curr_link)
        neighbors = graph[curr_link] if curr_link in graph else []
        
        for neighbor in neighbors:

            if neighbor not in visited:
                queue.append(neighbor)
                parent[neighbor] = curr_link

    sys.stderr.write("No path between 2 links\n")
    exit(EXIT_FAILURE)

def main(args):
    graph_file, start, end = validate_args(args)
    
    with open(graph_file) as graph_json:
        graph = json.load(graph_json)
        
    bfs(graph, start, end)

if __name__ == "__main__":
    main(sys.argv[1:])
    