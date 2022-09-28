import json

inverted_index = {}
pagerank = {}

# Load the pagerank into a dictionary
with open('en_pagerank.json', encoding="utf-8") as json_file:
    en_pagerank = json.load(json_file)
    pagerank.update(en_pagerank)

with open('es_pagerank.json', encoding="utf-8") as json_file:
    es_pagerank = json.load(json_file)
    pagerank.update(es_pagerank)

with open('zh_pagerank.json', encoding="utf-8") as json_file:
    zh_pagerank = json.load(json_file)
    pagerank.update(zh_pagerank)

# Load the inverted indices into a dictionary
with open('en_inverted_index.json', encoding="utf-8") as json_file:
    en_inverted_index = json.load(json_file)
    inverted_index.update(en_inverted_index)

with open('es_inverted_index.json', encoding="utf-8") as json_file:
    es_inverted_index = json.load(json_file)
    inverted_index.update(es_inverted_index)

with open('zh_inverted_index.json', encoding="utf-8") as json_file:
    zh_inverted_index = json.load(json_file)
    inverted_index.update(zh_inverted_index)

word_check = True
while word_check:
    search = input("Please enter your query (Enter empty line to exit): ")
    search = search.lower()
    if search == "":
        break
    words = search.split(" ")
    print("Relevant documents: ", end="")
    for check in words:
        if check not in inverted_index:
            print(" None\n")
            word_check = False
            break
    if word_check:
        # finding which documents share the same word
        temp = inverted_index[words[0]].keys()
        for i in range(1, len(words) - 1, 2):
            temp = temp & inverted_index[words[i + 1]].keys()
        # finding the term frequencies for a word shared in the same documents
        ranking = {}
        for k, v in inverted_index[words[0]].items():
            if k in pagerank:
                ranking[k] = v
        for i in range(1, len(words) - 1, 2):
            for k in temp:
                if k in pagerank:
                    if words[i] == "and":
                        ranking[k] = min(ranking[k], inverted_index[words[i + 1]][k])
                    if words[i] == "or":
                        ranking[k] += inverted_index[words[i + 1]][k]
        sorting = []
        for k, v in ranking.items():
            sorting.append([v * pagerank[k], k])
        sorting.sort(reverse=True)

        # output the links in sorted order
        if len(sorting) != 0:
            output = ""
            for v, num in sorting:
                output += str(num) + ", "
            output = output[:-2]
            print(output + "\n")
        else:
            print("None\n")
    word_check = True