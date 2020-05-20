# load libraries
library(sf)
library(tidyverse)
library(raster)
library(rgdal)
library(cdlTools)

# set directory
setwd("~/Desktop/Spring 2020/GIS3/Final Project")

##### Alt Start 1: download from USDA & load to environment #####

# load from local directory
nc <- "Data/USDA NASS Cropland Data Layer 2019/CDL_2019_clip_20200518231538_1929300428/CDL_2019_clip_20200518231538_1929300428.tif"
nc_raster <- raster(nc)

# check plot 
plot(nc_raster)

##### Alt Start 2 *used in this script*: cdlTools package #####

#install.packages("cdlTools")
#library(cdlTools)

# load 2019 NC data from cdlTools package
state <- 'North Carolina'
cdl.raster <- getCDL(x = state, 2019, location="~/")

# quick plot results
plot(cdl.raster$NC2019)

# Template from tutorial on cdlTools package, available here:
# http://meanmean.me/agriculture/r/2016/07/16/The-cdlTools-R-package.html#download

# rasterExtract is a quick function that polygonizes a SpatialPolygonsDataFrame 'x'
# to a given raster image extent and resolution 'r' with values specified by 'variable' in 

rasterExtract <- function(x,r,variable) {
  
  tempTif <- tempfile(fileext=".tif")
  tempShp <- tempfile(fileext=".shp")
  
  # write polygon
  writeOGR(x,dirname(tempShp),gsub("[.]shp","", basename(tempShp)),driver="ESRI Shapefile",overwrite=TRUE)
  
  # use gdalPolygonize
  if( missing(variable) ) {
    system(
      sprintf( "gdal_rasterize  -burn 1 -ot UInt32 -a_nodata 0 -a_srs '%s' -tr %f %f -te %f %f %f %f %s %s",
               projection(r), xres(r), yres(r), xmin(r), ymin(r), xmax(r), ymax(r),
               tempShp, tempTif)
    )
  } else {
    system(
      sprintf( "gdal_rasterize  -a '%s' -ot UInt32 -a_nodata 0 -a_srs '%s' -tr %f %f -te %f %f %f %f %s %s",
               variable, projection(r), xres(r), yres(r), xmin(r), ymin(r), xmax(r), ymax(r),
               tempShp, tempTif)
    )
  }
  
  # create a new raster object
  r.out <- raster(extent(r), ncols=ncol(r), nrows=nrow(r), crs=projection(r))
  values(r.out) <- values(raster(tempTif))
  
  # free up the data
  unlink(tempTif)
  unlink(tempShp)
  
  return(r.out)
}

library(rgdal)
library(rgeos)

# download county shape files
url <- sprintf("https://www2.census.gov/geo/tiger/TIGER2010/COUNTY/2010/tl_2010_%02d_county10.zip",fips(state))
download.file(url,destfile=sprintf('~/tl_2010_%02d_county10.zip',fips(state)))

#unzip
unzip(sprintf('~/tl_2010_%02d_county10.zip',fips(state)),exdir='~/')

#load
county <- readOGR(path.expand('~/'),sprintf('tl_2010_%02d_county10',fips(state)))

# quick plot
plot(county)

#re-project
county <- spTransform(county,projCDL)

#rasterize the shape files for NC counties
county.raster <- rasterExtract(county, cdl.raster$NC2019,'COUNTYFP10')

#plot out our current output to check if things look sane
plot(county.raster)
plot(county,add=T)
plot(nc_raster, add=T)

### Calculate Zonal Statistics with matchCount - corn

library(dplyr)
# we use matchCount to get the matched pairs between the rasters
# the parameter m is set to the maximum value in either raster image
cropByCounty <- matchCount(county.raster,cdl.raster$NC2019,m=200)
cropByCounty <- as.data.frame(cropByCounty)

# get all CDL classes that contain corn, available in the cdlTools 'corn' data
cornByCounty <- subset(cropByCounty, CDL_2019_37 %in% corn)

tmp <- county@data
tmp$layer <- as.numeric(as.character(county@data$COUNTYFP10))
cornByCounty <- left_join(cornByCounty, tmp, by=c("layer"="layer"))

aggregate(count ~ NAME10, data=cornByCounty,sum)


##### Cropping raster to specific Upper Coastal Plain area #####

# crop
crop_cdl <- crop(county, nc_raster)

plot(crop_cdl)

plot(nc_raster)
plot(crop_cdl, add=TRUE)  

# categorical

#cld_values <- raster::extract(x=nc_raster, y = crop_cdl, df = TRUE)

