#!/bin/bash

inputdir="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/tsv_files_reverse"
outdir="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/bed_files_reverse"
invlengthdir="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/Inversion_length_reverse"

mkdir -p $outdir
mkdir -p $invlengthdir

for file in $inputdir/*.tsv; 
do 
Sample=$(basename $file .tsv)  #strip extension 
sed '1d' $inputdir/${Sample}.tsv > $inputdir/${Sample}_1.tsv #strip the headers from tsv file, bedtools won't work otherwise
#merge nearby inversion blocks
awk '{print $10, $12, $13}' OFS="\t" $inputdir/${Sample}_1.tsv | sort -k1,1 -k2,2n | /storage/project/r-sanderson353-0/mjoshi96/bedtools2/bin/bedtools merge -i stdin -d 10000 > $outdir/${Sample}_merged.bed

#putting final inversion count for all files in a single file
wc -l $outdir/${Sample}_merged.bed > $outdir/${Sample}_count.txt
cat $outdir/${Sample}_count.txt >> $outdir/analysis5_counts_reverse.txt

#Counting total inversion length
awk '{sum += $3 - $2} END {print "Total inversion length: " sum " bp"}' $outdir/${Sample}_merged.bed > $invlengthdir/${Sample}_inv_length.txt

#Putting inversion length for all in a single file, together with filename
awk '{print FILENAME $0}' $invlengthdir/*.txt > Inversion_length_all.txt


#summarising in a single tsv file - This chunk doesn't work properly yet

#echo -e "sample\tinversion_count\tinversion_length" > Inversion_summary.tsv

#count=$(wc -l $outdir/${Sample}_merged.bed)
#inv_length=$(awk '{sum += $3 - $2} END {print sum}' $outdir/${Sample}_merged.bed)

#echo -e "${Sample}\t${count}\t${inv_length}" >> Inversion_summary.tsv

done

