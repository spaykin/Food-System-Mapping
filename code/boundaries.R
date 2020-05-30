################################
##### NC COUNTY BOUNDARIES #####
################################

library(sf)
library(tidyverse)
library(readr)
# visualization packages
library(tmap)
library(leaflet)

#### CLEAN & SUBSET DATA ####

# set wd
setwd("~/Desktop/Spring 2020/GIS3/Final Project")

# load state county boundaries
nc <- st_read(dsn = "Data/NCDOT_County_Boundaries-shp/NCDOT_County_Boundaries.shp")
st_crs(nc)

# subset Upper Coast Plain counties
UP_counties <- nc %>%
  dplyr::select(CountyName, NAME, geometry) %>%
  filter(CountyName %in% c("Edgecombe", "Halifax", "Nash", "Northampton", "Wilson"))

##### PROJEC DATA #####
# check CRS
st_crs(UP_counties)
# CRS EPSG:2264, GCS_North_American_1983

# transform CRS
UP_counties <- st_transform(UP_counties, "+proj=lcc +lat_1=36.16666666666666 +lat_2=34.33333333333334 +lat_0=33.75 +lon_0=-79 +x_0=609601.2192024384 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")
st_crs(UP_counties)

##### CREATE MAPS #####

# NC map - region spotlight
tm_shape(nc) +
  tm_borders() +
  tm_shape(UP_counties) +
  tm_fill("lightblue", alpha = .7) +
  tm_borders() +
  tm_layout(frame = FALSE, 
            legend.show = FALSE)

# simple county border map
tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)

