starttime <- Sys.time()

dir.exists = function(paths) {
  x = base::file.info(paths)$isdir
  !is.na(x) & x
}

# verify
behav <- read.table("track/behav_table",stringsAsFactors = FALSE)

tracks <- paste0("track",1:nrow(read.table("track/part_loc.ll")))

verified <- rep(FALSE,nrow(behav))
for(i in 1:nrow(behav)){
  fn <- paste0(behav[i,],collapse = '_')
  if(dir.exists(file.path("/fs","isi-nas1","dfo","bioios","dfo_bioios","dar002","OUTPUT",fn))){
    if(all(file.exists(file.path("/fs","isi-nas1","dfo","bioios","dfo_bioios","dar002","OUTPUT",fn,tracks)))){
      print(paste("Verified:",fn))
      verified[i] <- TRUE
    } else {
      print(paste("Missing file:",fn))
    } 
  } else {
    print(paste("Missing folder:",fn))
  }
}

write.table(behav[!verified,],"track/behav_table",row.names = FALSE,col.names = FALSE, quote = FALSE)


# wait
system('jobst -u dar002>testjobs.txt')
test <- try(read.table('testjobs.txt',sep='|',header = TRUE)[-1,], silent=TRUE)
if(class(test)=="try-error") test <- data.frame(jobname='verify.job')

while(sum(test$jobname!='verify.job')>15){
  print("Jobs (>5) are still running...")
  Sys.sleep(120)
  system('jobst -u dar002>testjobs.txt')
  test <- try(read.table('testjobs.txt',sep='|',header = TRUE)[-1,], silent=TRUE)
  if(class(test)=="try-error") test <- data.frame(jobname='verify.job')
  
  if(as.numeric(Sys.time()-starttime,units = "secs")>3600){
    system('jobsub ~/tmp/quickstart/verify.job')
    stop()
  }
}

#Resubmit or zip
if(nrow(behav[!verified,])>0){
  print('resubmitting runs loop...')
  system('make loop')
} else {
  print('all runs complete!')
  system('make zip')
}
