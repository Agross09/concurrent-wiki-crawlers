#!/usr/bin/env python
#-------------------------------------------------------------------------
#
#  File name: concurrent-spider.py
#
#  Description: Implementation of a Python web spider that
#  concurrently crawls Wikipedia sites and updates their graph
#  relationship using an adjacency matrix
#
#-------------------------------------------------------------------------
import sys
from threading import Thread, Lock
from bs4 import BeautifulSoup
from queue import Queue
import requests
import json

#=========================================================================
# Constants
BASE_URL          = "https://en.wikipedia.org"
DEFAULT_THREADS   = 20

# Maximum number of sites to be crawled
DEFUALT_SITE_LIMIT  = 1000

# Exit status
EXIT_FAILURE      = 1
EXIT_SUCCESS      = 0

# Global variables
job_queue               = Queue()
adjacency_matrix_lock   = Lock()
adjacency_matrix        = dict()

# Number of sites crawled so far
num_crawled_sites   = 0
# Current number of threads
curr_num_threads    = DEFAULT_THREADS

#=========================================================================
def create_job_queue(starting_url, num_worker_threads, site_limit):
    """
    Helper function: create_job_queue
    Parameters: num_worker_threads
    Returns: None
    Description: Create job queue for Worker threads
    """
    global num_crawled_sites
    # Add add <a> tag from starting url to the job queue
    source = requests.get(starting_url).text
    soup = BeautifulSoup(source, 'html.parser')

    # Fetch desired wikipedia sites
    for link in soup.find_all('a'):
        href = link.get('href')
        if href and len(href) > 6 and href[:6] == '/wiki/':
            # Add starting sites to the job queue
            if num_crawled_sites < site_limit:
                job_queue.put(BASE_URL + href)
                num_crawled_sites += 1

def consume(site_limit):
    """
    Helper function: consume
    Parameters: None
    Returns: None
    Description: Target for worker threads. Gets next site to crawl
    from job queue, updates global adjacency matrix
    """
    while (True):
        try:
            adjacency_matrix_lock.acquire()
            next = job_queue.get()
            # if (next is None) or (len(adjacency_matrix) > CRAWL_SITE_LIMIT):
            if (next is None):
                break
            crawl(next, site_limit)
        finally:
            job_queue.task_done()
            adjacency_matrix_lock.release()

#=========================================================================
def crawl(site, site_limit):
    """
    Helper function: crawl
    Parameters: site
    Returns: None
    Description: Helper function that scrapes given site and
    update adjacency matrix
    """
    global num_crawled_sites
    global curr_num_threads

    source = requests.get(site).text
    soup = BeautifulSoup(source, 'html.parser')

    if site not in adjacency_matrix:
        adjacency_matrix[site] = set()

    # Fetch desired wikipedia sites
    for link in soup.find_all('a'):
        href = link.get('href')
        if href and len(href) > 6 and href[:6] == '/wiki/':
            url = BASE_URL + href

            if url in adjacency_matrix:
                break
            else:
                adjacency_matrix[site].add(url)
                if num_crawled_sites < site_limit:
                    job_queue.put(url)
                    num_crawled_sites += 1

                # Put stop condition when number of crawled sites
                # is satisfied
                else:
                    if curr_num_threads > 0:
                        job_queue.put(None)
                        curr_num_threads -= 1

def get_args(args):
    """Process arguments"""
    starting_url = args[1]
    num_worker_threads = DEFAULT_THREADS
    site_limit = DEFUALT_SITE_LIMIT
    for i in range(2, len(args) - 1):
        if len(args) > i + 1:
            if args[i] == "-t":
                num_worker_threads = int(args[i + 1])
            elif args[i] == "-s":
                site_limit = int(args[i + 1])
        else:
            sys.stderr.write(
"Usage: starting url -t <#crawler threads> -s <site limit>\n")
            exit(0)
    return (starting_url, num_worker_threads, site_limit)

#=========================================================================
# Main function
def main(args):
    """
    Function main
    Parameters: starting_url
    Returns: None
    Description: Main driver for the program
    """
    (starting_url, num_worker_threads, site_limit) = get_args(args)

    # Start producer thread with starting url
    producer_thread = Thread (
        target=create_job_queue,
        args=[starting_url, num_worker_threads, site_limit]
    )
    producer_thread.start()

    worker_threads = []
    for _ in range(num_worker_threads):
        worker_threads.append(Thread(target=consume, args=[site_limit]))

    for thread in worker_threads:
        thread.start()

    for thread in worker_threads:
        thread.join()

    job_queue.join()

    for url in adjacency_matrix:
        adjacency_matrix[url] = list(adjacency_matrix[url])
    print(json.dumps(adjacency_matrix, indent=4))

#=========================================================================
if __name__ == '__main__':
    main(sys.argv)
