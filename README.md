# Concurrent Wikipedia Web Crawlers

Tufts University - Fall 2019

Benjamin Auerbach, Andrew Gross, Trung Truong

## Description

A Python tool that crawls and indexes Wikipedia sites concurrently

## Installing

Clone this repository. To install all dependencies and run the program, `pip3`
and `python3` are required. Navigate to root folder and run the following 
instructions to install dependencies.

```
pip3 install -r requirements.txt
```

To run the concurrent crawler,
```
python3 src/concurrent-spider.py <starting wikipedia url>
```

To run the breath-first-search algorithm on a graph,
```
python3 src/bfs.py graph.json <start> <end>
===========================================

python3 src/bfs.py graph.json Businessperson California
================================================================================
Path between Businessperson and California
================================================================================
> https://en.wikipedia.org/wiki/Businessperson
> https://en.wikipedia.org/wiki/National_capitalism
> https://en.wikipedia.org/wiki/File:A_coloured_voting_box.svg
> https://en.wikipedia.org/wiki/Abraham_Lincoln
> https://en.wikipedia.org/wiki/Democratic_Party_(United_States)
> https://en.wikipedia.org/wiki/California
```

To run the visualization prgram,
```
python3 src/viz.py graph_small.json
```

## Sample graphs

<img src="https://github.com/ttrung149/concurrent-wiki-crawlers/blob/crawler/media/graph-viz-2.png" width="40%">.

## Authors

* [Andrew Gross](https://github.com/Agross09)
* [Benjamin Auerbach](https://github.com/BenjaminSAu)
* [Trung Truong](https://github.com/ttrung149)

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details