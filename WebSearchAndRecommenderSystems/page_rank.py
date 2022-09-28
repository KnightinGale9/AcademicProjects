# Importing necessary libraries
import requests
import urllib.robotparser
from collections import deque
import langid
from bs4 import BeautifulSoup
import os
import validators
import time
import json
import copy


def main():
    crawl_page("https://www.cpp.edu", "en", 1)
    crawl_page("https://www.disney.es", "es", 2)
    crawl_page("https://news.sina.com.cn", "zh", 3)


# Function for crawling pages
def crawl_page(page, lang, number):
    robots_txt = page + "/robots.txt"

    # Create a queue
    q = deque()

    # Create a set for links
    crawled_set = set()

    # Create a set for pagerank websites
    pagerank_websites = set()

    # Create a dictinary for a simple inverted index
    simple_inverted_index = {}

    # Start with the first link
    starting_website = page
    q.append(starting_website)
    website_counter = 0

    # Set up a robot parser for checking if links can be crawled
    robot_parser = urllib.robotparser.RobotFileParser()
    robot_parser.set_url(robots_txt)
    robot_parser.read()

    # Set up graph for inlinks and dictionaries for outlinks
    inlinks = {}
    outlinks = {}

    # Crawl all the outlinks
    while website_counter < 500:
        website = q.popleft()
        print(website)
        # Check if the website has been crawled already or not
        if website in crawled_set:
            continue
        # Add website to the set of crawled links
        crawled_set.add(website)

        # Check the links that can be crawled through robots.txt
        if not robot_parser.can_fetch("*", robots_txt):
            continue

        # Get the html from the web page and set up BeautifulSoup
        try:
            time.sleep(0.0005)
            response = requests.get(website, timeout=10)
        except requests.exceptions.RequestException as error:
            continue
        soup = BeautifulSoup(response.content, "html.parser")
        body = soup.body
        # check to make sure there are contents in the body of the website
        if body == None:
            continue

        # Check if page is in the desired language
        # more accurate result for when sample text is too short of ambiguous
        identified_lang = langid.classify(str(body))[0]
        if identified_lang != lang:
            continue

        # update the counter for the number of websites that have been crawled
        website_counter += 1

        # Add the current website to the pagerank_website set
        pagerank_websites.add(str(website))

        # Get all the outlinks for each site
        for anchor_tag in soup.find_all(name="a", href=True):
            # get the href from the anchor tag
            link = anchor_tag.get("href")
            # print(link)
            # check if the href is a link, if it is then append it to the queue and add to the outlink counter
            if validators.url(link):
                q.append(link)
                # add the inlink to the graph
                if link not in inlinks:
                    inlinks[link] = set()
                inlinks[link].add(website)

                # add the outlink to the graph
                if website not in outlinks:
                    outlinks[website] = set()
                outlinks[website].add(link)

        print()

    # Get rid of the outlinks that we have not crawled yet
    for key in outlinks:
        outlinks[key] = outlinks[key].intersection(pagerank_websites)
    inlink2 = {}
    for key in pagerank_websites:
        if key in inlinks:
            inlink2[key] = inlinks[key]
        else:
            inlink2[key] = set()
    print("pagerank\n")
    print(pagerank_websites)
    print("\ninlink\n")
    print(len(inlink2))
    print(inlink2)
    print("\noutlink\n")
    print(len(outlinks))
    print(outlinks)
    # Calculate the pagerank
    calculatePageRank(pagerank_websites, inlink2, outlinks, lang)


def errorCheck(current, previous):
    check = True
    error = 0.5 * 10 ** -3
    for key in current:
        # find the relative error for each key
        if current[key] == 0:
            continue
        relerror = abs(current[key] - previous[key]) / current[key]
        # if any error does not comply then false
        if (error < relerror):
            check = False
            return check
    # if we go through all and check=true then convergence
    return check


def calculatePageRank(pagerank_websites, inlinks, outlinks, lang):
    # Calculate PageRank
    lambda_value = 0.2

    # Data structure for storing page rank calculations
    previous_pagerank = {}
    current_pagerank = {}
    # Set initial pagerank values
    n = len(pagerank_websites)
    # print(pagerank_websites)
    # print(n)
    for key in pagerank_websites:
        previous_pagerank[key] = 1 / n

    print(previous_pagerank)
    # for i in range(0, 20):

    while True:
        # Go through all links that have been crawled
        for key in pagerank_websites:
            pagerank_calculation = 0
            if key in inlinks:
                for inlink in inlinks[key]:
                    # print(inlink)
                    pagerank_calculation += (previous_pagerank[inlink] / len(outlinks[inlink]))

            current_pagerank[key] = (lambda_value / n) + (1 - lambda_value) * pagerank_calculation

        # if the current and previous pagerank don't have significant difference, then stop
        if errorCheck(current_pagerank, previous_pagerank):
            break

        # Set the current_pagerank to the previous_pagerank for next iteration
        previous_pagerank = copy.deepcopy(current_pagerank)
        print(current_pagerank)

        # Make sure the pageranks add up to 1
        pagerank_sum = 0.0
        for key in current_pagerank:
            pagerank_sum += current_pagerank[key]
        print(pagerank_sum)

    # Save the final pagerank calculations to a file
    if not os.path.isfile(f"{lang}_pagerank.json"):
        file = open(f"{lang}_pagerank.json", 'w')
        file.close()
    with open(f"{lang}_pagerank.json", "w", encoding="utf-8") as pagerank_file:
        json.dump(current_pagerank, pagerank_file, ensure_ascii=False)


main()