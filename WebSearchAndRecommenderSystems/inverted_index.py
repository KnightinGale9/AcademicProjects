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

        # Get all the words from the website and put them into a list
        strings = []
        for string in body.strings:
            string = str(string).strip()
            if not string == "":
                strings.append(string)

        # add words into word dict
        linesplit = wordSplitter(lang, strings)
        for i in linesplit:
            if i[:5] == "https":
                continue
            if lang == "en" and len(i) < 1:
                continue
            if len(i) == 0:
                continue
            inputSimpleInvertedIndex(simple_inverted_index, i, website)

        # Get all the outlinks for each site and count the number of outlinks
        for anchor_tag in soup.find_all(name="a", href=True):
            # get the href from the anchor tag
            link = anchor_tag.get("href")
            # check if the href is a link, if it is then append it to the queue and add to the outlink counter
            if validators.url(link):
                q.append(link)

    # Generate file for simple inverted index
    if not os.path.isfile(f"{lang}_inverted_index.json"):
        file = open(f"{lang}_inverted_index.json", 'w')
        file.close()
    with open(f"{lang}_inverted_index.json", "w", encoding="utf-8") as simple_inverted_index_file:
        json.dump(simple_inverted_index, simple_inverted_index_file, ensure_ascii=False)


def wordSplitter(input, line):
    if input == "en" or input == "es":
        return westernwordSplitter(line)
    elif input == "zh":
        return easternwordSplitter(line)


def westernwordSplitter(line):
    newlist = []
    punctuation = "!\"#$%&'()*+,，：“”-./:;<=>?@[\]^_`{|}~。、《》»«©€™"
    for l in line:
        linelist = l.split()
        newstring = ""
        for i in range(len(linelist)):
            for j in linelist[i]:
                if j.isdigit():
                    continue
                if j in punctuation:
                    continue
                newstring = newstring + j
            newlist.append(newstring.lower())
            newstring = ""
    return newlist


def easternwordSplitter(line):
    newstring = ""
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    punctuation = "！!\"#$%&'()*+,-.，：“”/:;<=>?？@[\]^_`{|}~。、《》»«®"
    for i in line:
        for j in i:
            if j.isdigit() or j.isspace():
                continue
            if j in punctuation:
                continue
            if j in alphabet:
                continue
            if j in alphabet.upper():
                continue
            newstring = newstring + j
    return list(newstring)


def writeWords(domain, di, number):
    file = open(f"words{number}.csv", "w", encoding='utf-8')
    file.write(domain + ":" + ",")
    for i in range(99):
        out = di[i]
        file.write(str(out[1]) + ", " + str(out[0]) + "\n")
    out = di[99]
    file.write(str(out[1]) + ", " + str(out[0]) + "\n")
    file.close()


def inputSimpleInvertedIndex(di, inputword, filename):
    if inputword not in di:
        di[inputword] = {}
    if filename not in di[inputword]:
        di[inputword][filename] = 1
    else:
        di[inputword][filename] += 1


main()