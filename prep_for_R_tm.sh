#!/bin/bash
# Usage: batch prep .txt files for use with tm package in R
# Outputs: one string per line files as .ooo of all strings >3, with custom word-stemming

shopt -s nullglob

# Make list of all files
ls *.txt > lstxt.ttt

# Loop through pwd cd'ing into each directory then pdftotext all PDFs within each subdirectory
for i in $(cat lstxt.ttt); do
  echo "word bag for $i"
        tac "$i" |                    #reverse cat each file, then grep for Refs and print only after this
        strings | 		      #removes annoying illegal characters that have been seen to break the next step!
        egrep "(Literature [cC]ited$|References$|References [cC]ited$|REFERENCES$|Bibliography$|BIBLIOGRAPHY$|LITERATURE CITED$|References \[not in Zootaxa format\]$|^Reference$|^Literature$|^References \(asterisks)" -m 1 -A 99999 | 
        tac |                #puts file back into correct order, minus References section (if it ever had one, some dont e.g. erratums)
        tr '[A-Z]' '[a-z]' |          #change to all lowercase
        sed 's/[[:punct:]]/ /g' |     #remove all punctuation
        sed s/' '/\\n/g |             #replace spaces with newlines (each string on separate line)
        sort | awk 'length > 3' |     #sort strings & remove string counts of 3 or less characters e.g. 'the'
        sed -r 's/phylog.+/phylogSTEM/g' |    #custom stemming  phylogenetic, phylogeny, phylogentically, phylogenetics
        sed -r 's/cladog.+/cladistii/g' |     #stemming cladogram, cladograms, cladogenetic
        sed -r 's/cladist.+/cladistSTEM/g' |  #stemming cladistic, cladistically, cladistics
        sed -r 's/parsimon.+/parsimonSTEM/g' | #struggling to get stopwords working in R, so partial bash removal below
        sed '/with$\|from$\|than$\|that$\|well$\|more$\|most$\|have$\|this$\|some$\|there$\|their$\|zootaxa$\|magnolia$\|press$/d' |
        sed '/words$\|copyright$\|print$\|abstract$\|online$\|introduction$\|accepted$\|published$\|methods$\|issn$\|discussion$\|edition$\|known$\|used$\|found$/d' |
	sed '/figure$\|however$\|into$\|same$\|except$\|these$\|only$\|which$\|also$\|each$\|other$\|between$\|were$/d' | 
	sed '/[0-9]/d' | #words containing numbers, then apply Porter stemmer (the last step below)
	perl stem.pl > "$i.ooo"
	done
