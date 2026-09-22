# Drosophila_inversions_pipeline
This repository contains scripts that can be used to find number of inversions and total length of inversions (inverted bp) between two Drosophilidae species in a cactus alignment. The step by step instructions to do it are given below. All the genome assemblies as well as cactus alignment is publicly available as a part of this study - https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.3002697

1. To infer Synteny between two genomes from progressive cactus alignment, we can use halSynteny function, available as part of cactus and broader comparative genomic analysis 
toolkit (https://github.com/ComparativeGenomicsToolkit/cactus)

```
/path_to_cactus/bin/halSynteny your_alignment.hal Output.psl --queryGenome genome1 --targetGenome genome2 –blockSize 10000
```
–blockSize controls the minimum anchor size used when building synteny blocks from HAL alignment. Using **higher** block size is good to detect structural variation

2. Automating for all pairs (71 in this case)

Use script `All_pairs_synteny.sh`, where your species pairs along with their relative pair age (see background) are specified in file `pairs.txt`. Note that if this file was created in the mac system and then uploaded to cluster (unix environment), there will be standard characters (\t , \r, etc) present in the lines which will be carried to file names since they are 'attached' to the columns and are carried in the output filename. So, these characters have to be removed using dos2unix.

3. Interpreting and filtering the output

To understand what each column in output psl file represents, please visit UCSC genome browser site - https://genome.ucsc.edu/FAQ/FAQformat.html#format2
In psl file, the putative inversions can be detected from column #9, which represents the strand direction. You will either see '++' which indicates both query and target syntenic blocks are on the same strand, which '+-' will indicate putative inversion in target genome related to query genome. So we find all such putative inversions and filter them using followng criteria - 

a)	Filtering based on identity – ensures that spuriously aligned regions are filtered
b)	Removing tiny hits/alignments (query alignment end position - query alignment start position)
c)	Syntenic context – A true inversion occurs on the same chromosome and is flanked by collinear syntenic blocks on both sides

Note that sometimes filtering based on identity will remove lots of useful stuff (i.e., candidate inversions in this case), especially if you are working with taxa pair that are distantly related. **This filter has not been included in this analysis.** 

The filtering can be done using script `Filtering_inversions.py`. This script will take psl files as input, filter '+-' strands (on target genome) keeping alignment/synteny block size greater than 1000 (different size thresholds can be explored here), and retain inversions that occur on the same chromosome and are flanked by '++' strands. Note that all of the filtering will take place in target genome coordinate space, because we are detecting inversions on target genome. Output in tsv format will retain filtered inversions. 
To run for all 71 pairs,

```
for file in /path/to/psl_files; do python3 Filtering_inversions.py ${file}; done
```

4. Merging nearby inversion blocks and counting total inverted bp

To merge candidate inversions that are within a specified distance of one another, 'bedtools merge' can be used. Before running bedtools, the header has to be removed (sed '1d' option) as bedtools won't work otherwise. Next, the columns in tsv files should be sorted first according to chromosomes/contig positions (-k1, 1) and then according to coordinates (-k2, 2n) (because this is requirement by bedtools). 
Finally, to count total inverted bp (after merging), we use simple awk command which output the sum of difference between coordinates of start and end position for each inversion. 

Script `Merge_inversions.sh` performs all the above tasks for all 71 pairs. 

#### Important! Detecting inversions using halSynteny tells you about the sequences that are inverted in target relative to the query genome. It is impossible to know whether inversions were gained in target genome or lost in query genome without bringing an outgroup and cheking which orientation it carries.
