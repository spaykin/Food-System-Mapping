library(sf)
library(tidyverse)
library(readr)

# visualization packages
library(tmap)
library(leaflet)

setwd("~/Desktop/Spring 2020/GIS3/Final Project")


### NC County Boundaries

# load state county boundaries
nc <- st_read(dsn = "Data/NCDOT_County_Boundaries-shp/NCDOT_County_Boundaries.shp")

# subset Upper Coast Plain counties
UP_counties <- nc %>%
  select(CountyName, NAME, ShapeSTAre, ShapeSTLen, geometry) %>%
  filter(CountyName %in% c("Edgecombe", "Halifax", "Nash", "Northampton", "Wilson"))

plot(UP_counties["geometry"])

# check CRS
st_crs(UP_counties)
# CRS EPSG:2264, GCS_North_American_1983

# transform CRS
UP_counties <- st_transform(UP_counties, "+proj=lcc +lat_1=36.16666666666666 +lat_2=34.33333333333334 +lat_0=33.75 +lon_0=-79 +x_0=609601.2192024384 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")
st_crs(UP_counties)

