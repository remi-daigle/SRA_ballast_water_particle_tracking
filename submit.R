fn <- commandArgs(trailingOnly=TRUE)[1]

system('jobst -u dar002>testjobs.txt')
test <- try(read.table('testjobs.txt',sep='|',header = TRUE)[-1,], silent=TRUE)

if(paste0(fn,'.job') %in% test$jobname){
    print(paste0('Job already running:',fn,'.job'))
} else if(nrow(test)>25) {
    print(paste0('Too many jobs running: ',fn,'.job not submitted'))
} else {
    system(paste0('jobsub ~/tmp/quickstart/particles_',fn,'.job'))
}
