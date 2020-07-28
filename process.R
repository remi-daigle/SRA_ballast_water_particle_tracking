require(tidyverse)
# verify
behav <- read.csv("track/behav_table_all", header=FALSE, stringsAsFactors=FALSE) %>% 
  mutate(V1=gsub(" ","_",V1))

datadir <- "/fs/isi-nas1/dfo/bioios/dfo_bioios/dar002/OUTPUT"

templatefile <- file("~/tmp/quickstart/process_template.job")
job <- readLines(templatefile,warn=FALSE)
close(templatefile)

for(r in 1:nrow(behav)){
    i <- behav[r,]
    if(!file.exists(paste0(datadir,"/counts_",as.character(i),".RDS"))){
        fn <- paste0("~/tmp/quickstart/process_",as.character(i),",.job") %>% gsub(",","",.)
        file.create(fn)
        jobfile <- file(fn)
        writeLines(job %>% gsub("template",as.character(i),.),jobfile)
        close(jobfile)
        print(as.character(i))
        system(paste0("jobsub ~/tmp/quickstart/process_",as.character(i),",.job") %>% gsub(",","",.))
    }
    
}

