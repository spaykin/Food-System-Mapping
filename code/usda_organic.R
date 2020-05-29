#######################################
##### USDA Organic INTEGRITY Data #####
#######################################

library(sf)
library(tidyverse)
library(readr)
library(ggmap)
library(rgdal)
library(raster)
library(sp)
library(readxl)
# visualization packages
library(tmap)
library(leaflet)

# set directory
setwd("~/Desktop/Spring 2020/GIS3/Final Project")

# read in data
integrity <- read_xlsx("Data/USDA Integrity 2019/NC_USDA Integrity 2019.xlsx") %>%
  select(c(5,1,33:36,38,49:63))

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
register_google(key = xx, write = TRUE)

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

# check crs 
st_crs(geo_integrity)

# simple plot of geometry
plot(geo_integrity["geometry"])

# check CRS
st_crs(UP_counties)
st_crs(geo_integrity)

# create dataframe
geo_integrity_df <- as.data.frame(geo_integrity)

# create coordinates
coordinates(geo_integrity_df) <- c("lon", "lat")
proj4string(geo_integrity_df) <- CRS("+proj=longlat + ellps=WGS84")

# transform CRS
geo_integrity_df <- spTransform(geo_integrity_df, "+proj=lcc +lat_1=36.16666666666666 +lat_2=34.33333333333334 +lat_0=33.75 +lon_0=-79 +x_0=609601.2192024384 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")
geo_integrity <- st_as_sf(geo_integrity_df)

UP_integrity <- st_intersection(UP_counties, geo_integrity)
class(UP_integrity)

#### MAPS

plot(UP_counties["geometry"])
plot(geo_integrity["geometry"], add = T)

tmap_mode("view")

organicMap <- 
  tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(integrity_subset) +
  tm_bubbles(col = "purple", size = .4, alpha = 0.6,
             popup.vars = c("Name" = "Name",
                            "Certifier" = "Certifier",
                            "Address" = "addresses",
                            "County" = "CountyName"
             )) +
  tm_add_legend(type = "fill", 
                labels = "Organic Operations",
                shape = "bubble",
                col = "purple", alpha = 0.6) +
  tm_layout(frame = FALSE)
organicMap



