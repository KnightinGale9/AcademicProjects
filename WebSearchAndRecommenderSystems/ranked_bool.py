import json

inverted_index = {}

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
            ranking[k] = v
        for i in range(1, len(words) - 1, 2):
            for k in temp:
                if words[i] == "and":
                    ranking[k] = min(ranking[k], inverted_index[words[i + 1]][k])
                if words[i] == "or":
                    ranking[k] += inverted_index[words[i + 1]][k]
        sorting = []
        for k, v in ranking.items():
            sorting.append([v, k])
        sorting.sort(reverse=True)

        if len(sorting) != 0:
            output = ""
            for v, num in sorting:
                # print("doc",num,",",sep='',end=" ")
                output += "doc" + str(num) + ", "
            output = output[:-2]
            print(output + "\n")
        else:
            print("None\n")
    word_check = True