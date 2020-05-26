# load libraries
library(sf)
library(tidyverse)
library(raster)
library(rgdal)
library(cdlTools)
library(readxl)

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


##########################
##### Alt 3: Velox #######

library(devtools)
install_github("hunzikp/velox")


#################
# from Isaac's Tutorial on NDVI Aggregation

# Load CDL data
cdl <- raster("Data/USDA NASS Cropland Data Layer 2019/CDL_2019_clip_20200518231538_1929300428/CDL_2019_clip_20200518231538_1929300428.tif")

# Load county boundaries
UP_counties
plot(UP_counties["geometry"])

# Transform CRS to match raster CRS
UP_counties2 <- st_transform(UP_counties, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
st_crs(UP_counties2)
st_crs(cdl)

# Test plot
plot(cdl)
plot(UP_counties2["geometry"], add=TRUE)

# Crop
crop_cdl <- crop(cdl, UP_counties2["geometry"])
plot(crop_cdl)

# rename name variable to Category Code
glimpse(crop_cdl@data)
names(crop_cdl) <- "catCode"

# Mask
mask_cdl <- mask(cdl, UP_counties2)

plot(mask_cdl)
glimpse(mask_cdl)
                       
# mask_df <- as.data.frame(mask_cdl, na.rm=TRUE) 
# 
# mask2 <- select(mask_cdl, catCode = CDL_2019_clip_20200518231538_1929300428)
# mask2 <- rename(mask_cdl@data, catCode = CDL_2019_clip_20200518231538_1929300428)

# mask_cdl2 <- mask(cdl, UP_counties2, updatevalue = 0)
# plot(mask_cdl2)

# rename name variable to Category Code
glimpse(mask_cdl@data)
names(mask_cdl) <- "catCode"


# get color table
glimpse(mask_cdl@legend)
mask_cdl@legend@type

colortable <- colortable(mask_cdl) # 256 colors
colortable


# subset

cdl[UP_counties2, drop=FALSE]
class(cdl)
class(UP_counties2)

plot(crop_cdl, main = "CDL Crop")

###################################################################################

# Extracting pixel values from the raster 
UP_cdl <- raster::extract(cdl, UP_counties["geometry"])
glimpse(UP_cdl)

UP_cdl4 <- raster::extract(cdl, UP_counties2, drop = FALSE)
glimpse(UP_cdl4)

# with correct CRS county boundaries
UP_cdl2 <- raster::extract(cdl, UP_counties2)
glimpse(UP_cdl2)
names(UP_cdl2) <- c("catCode", "catCode", "catCode", "catCode", "catCode")

# from Geocompt - 5.3.1
# Retrieve a spatial output

cdl_subset <- cdl[extent(UP_counties2), drop = FALSE]
plot(cdl_subset)

tmap_mode("plot")

# rename variable to catCode
names(cdl_subset) <- "catCode"

# merge with catCodes into datagrame
df <- as.data.frame(cdl_subset)
df_merge <- left_join(df, catCodes)

cdl_subset <- ratify(cdl_subset)

values(cdl_subset) # values is where the CatCodes are 
# get values
values <- as.data.frame(getValues(cdl_subset))

catCodes
names(values) <- "catCode"
names(values)

vals_merge <- left_join(values,
                        catCodes, by = "catCode")

raster_merge2 <- setValues(cdl_subset, catCodesList, layer = 2)

catCodesList <- list(catCodes[,2])

##################### THIS WORKED USE THIS ########################
levels(cdl_subset)[[1]]
levels(cdl_subset)[[1]] <- cbind(levels(cdl_subset)[[1]], catCode = catcodes_filter)
levels(cdl_subset)[[1]]

rat2 <- levels(cdl_subset)[[2]]
levels(cdl_subset) <- rat2

levels(cdl_subset)[[2]]

levelplot(cdl_subset$catCode)


# levels(cdl_subset)[[1]] <- merge(values, catCodes)
# levels(cdl_subset)

# filter out only data in Raster
catcodes_filter <- 
  catCodes %>%
  filter(catCode %in% c(1,2,4:6, 10:12, 21, 24, 26:29, 36:37, 42:44, 46, 48, 50,
                        53, 57, 59, 61, 67, 69, 70, 74, 92, 111, 121:124, 131,
                        141:143, 152, 176, 190, 195, 205, 209, 213, 214, 216, 219,
                        221, 222, 225, 228:229, 236, 237:238, 240, 242:244))

# filter only top crops
catcodes_crop_filter <- 


# subs to substitute values in a raster values
cdl_subset3 <- subs(cdl_subset, df_merge, by = "catCode")

cdl_subset3 <- merge(cdl_subset@values, df_merge, by = "catCode")
cdl_subset3 <- merge(cdl_subset, df_merge, by.x = "catCode", by.y = "catCode")
cdl_subset3 <- left_join(cdl_subset, df_merge)

# check to ensure subsetting
cdl_subset_df <- as.data.frame(cdl_subset) # ~12,000,000 observations
cdl_df <- as.data.frame(cdl) # ~17,000,000 observations

# summarize data 
cdl_subset2 <- as.data.frame(cdl_subset_df) %>%
  group_by(catCode) %>%
    count() %>%
    arrange(desc(n)) %>%
    mutate(
      n_pixels = n,
      area_m = n_pixels * 900,
      acres = area_m * 0.000247105,
      acres = round(acres, 3)
      )

cdl_subset2 <- left_join(cdl_subset2, catCodes, by = "catCode")


#TOP CROPS
# 5 - Soybeans
# 2 - Cotton
# 1 - Corn
# 61 - Fallow/Idle Cropland
# 37- Other Hay
# 176 - Grassland/Pasture
# 10 - Peanuts
# 46 - Sweet Potatoes
# 11 - Tobacco
# 59 - Sod / Grass Seed

topCrops <- cdl_subset2 %>%
  select(catCode, Pixels = n_pixels, Acres = acres, `Land Cover`) %>%
  filter(catCode %in% c(5,2,1,61,37,
                        176,10,46,11,59))

library(data.table)
library(formattable)

formattable(topCrops)

cdl_subset3 <- cdl_subset
levels(cdl_subset3)

levels(cdl_subset3)[[1]]

levelplot(cdl_subset3, col.regions = terrain.colors(63))

unique(cdl_subset)





ggplot() +
  geom_raster(cdl_subset)


class(cdl_subset2)

# read in Cat Codes metadata
catCodes <- read_xlsx("Data/USDA NASS Cropland Data Layer 2019/CropCatCodes.xlsx") %>%
  select(c(1:2))

# make numeric
catCodes$catCode <- as.numeric(catCodes$catCode)

# filter out only data in Raster
catcodes_filter <- 
  catCodes %>%
  filter(catCode %in% c(1,2,4:6, 10:12, 21, 24, 26:29, 36:37, 42:44, 46, 48, 50,
                        53, 57, 59, 61, 67, 69, 70, 74, 92, 111, 121:124, 131,
                        141:143, 152, 176, 190, 195, 205, 209, 213, 214, 216, 219,
                        221, 222, 225, 228:229, 236, 237:238, 240, 242:244))

# Merge CDL with MetaData!!!
cdl_subset2 <- left_join(cdl_subset2, catCodes, by = "catCode")

#cdl_subset_catCode <- left_join(cdl_subset, catCodes, by = "catCode")
#cdl_subset_catCode <- left_join(catCodes, cdl_subset, by = "catCode")

levels(cdl_subset)



UP_countiesRaster <- raster(UP_counties2)
plot(cdl[UP_countiesRaster, drop = FALSE])

glimpse(UP_countiesRaster)
glimpse(UP_countiesRaster@data)

# library(spData)
# data("elev", package = "spData")
# clip = raster(xmn = 0.9, xmx = 1.8, ymn = -0.45, ymx = 0.45,
#               res = 0.3, vals = rep(1, 9))
# elev[clip, drop = FALSE]

# raster, DATA FRAME
UP_cdl3 <- raster::extract(cdl, UP_counties2, df=TRUE)
glimpse(UP_cdl3)
names(UP_cdl3) <- c("ID", "catCode")

UP_cdl_df <- UP_cdl3

UP_cdl_new <- raster::extract(cdl, UP_counties2)

# Raw pixel count of land cover categorization code for each county

# From NASS: https://www.nass.usda.gov/Research_and_Science/Cropland/sarsfaqs2.php#Section1_6.0
# Counting pixels and multiplying by the area of each pixel will result in biased area estimates and should be considered raw numbers needing bias correction. 

# # Pixel size
# cell_res <- res(crop_cdl)
# cell_res # 30 x 30 meters (from metadata)
# 
# # df1
# df1 <- as.data.frame(UP_cdl[1])
# names(df1)[1] <- "catCode"
# 
# df1 <- df1 %>%
#   group_by(catCode) %>%
#   count() %>%
#   arrange(n) %>%
#   mutate(
#     area_m = n * 900,
#     acres = area_m * 0.000247105,
#     acres = round(acres, 3)
#     )
# 
# # df2
# df2 <- as.data.frame(UP_cdl[2])
# names(df2)[1] <- "catCode"
# 
# df2 <- df2 %>%
#   group_by(catCode) %>%
#   count() %>%
#   arrange(n)
# 
# 
# 
