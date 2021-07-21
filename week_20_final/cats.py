#!/usr/bin/env python

#1.	Write a python program (not a Jupyter notebook, but a py file you run from the command line) 
#that accepts the cats_txt.txt file as input and counts the frequency of all words and punctuation
# in that text file, ordered by frequency. Make sure to handle capital and lowercase versions of words and 
# count them together.

#with open("cats_txt.txt", "w") as text_file:

#apparently I had some encoding issues and the google told me to do this utf8 business
cat = open("cats_txt.txt", "r",  encoding='utf-8', errors = 'ignore')

import sys


#importing useful tidbits
from nltk.tokenize import wordpunct_tokenize
from collections import Counter


def frequency(text):
   
    # convert to string (thanks Amanda for the suggestion which makes my code much more concise than it was before)  
    cats = cat.read().replace("\n", " ")
    #closing per Nicole's instruction
    cat.close()

    #lowercase everything
    cats = cats.lower()
    # tokenize
    token = wordpunct_tokenize(cats)
    # counter for frequency
    frequency = Counter(token)

    return frequency.most_common()

print(frequency(cat))


