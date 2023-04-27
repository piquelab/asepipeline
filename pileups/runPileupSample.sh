#!/bin/bash

#SBATCH --job-name $sample 
#SBATCH -q primary
#SBATCH -N 1-1
#SBATCH -n 12
#SBATCH --mem=120G
#SBATCH -o output_%j.out
#SBATCH -e errors_%j.err
#SBATCH -t 1-:0:0


set -e 
set -v

sample=$1

vcfFileMain=/wsu/home/groups/piquelab/barreiro2/genotypes/filtered.vcf.gz
fastaRef=/wsu/home/groups/piquelab/barreiro2/ref/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa
bamFolder=/nfs/osiris-pique/barreiro2/bams/
ncores=8


bcftools view -s $sample $vcfFileMain \
  | bcftools view -g het \
  | bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\n' \
  > $sample.het.pos.txt

##bcftools view -s AF04 ../../genotypes/filtered.vcf.gz | bcftools view -g het -Oz > AF04.het.vcf.gz

time bcftools mpileup -d 1000000 --min-MQ 30 --min-BQ 30 \
                      -a FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR \
                      -f $fastaRef -T $sample.het.pos.txt \
                      --threads $ncores \
                      ${bamFolder}/*/${sample}*bam \
     | bcftools call -m -Oz --threads $ncores \
     > ${sample}.AD.vcf.gz

bcftools query  -f '%CHROM\t%POS\t%REF\t%ALT\t%AD[\t%AD]\n' ${sample}.AD.vcf.gz | bgzip > ${sample}.AD.txt.gz 

bcftools query -l ${sample}.AD.vcf.gz | sed 's/.*bams\/\///g;s/.sorted.*bam//;s/\//_/' > ${sample}.header.txt
