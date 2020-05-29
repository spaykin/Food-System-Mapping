##############################################
##### Cropland Data Layer - raster data ######
##############################################

# load libraries
library(sf)
library(tidyverse)
library(raster)
library(rgdal)
library(mapview)
library(tmap)
library(leaflet)
library(leafem)
library(cdlTools)
library(readxl)
library(rgdal)
library(rgeos)
library(data.table)
library(formattable)

############################################
#### STEP 1: Load & Prepare Raster Data ####
############################################

# set directory
setwd("~/Desktop/Spring 2020/GIS3/Final Project")

# download from USDA & load to environment 

# load from local directory
nc <- "Data/USDA NASS Cropland Data Layer 2019/CDL_2019_clip_20200518231538_1929300428/CDL_2019_clip_20200518231538_1929300428.tif"
nc_raster <- raster(nc)

# check plot 
plot(nc_raster)

################################################################
### STEP 2: Crop / Mask Raster to Upper Coastal Plain Region ###
################################################################

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

# mask raster
mask_cdl <- mask(cdl, UP_counties2)

# write raster to save locally
writeRaster(mask_cdl, "mask_cdl")

# read in mask raster
mask_cdl <- raster("Food-System-Mapping/data/mask_cdl.grd")

# simple plot of mask raster
plot(mask_cdl)
glimpse(mask_cdl)

# rename name variable to Category Code
glimpse(mask_cdl@data)
names(mask_cdl) <- "catCode"

# get color table
glimpse(mask_cdl@legend)
mask_cdl@legend@type
colortable <- colortable(mask_cdl) # 256 colors

# subset
cdl[UP_counties2, drop=FALSE]
class(cdl)
class(UP_counties2)

##############################
### STEP 3: Extract Values ###
##############################

# Extracting pixel values from the raster 
UP_cdl <- raster::extract(cdl, UP_counties["geometry"])
glimpse(UP_cdl)

# with correct CRS county boundaries
UP_cdl2 <- raster::extract(cdl, UP_counties2)
glimpse(UP_cdl2)
names(UP_cdl2) <- c("catCode", "catCode", "catCode", "catCode", "catCode")

# subset cdl to UP region
cdl_subset <- cdl[extent(UP_counties2), drop = FALSE]
plot(cdl_subset)

# rename variable to catCode
names(cdl_subset) <- "catCode"

# merge with catCodes into datagrame
df <- as.data.frame(cdl_subset)
df_merge <- left_join(df, catCodes)

# ratify
cdl_subset <- ratify(cdl_subset)

# get values
values <- as.data.frame(getValues(cdl_subset))

# filter catCodes for only data in this Raster
catcodes_filter <- 
  catCodes %>%
  filter(catCode %in% c(1,2,4:6, 10:12, 21, 24, 26:29, 36:37, 42:44, 46, 48, 50,
                        53, 57, 59, 61, 67, 69, 70, 74, 92, 111, 121:124, 131,
                        141:143, 152, 176, 190, 195, 205, 209, 213, 214, 216, 219,
                        221, 222, 225, 228:229, 236, 237:238, 240, 242:244))

# subs to substitute values in a raster values
cdl_subset3 <- subs(cdl_subset, df_merge, by = "catCode")
cdl_subset3 <- merge(cdl_subset@values, df_merge, by = "catCode")
cdl_subset3 <- merge(cdl_subset, df_merge, by.x = "catCode", by.y = "catCode")
cdl_subset3 <- left_join(cdl_subset, df_merge)

# check to ensure subsetting
cdl_subset_df <- as.data.frame(cdl_subset) # ~12,000,000 observations
cdl_df <- as.data.frame(cdl) # ~17,000,000 observations


# summarize category codes data 
cdl_subset2 <- as.data.frame(cdl_subset_df) %>%
  group_by(catCode) %>%
    count() %>%
    arrange(desc(n)) %>%
    mutate(
      n_pixels = n, # count number of 30m x 30 m pixels
      area_m = n_pixels * 900, # calculate square meters
      acres = area_m * 0.000247105, # calculate acreage
      acres = round(acres, 3)
      )

# join data
cdl_subset2 <- left_join(cdl_subset2, catCodes, by = "catCode")

# subset top crops in the region by acreage
topCrops <- cdl_subset2 %>%
  select("USDA Category Code" = catCode, "Crops" = `Land Cover`, "# Acres" = acres) %>%
  filter(`USDA Category Code` %in% c(5,2,1,61,37,
                        176,10,46,11,59))

# format acres with commas
topCrops$`# Acres` <- comma(topCrops$`# Acres`)

# format table
topCropsTable <- formattable(topCrops)

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

# check levels
levels(cdl_subset)

UP_countiesRaster <- raster(UP_counties2)
plot(cdl[UP_countiesRaster, drop = FALSE])

# raster, DATA FRAME
UP_cdl3 <- raster::extract(cdl, UP_counties2, df=TRUE)
glimpse(UP_cdl3)
names(UP_cdl3) <- c("ID", "catCode")


##### CREATE MAPS #####

# plot map
plot(mask_cdl) + plot(UP_counties2["geometry"], add = T)

# tmap map
croplandMap <- 
  tm_shape(mask_cdl, alpha = 0.7) +
  tm_raster(legend.show = FALSE) +
  tm_shape(UP_counties2) + 
  tm_borders() +
  tm_layout(frame = FALSE)
croplandMap

# leaflet map

# aggregate data
mask_cdl_agg <- raster::aggregate(mask_cdl, fact=5)

# leaflet map 
croplandMapLeaflet <- 
  leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addRasterImage(mask_cdl_agg[[1]], layerId = "CDL_2019_clip_20200518231538_1929300428", 
                 opacity = 0.6) %>%
  addMouseCoordinates() %>%
  addImageQuery(mask_cdl_agg[[1]],
                layerId = "CDL_2019_clip_20200518231538_1929300428",
                project = TRUE,
                position="bottomleft")

croplandMapLeaflet

# check number and names of layers
raster::nlayers(mask_cdl_agg)
names(mask_cdl_agg)




