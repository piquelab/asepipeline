library(tidyverse)

sn <- scan(paste0("shortNames.txt"),what=character(0))

file_list <- paste0(sn,".Quasar.res.tsv.gz")
final_df <- map_df(file_list, read_tsv, .id = "file")

write_tsv(final_df,file="Final.combined.tsv.gz")

##read_tsv(paste0(pileupFolder,sample,".AD.txt.gz"),col_names=cn)

