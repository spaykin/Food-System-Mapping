library(sf)
library(tidyverse)
library(readr)
library(ggmap)
library(rgdal)
library(raster)

# visualization packages
library(tmap)
library(leaflet)

setwd("~/Desktop/Spring 2020/GIS3/Final Project")

#### USDA Integrity Data

# read in data
integrity <- read_xlsx("Data/USDA Integrity 2019/NC_USDA Integrity 2019.xlsx") %>%
  select(c(1,5,33:36,38,49:63))

names(integrity)

addresses <- paste(integrity$`Physical Address: Street 1`, 
                       integrity$`Physical Address: City`, 
                       integrity$`Physical Address: State/Province`, 
                       integrity$`Physical Address: ZIP/ Postal Code`, 
                       sep = ", ")

integrity$addresses <- addresses

# Loop through the addresses to get the latitude and longitude of each address and add it to the
# geo_integrity data frame in new columns lat and lon

# REGISTER GOOGLE API
register_google(key = "AIzaSyBJkg-WXWMFWyCOZfM-yyoyhj__2JySDGw", write = TRUE)

geo_integrity <- data.frame(stringsAsFactors = FALSE)

for(i in 1:nrow(integrity))
  {
  # Print("Working...")
  result <- geocode(integrity$addresses[i], output = "latlon", source = "google")
  integrity$lon[i] <- as.numeric(result[1])
  integrity$lat[i] <- as.numeric(result[2])
  #integrity$geoAddress[i] <- as.character(result[3])
}

# Write a CSV file containing origAddress to the working directory
write.csv(integrity, "geocoded.csv", row.names=FALSE)

# Read in Shapefile
geo_integrity <- st_read("Data/USDA Integrity 2019/integrity_geo2.shp")

st_crs(geo_integrity)

plot(geo_integrity["geometry"])

st_crs(UP_counties)
st_crs(geo_integrity)

library(sp)

geo_integrity_df <- as.data.frame(geo_integrity)

coordinates(geo_integrity_df) <- c("lon", "lat")
proj4string(geo_integrity_df) <- CRS("+proj=longlat + ellps=WGS84")
geo_integrity_df <- spTransform(geo_integrity_df, "+proj=lcc +lat_1=36.16666666666666 +lat_2=34.33333333333334 +lat_0=33.75 +lon_0=-79 +x_0=609601.2192024384 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")

geo_integrity <- st_as_sf(geo_integrity_df)

tmap_mode("view")

tm_shape(UP_counties) +
  tm_borders() +
  tm_shape(geo_integrity) +
  tm_dots() +
  tm_layout(frame = FALSE)

plot(UP_counties["geometry"])
plot(geo_integrity["geometry"], add = T)

UP_integrity <- st_intersection(UP_counties, geo_integrity)
class(UP_integrity)

plot(integrity_subset["geometry"])

tmap_mode("view")

tm_shape(UP_counties) +
  tm_borders() +
  tm_shape(UP_integrity) +
  tm_dots()




