# python_test.py
# Description: Python module to test python functions called via Elixir using
#              Erlport
# When sending any string Elixir, you must call [str].encode("utf-8")

def print_hello():
    print("Hello Python")

def scrape(url):
    import time
    print("Hello Python")
    print("I am scraping")
    time.sleep(0)
    print("I am done scraping!")
    return url[::-1].encode("utf-8")

def scrape_dict(url):
    import json
    urlsA = ["wiki.comA", "wiki.comB", "wiki.comC"]
    urlsB = ["wiki.com1", "wiki.com2", "wiki.com3"]
    urlsC = ["wiki.com!", "wiki.com?", "wiki.com/"]
    
    url_dict = {
        url+"A": urlsA, 
        url+"1": urlsB, 
        url+"!": urlsC
    }
    return json.dumps(url_dict).encode("utf-8")

