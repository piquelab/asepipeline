#!/usr/bin/env Rscript

# Get command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Parse arguments
if (length(args) < 1) {
    stop("No arguments provided. Provide a Sample name")
}

##Rscript compAse.R AF04
##sample="EU47"

sample=args[1]
pileupFolder="../pileups/"
outFolder='./'


library(tidyverse)

library(QuASAR)


##../pileups/AF04.AD.txt.gz
## ../pileups/AF04.AD.vcf.gz
## ../pileups/AF04.header.txt
## ../pileups/AF04.het.pos.txt


cn <- scan(paste0(pileupFolder,sample,".header.txt"),what=character(0))

cn <- c("chr","pos","ref","alt","All",cn)

dd = read_tsv(paste0(pileupFolder,sample,".AD.txt.gz"),col_names=cn)

dd$id <- paste(dd$chr,dd$pos,dd$ref,dd$alt,sep=":")

anno = read_tsv(paste0(pileupFolder,sample,".het.pos.txt"),
                col_names=c("chr","pos","rsid","ref","alt"))


anno$id <- paste(anno$chr,anno$pos,anno$ref,anno$alt,sep=":")   


dd2 <- inner_join(anno,dd) %>%
         separate(col="All",into=c("NRef","NAlt"),sep=",",convert=T) %>%
         mutate(NSum=NRef+NAlt) %>% filter(NSum>=50)

dim(dd2)

dd3 <-  dd2 %>% pivot_longer(cols=9:(ncol(dd2)-1),names_to="Exp",values_to="AD") %>%
    select(-c(NRef,NAlt)) %>%
    separate(col="AD",into=c("R","A"),sep=",",convert=T) %>%
    mutate(N=R+A) %>%
    filter(N>20) 

dd4 <- dd3 %>% group_by(Exp) %>%
    group_modify(function(a=.x,b=.y){
        dim(a)
        res <- fitQuasarMpra(a$R,a$A,rep(0.5,nrow(a)))
        cbind(a,res)
    })


dd4 <- dd4 %>% select(chr,pos,rsid,ref,alt,id,NSum,R,A,N,beta=betas.beta.binom,beta.se=betas_se,beta.z=betas_z,pval=pval3,padj_quasar,Exp)

dd4 <- dd4 %>% separate(col=Exp,into=c("Assay","Indiv","Cond"),sep="_",remove=FALSE)


sum(dd4$padj_quasar<0.1)

dd4 %>% filter(padj_quasar<0.1) %>%
    group_by(Exp) %>%
    summarize(n=n())

fn = paste0(outFolder,sample,".Quasar.res.tsv.gz")
write_tsv(dd4,fn)
