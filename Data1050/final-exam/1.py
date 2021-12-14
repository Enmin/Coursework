# Your code answer here:
import requests
from bs4 import BeautifulSoup

# TODO add appropriate import statements

page = requests.get('http://shakespeare.mit.edu/othello/full.html')
html = page.text

soup = BeautifulSoup(html, 'html.parser')


def clean_page(html):
    # convert the page.text into a BeautifulSoup object
    soup = BeautifulSoup(html, 'html.parser')
    # navigate to the HTML body node (look at calls to .body)
    body = soup.body
    # remove the header (note that it is wrapped in a table)
    table_tag = body.table
    table_tag.decompose()
    # now return the text from the body
    return body.get_text()


### Problem 1.1 All the Words
# 1. Make this function make a string of text into a list of words.
# 2. Have it take out the punctuation.
# 3. Have it make the words lowercase.
# 4. It must return the list
def lowercase_and_split(s):
    # time complexity: O(n), space : O(n)
    # lower all the string and use space to replace non-alpha characters and rejoin into a string
    lower_s = "".join([i.lower() if i.isalpha() else " " for i in s])
    # split the sentence into words based on the space because space separate words in english
    words = lower_s.split(" ")
    # remove the empty string because of the two space next to each other in the first process
    real_words = [w for w in words if w != '']
    return real_words


### Problem 1.2 Largest Words
# 1. This function should take a list of words.
# 2. It needs to return the n largest words.
# 3. When words are the same length they need to be returned in alphabetical order.
def largest_words(text, n=3):
    # space O(1), time O(n^2)
    # sort the text based on string length
    for i in range(len(text)):
        for j in range(i+1,len(text)):
            if len(text[i]) < len(text[j]):
                text[i], text[j] = text[j], text[i]
    # sort the text based on alphabetical order
    for i in range(len(text)):
        for j in range(i+1,len(text)):
            if len(text[i]) == len(text[j]) and text[i] > text[j]:
                text[i], text[j] = text[j], text[i]
    return text[:n]


### Problem 1.3 Most Common Words
# 1. Create a list of the n words that occur the most.
# 2. When words are the same length they need to be returned in alphabetical order.
def most_common_words(text, n=3):
    # time O(n^2), space O(n)
    count = {}
    # count the occurrence of words
    for i in text:
        if i in count.keys():
            count[i] = count[i] + 1
        else:
            count[i] = 1
    # sort the dict and return n most frequent words, this is O(nlogn)
    sorted_count = [(k,v) for k, v in sorted(count.items(), key=lambda item: item[1])]
    # append the top words into top list
    top = []
    i = 0
    while i < n:
        top.append(sorted_count[i])
        i += 1
    remaining = []
    # append more than n words if there are words have same occurrence in parallel
    if i < len(sorted_count) and sorted_count[i][1] == top[-1][1]:
        remaining = [k for k,v in sorted_count[i:] if v == top[-1][1]] + [k for k,v in top if v == top[-1][1]]
    # take those last words in parallel out of top list
    top = [k for k,v in top if v > top[-1][1]]
    # use previous function to return the largest top words
    top = largest_words(top, len(top)) + largest_words(remaining, n - len(top))
    return largest_words(top, n)



### Problem 1.4 Find Words
# Your job to quickly find all occurrences of a set of words in a text stored as another
# list of words.  This function needs to do that, and should return a list of lists
# with the locations corresponding to each word that is to be found.
def find_words(words, text):
    # space: O(n), time: O(n)
    # build a dictionary to store the seen word locations if word is in words
    locations = {}
    # loop through the text and add word location into locations
    for i in range(len(text)):
        # check if the word is in words
        if text[i] in words:
            # check if we see the words before
            if text[i] in locations.keys():
                locations[text[i]] = locations[text[i]] + [i]
            else:
                locations[text[i]] = [i]
    # return the lists of list in order
    results = [locations[word] for word in words]
    return results


### Problem 1.5 Tokenization
# This function takes a list of words and a dictionary, and uses the dictionary to
# replace words with numbers using a token dictionary.  If a word is not found, add a
# new entry in the dictionary for it, and a unique number is assigned to it.
# When it is all done, this function returns both the tokenized list and the token dictionary.
def tokenize(text, tokens=None):
    # space: O(n), time: O(n)
    # create tokens dict if none
    if tokens is None:
        tokens = {}
    # use an incre to set token for new words
    incre = 0
    # loop through the text
    for i in range(len(text)):
        # use token if we see the word before
        if text[i] in tokens.keys():
            text[i] = tokens[text[i]]
        # use incre if we haven't seen
        else:
            # find a new unique incre the the unseen word
            while incre in tokens.values():
                incre += 1
            tokens[text[i]] = incre
            text[i] = incre
            incre += 1
    return text

def test_lowercase_and_split():
    s = 'my name!! is Enm,in Zhou[]'
    assert lowercase_and_split(s) == ['my', 'name', 'is', 'enm', 'in', 'zhou']


def test_largest_words():
    s = ['my', 'name', 'is', 'enm', 'in', 'zhou']
    assert largest_words(s) == ['name', 'zhou', 'enm']

def test_most_common_words():
    s = ['my', 'name', 'is', 'enm', 'in', 'zhou']
    assert most_common_words(s) == ['name', 'zhou', 'enm']

def test_find_words():
    s = ['my', 'name', 'my', 'is', 'enm', 'zhou', 'in', 'zhou']
    assert find_words(['my', 'is', 'zhou'], s) == [[0, 2], [3], [5,7]]

def test_tokenize():
    s = ['my', 'name', 'my', 'is', 'enm', 'zhou', 'in', 'zhou']
    assert tokenize(s) == [0,1,0,2,3,4,5,4]

if __name__ == "__main__":
    text = clean_page(html)
    words = lowercase_and_split(text)
    test_lowercase_and_split()
    test_largest_words()
    test_most_common_words()
    test_find_words()
    test_tokenize()

'''
n the previous functions, we will sort and compare based on the value of tokens if we use the tokenization. However, the part that counts the occurrences will not change since tokenization does not have an impact on that. When we build the token dictionary, the key will be the tokens and the values will be the words. If we design the token based on the length and alphabetical order the words, we will have a smaller time complexity in sorting and comparing part in the above, However we will have to pass a dictionary every time so that our space complexity will be larger.

'''