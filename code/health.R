############## Health Indicators #############
#### RWJF County Health Rankings Dataset #####
##############################################

library(sf)
library(tidyverse)
library(readr)
library(tmap)
library(leaflet)

# set directory
setwd("~/Desktop/Spring 2020/GIS3/Final Project")



# load state county-level health data
library(readxl)
NC_health <- read_csv("Data/County Health/AdditionalMeasureData.csv", skip = 1)

# subset Upper Coastal Plain counties
health <- 
  NC_health %>%
  filter(County %in% c("Edgecombe", "Halifax", "Nash", "Northampton", "Wilson"))

# view variable names
names(health)

# set CRS
st_crs(UP_counties)
UP_counties <- st_transform(UP_counties, 2264)

# merge health data with county boundaries
health_merge <- merge(UP_counties, health, by.x = "CountyName", by.y = "County")
plot(health_merge["geometry"])

# confirm CRS
st_crs(health_merge)

# save health shapefile
st_write(health_merge, "Data/County Health/health.shp")

# basic health map
tmap_mode("view")

##### HEALTH MAPS #####

# % Diabetes Map
diabetesMap <- 
  tm_shape(UP_counties) +
  tm_borders(col = "white") +
  tm_shape(health_merge) +
  tm_borders() +
  tm_fill(col = "% Diabetic", alpha = 0.8, palette = "BuPu") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE, title = "Percentage of Population with Diabetes")
diabetesMap

# % Food Insecure Map
foodinsecureMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "% Food Insecure", alpha = 0.8, palette = "BuPu") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)
foodinsecureMap


# % Uninsured Map
uninsuredMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "% Uninsured", alpha = 0.8, palette = "BuPu") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)

# Frequent Physical Distress
physicaldistressMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "% Frequent Physical Distress", alpha = 0.8, palette = "BuPu") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)

# Frequent Mental Distress
mentaldistressMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "% Frequent Mental Distress", alpha = 0.8, palette = "BuPu") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)
