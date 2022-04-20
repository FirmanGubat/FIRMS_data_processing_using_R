###Package
library(RCurl)
library(sf)
library(rgdal)
library(dplyr)
library(tidyverse)
library(RPostgreSQL)
library(RPostgres)

###Pengolahan Data MODIS
#Download Data
file_base = "https://firms.modaps.eosdis.nasa.gov/data/country/modis/"
tahuns = paste0(sapply(as.character(2000:2020), function(x) if(nchar(x) == 1) paste0(0, x) else x, simplify = T))
for(tahun in tahuns){
  download.file(url = paste0(file_base, tahun,"/modis_",tahun,"_Indonesia.csv"),
                destfile = paste0("your destination folder","modis_", tahun, "_Indonesia.csv"),
                method = "curl", 
                quiet = T,
                mode = "wb")
}

#Convert CSV to SHP
file_dir = list.files(path = "your directory folder", full.names = TRUE)
for(file in file_dir) {
  dataku=read.csv(file)
  coords <- c("longitude", "latitude")
  geom_dataku=st_as_sf(dataku,coords = coords)
  st_crs(geom_dataku) = 4326
  names<-substr(file, 46, nchar(file_dir)-4)
  st_write(geom_dataku,dsn="your directory folder", layer=names, driver="ESRI Shapefile")
}

#Intersect Data modis dengan Batas Administrasi
file_dir = list.files(path = "your directory shapefile polygon", full.names = TRUE, pattern = "shp")
for(file in file_dir) {
  dataku=st_sf(st_read(file))
  keldes_jabar=st_sf(st_read("your directory shapefile"))
  sf::sf_use_s2(FALSE)
  out=st_join(dataku,keldes_jabar)%>%filter(!is.na(WADMKD))
  names<-substr(file, 46, nchar(file_dir)-14)
  st_write(out,dsn="your directory shapefile", layer=paste0(names,"_Jabar"), driver="ESRI Shapefile")
}

#Import Data Shapefile to PostgreSQL
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "database", user = "username", host = "host",
                 port = port, password = "pass")
file_dir = list.files(path = "your directory shapefile", full.names = TRUE, pattern = "shp")
for(file in file_dir) {
  dataku=st_read(file)
  names=substr(file, 52, nchar(file_dir)-4)
  skema=c("your schema",names)
  st_write(dataku,con,layer=skema)
}



###Pengolahan Data VIIRS S-NPP
file_base = "https://firms.modaps.eosdis.nasa.gov/data/country/viirs-snpp/"
tahuns = paste0(sapply(as.character(2012:2021), function(x) if(nchar(x) == 1) paste0(0, x) else x, simplify = T))
for(tahun in tahuns){
  download.file(url = paste0(file_base, tahun,"/viirs-snpp_",tahun,"_Indonesia.csv"),
                destfile = paste0("your directory folder","viirs-snpp_", tahun, "_Indonesia.csv"),
                method = "curl", 
                quiet = T,
                mode = "wb")
}

#Convert CSV to SHP
file_dir = list.files(path = "your directory folder", full.names = TRUE)
for(file in file_dir) {
  dataku=read.csv(file)
  coords <- c("longitude", "latitude")
  geom_dataku=st_as_sf(dataku,coords = coords)
  st_crs(geom_dataku) = 4326
  names<-substr(file, 51, nchar(file_dir)-4)
  st_write(geom_dataku,dsn="your directory folder", layer=names, driver="ESRI Shapefile")
}

#Intersect Data viirs snpp dengan Batas Administrasi
file_dir = list.files(path = "your directory folder", full.names = TRUE, pattern = "shp")
for(file in file_dir) {
  dataku=st_sf(st_read(file))
  keldes_jabar=st_sf(st_read("your directory shapefile polygon"))
  sf::sf_use_s2(FALSE)
  out=st_join(dataku,keldes_jabar)%>%filter(!is.na(WADMKD))
  names<-substr(file, 51, nchar(file_dir)-14)
  st_write(out,dsn="your directory folder", layer=paste0(names,"_Jabar"), driver="ESRI Shapefile")
}

#Import Data Shapefile to PostgreSQL
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "database", user = "usernam", host = "host",
                 port = port, password = "pas")
file_dir = list.files(path = "your directory shapefile", full.names = TRUE, pattern = "shp")
for(file in file_dir) {
  dataku=st_read(file)
  names=substr(file, 57, nchar(file_dir)-4)
  skema=c("your schema",names)
  st_write(dataku,con,layer=skema)
}