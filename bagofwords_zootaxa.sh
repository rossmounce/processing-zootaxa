#!/bin/bash
# Usage: use inside a folder with lots of pdftotext'd .txt files of Zootaxa papers
# This will chop-off the references and create a bag-of-words summary of the >3character strings of each paper
# These paper bag-of-words summaries are output as .ztx so they are not confused with raw input files

shopt -s nullglob                     # Turning on the nullglob shell option
ls *.txt > lstxt.ttt                  # Make list of all files to be 

for i in $(cat lstxt.ttt); do
  echo "word bag for $i"
        tac "$i" |                    #reverse cat each file, then grep for Refs and print only after this
        egrep "(Literature [cC]ited$|References$|REFERENCES$|Bibliography$|BIBLIOGRAPHY$|LITERATURE CITED$)" -m 1 -A 99999 | 
        strings |                     #removes special characters e.g Copyright symbol and other strangeness
        tr '[A-Z]' '[a-z]' |          #change to all lowercase 
        sed 's/[[:punct:]]/ /g' |     #remove all punctuation
        sed s/' '/\\n/g |             #replace spaces with newlines (each string on separate line)
        sort | uniq -c |              #sort strings and count unique strings
        sort -nr | awk 'length > 11' | > "$i.ztx"     #remove string counts of 3 or less characters e.g. 'the'
        #(optional) sed '/with$\|from$\|than$\|that$\|well$\|more$\|most$\|have$\|this$\|some$\|there$\|their$\|zootaxa$\|magnolia$\|press$/d' or better use R's textmining package tm to strip common-words 
	done
