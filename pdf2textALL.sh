#!/bin/bash
# Use this script from a directory above all your pdf-containing subfolders 
# e.g. place script in /aaa with your pdfs for conversion in /aaa/pdfs1 /aaa/pdfs2 etc

# Turning on the nullglob shell option
shopt -s nullglob

# Make list of all subfolders in working directory, save as pwd.txt
find * -maxdepth 0 -type d -exec bash -c "cd \"{}\"; pwd" \;  > pwd.txt

# Loop through pwd cd'ing into each directory then pdftotext all PDFs within each subdirectory
for i in $(cat pwd.txt); do
  cd $i 
  for f in *.pdf
  do
	echo "converting $f"
        pdftotext "$f" "${f%.*}.txt" 
	done
done
