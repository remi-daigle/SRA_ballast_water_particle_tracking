start.time <- Sys.time()
require(sf)
require(data.table)
require(purrr)
require(rnaturalearth)
require(ggplot2)
require(tidyverse)

datadir <- "/fs/isi-nas1/dfo/bioios/dfo_bioios/dar002/OUTPUT"
treatment <- commandArgs(trailingOnly = TRUE)[1]

files <- list.files(path=file.path(datadir,treatment),pattern="track*")

read_tracks <- function(datadir,treatment,track,releases,ll,proj,settle){
  track <- fread(file.path(datadir,treatment,track),drop=3) %>% 
    rowid_to_column(var="soak") %>% 
    mutate(soak=(soak-1)*60*60*2,
           release=releases[as.numeric(gsub("track","",track))]
    ) %>% 
    st_as_sf(coords=c("V1","V2"),crs=ll) %>% 
    st_transform(proj) 
  
  settle <- track %>% 
    st_intersects(settle,sparse=F) %>% 
    cbind(track) %>%
    as.data.frame() %>% 
    `colnames<-`(c(paste0("s_",as.character(settle$settle)),names(track))) %>% 
    select(-geometry) %>% 
    pivot_longer(cols=starts_with("s_"),names_to="site",names_prefix="s_",values_to="settlers") %>%
    filter(release!=site,
           settlers!=0)
}


proj <- "+proj=eqdc +lon_0=-61.7211914 +lat_1=43.0075207 +lat_2=50.5877283 +lat_0=46.7976245 +datum=WGS84 +units=m +no_defs"
ll <- 4269
QC <- c("Rimouski",
        "Sept-Iles",
        "Port-Menier",
        "Havre-Saint-Pierre",
        "Natashquan",
        "Kegaska",
        "La Romaine",
        "Harrington Harbour",
        "Tete-a-la-Baleine",
        "La Tabatiere",
        "St-Augustin",
        "Blanc-Sablon")



releases <- c(rep("Saint John Anchorage",2000),
              rep("Boston",2000),
              rep(QC,each=1000))

part <- fread("track/part_loc.ll") %>% 
  st_as_sf(coords=c("V1","V2"),crs=ll) %>% 
  mutate(release=releases)



settle <- rbind(st_sf(release="Saint John",geometry=st_sfc(st_point(c(-66.0438,45.216)),crs=ll)),part) %>% 
  filter(release!="Saint John Anchorage",
         release!="Boston") %>% 
  st_transform(proj) %>% 
  group_by(release) %>% 
  summarise(geometry=st_centroid(st_combine(geometry))) %>% 
  transmute(settle=release) %>% 
  st_buffer(3000)


#for(f in files){
#  print(f)
#  assign(f,read_tracks(datadir,treatment,f,releases,ll,proj,settle)) 
#}
#counts <- bind_rows(mget(files))

counts <- map_df(files,function(x) read_tracks(datadir,treatment,x,releases,ll,proj,settle)) %>%
  group_by(release,site,soak) %>%
  summarize(settlers=sum(settlers))

saveRDS(counts,file.path(datadir,paste0("counts_",treatment,".RDS")))
Sys.time()-start.time
