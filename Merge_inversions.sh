#!/bin/bash

inputdir="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/Non_sister_pairs/tsv_files"
outdir="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/Non_sister_pairs/bed_files"

summaryfile="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/Non_sister_pairs/Inversions_summary.tsv"

mkdir -p $outdir

echo -e "Sample\tInversion_count\tTotal_inversion_length" > "$summaryfile"

for file in $inputdir/*.tsv; 
do 
Sample=$(basename $file .tsv)  #strip extension 
sed '1d' $inputdir/${Sample}.tsv > $inputdir/${Sample}_1.tsv #strip the headers from tsv file, bedtools won't work otherwise
#merge nearby inversion blocks
awk '{print $10, $12, $13}' OFS="\t" $inputdir/${Sample}_1.tsv | sort -k1,1 -k2,2n | /storage/project/r-sanderson353-0/mjoshi96/bedtools2/bin/bedtools merge -i stdin -d 10000 > $outdir/${Sample}_merged.bed

# Count inversions
count=$(wc -l < "${outdir}/${Sample}_merged.bed")

# Calculate total inversion length
inv_length=$(awk '{sum += $3 - $2} END {print sum}' "${outdir}/${Sample}_merged.bed")

# Add results to summary
echo -e "${Sample}\t${count}\t${inv_length}" >> "$summaryfile"

done

