# Extracting and Manually Labelling Zootaxa Figure Captions

## Author: 
Ross Mounce, University of Bath

## Operating System and specific software tools used in this article
Ubuntu Linux 13.10, *grep*, *tr*, *sed*, *wget*, *pdftotext*

## Aim:

We want to automate the process of determining if a figure caption of a scientific paper relates to a phylogenetic tree figure (image). We will start-off approaching this as a binary classification problem; either the figure caption relates to a phylogenetic tree in the corresponding figure image (scored as '1'), or it does not (scored as '0'). This will help identify the figure images for which further processing is applicable, downstream, to attempt to convert (only) phylogenetic tree images back into open, immediately re-usable, machine-readable data. 


## Method:

Legally-obtain papers from Zootaxa website corresponding to all material (inc. editorials, corrections, front matter...) published in the year 2012 (January 1st to December 31st inclusive).

Download the table of contents for Zootaxa papers in 2012: 
```wget http://www.mapress.com/zootaxa/list/list2012.html``` 

Parse out the URLs from this table of contents HTML, of the 450 issues published in 2012:

```
grep -i '2012/....\.html' list2012.html | tr "\"" "\n" | grep '\.html'| sed 's@2012@http://www\.mapress\.com/zootaxa/list/2012@g'  > list-of-450-URLs-for-all-2012-issues.txt
```

Download all issue table of contents pages, for 2012:
```wget -w 30 -i list-of-450-URLs-for-all-2012-issues.txt```

N.B. Zootaxa (Magnolia Press) is a hybrid journal. Some articles are freely-available without a subscription-required to access them. But the majority of articles are not freely-available to download, and instead require a personal or institutional subscription to download.

On each issue HTML page the freely-available article PDFs are indicated with this URL structure:
```
http://www.mapress.com/zootaxa/2012/f/zt03165p024.pdf
```

Where the '/f/' is the indicator that it is freely available, zt_issue number_p_EndPageNumber_.pdf

The subscription-access-only article PDF URLs  are indicated with this URL structure:
    http://www.mapress.com/zootaxa/2012/1/zt03590p072.pdf (real URL)
    OR
    http://www.mapress.com/zootaxa/2012/2/zt03165p063.pdf (real URL)
    OR
    http://www.mapress.com/zootaxa/2012/s/zt03165p063.pdf (made-up example)

Where '/s/' '/1/' or '/2/' indicate that it is subscription-only.

All 'preview' abstract+references only PDFs have URLs of the form:
```
http://www.mapress.com/zootaxa/2012/f/z03154p039f.pdf
```

Where '*f.pdf' indicates that it is a preview PDF, not a fulltext PDF. 

Having noted these general rules, I must point out that this website structure is not perfect in practice. I have personally contacted (via email) the editor of Zootaxa more than once to point out incorrectly specified and dead/broken links to articles, which have subsequently been fixed. The website structure is not guaranteed to be static. This describes how it is as of 16/04/2014.

Thus based-upon these assumed rules (above), one can parse the 450 downloaded HTML issue pages for links to fulltext-only article PDFs with the following commands:
```
grep -i '\.pdf' *.html | tr "\"" "\n" | grep '\.pdf' | grep -v 'f\.pdf' | sort -u | sed 's@\.\./\.\./2012@http://www\.mapress\.com/zootaxa/2012@g' > 2012-Zootaxa-Fulltext-Articles.txt
```

This method determines that there are 1972 fulltext articles available across all the 450 issues published in Zootaxa in 2012.

Then proceed to download each unique fulltext article PDF at a responsible download-rate (30-second delay between file downloads) from the parsed list with:
```
wget -w 30 -i 2012-Zootaxa-Fulltext-Articles.txt
```

Broken links: 
a) 
Erratum 
Zootaxa 3440: 68 (27 Aug. 2012)
Anker, A. (2012) “Revision of the western Atlantic members of the Alpheus armillatus H. Milne Edwards, 1837 species complex (Decapoda, Alpheidae), with description of seven new species”. Zootaxa, 3386, 1–109. 

FIX -> Download the preview PDF instead (it's the same, it's a 1-page erratum article):
```
wget http://www.mapress.com/zootaxa/2012/f/z03440p068f.pdf
```

Check the downloaded PDF files:
```
#!/bin/bash
for f in *.pdf; do
  echo "checking $f"
  if pdfinfo "$f" > /dev/null; then
    : Nothing
  else
    echo "$f is broken"
  fi
done
```

Create a plaintext copy of each unique fulltext article PDF using *pdftotext*:
```
	#!/bin/bash	
	for f in *.pdf
	do
	echo "making a plaintext copy of $f"
        pdftotext "$f"  
	done 
```

Check if there are any empty (zero byte sized) plaintext files, indicating an error in the pdftotext conversion:
```
find . -type f -name '*.txt' -size 0
```

Tidy up:
```
mkdir plaintext
mv *.txt plaintext/
cd plaintext/
```


**Possible sources of error and/or incompleteness with the above method:**

1. Potential for the website HTML scraping and parsing methods to miss an issue or PDF link somehow if unanticipated irregular or non-standard HTML is used onsite.
2. Connection problems with server when downloading the PDF files, resulting in missing, incomplete or corrupt PDF files.
3. If *pdftotext* cannot reliably create a complete plaintext copy of some PDF files (this has been observed to happen with a very small number of Zootaxa 'version of record' PDFs).	


