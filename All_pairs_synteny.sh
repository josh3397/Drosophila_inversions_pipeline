#!/bin/bash

inputalign="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/drosophila.hal"
PairFile="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/pairs.txt"
outdir="/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/halSynteny_results"

mkdir -p $outdir

while IFS=$'\t' read QUERY TARGET age
do
age=$(echo "$age" | tr -d '\r')
 
echo Analysing ${QUERY} vs ${TARGET}

/storage/home/hcoda1/7/mjoshi96/scratch/Mukta/Drosophila/cactus-bin-v3.1.4/bin/halSynteny --queryGenome ${QUERY} --targetGenome ${TARGET} --minBlockSize 10000 $inputalign "$outdir/output_${QUERY}_${TARGET}_${age}.psl"

done < "$PairFile"


