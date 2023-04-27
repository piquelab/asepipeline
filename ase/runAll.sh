#!/bin/bash

cat shortNames.txt | \
while read sample; 
do    
    if [ ! -f "slurm.${sample}.out" ]; then 
	echo "#################"
	echo $sample 
	sbatch -q primary -n 4 -N 1-1 --mem=80G -t 8000 -J $sample -o slurm.$sample.out  --wrap "
module load R; 
Rscript compAse.R ${sample}
"  
    fi
done

