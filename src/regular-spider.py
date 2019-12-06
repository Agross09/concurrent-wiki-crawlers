#!/usr/bin/env python
#--------------------------------------------------------------
#
#  File name: regular-spider.py
#
#  Description: Implementation of a Python web spider that
#  crawls Wikipedia sites and updates their graph relationship 
#  using an adjacency matrix
#  
#---------------------------------------------------------------
from bs4 import BeautifulSoup
import requests
import sys
import json

# Constants
BASE_URL          = "https://en.wikipedia.org"

def crawl(site):
    source = requests.get(site).text
    soup = BeautifulSoup(source, 'html.parser')

    neighbors = []
    for link in soup.find_all('a'):
        href = link.get('href')
        if href and len(href) > 6 and href[:6] == '/wiki/':
            neighbors.append(BASE_URL + href)

    print(json.dumps({site: neighbors}))

if __name__ == '__main__':
    crawl(sys.argv[1])