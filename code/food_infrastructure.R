library(sf)
library(tidyverse)
library(readr)

# visualization packages
library(tmap)
library(leaflet)

### NC Local Food Infrastructure

# load Local Foods Infrastructure dataset
localfoods <- st_read(dsn = "Data/Local_Foods_Inventory.shp")
plot(localfoods["geometry"])

# subset Upper Coastal Plain counties
UP_localfoods <- localfoods %>%
  filter(COUNTY %in% c("Edgecombe", "Halifax", "Nash", "Northampton", "Wilson"))
plot(UP_localfoods["geometry"])

# check CRS
st_crs(UP_localfoods) # no CRS

# transform CRS
UP_localfoods <- st_transform(UP_localfoods, crs)
plot(UP_localfoods["geometry"])

# quick overlay map
tm_shape(UP_counties) +
  tm_borders() +
  tm_shape(UP_localfoods) +
  tm_dots(col = "CATEGORY", size = 1) +
  tm_layout(frame = FALSE)





