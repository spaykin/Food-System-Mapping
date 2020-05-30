########################################
##### NC Local Food Infrastructure #####
########################################

# load libraries
library(sf)
library(tidyverse)
library(readr)
# visualization packages
library(tmap)
library(leaflet)

#### CLEAN & SUBSET DATA ####

# set directory
setwd("~/Desktop/Spring 2020/GIS3/Final Project")

# load Local Foods Infrastructure dataset
localfoods <- st_read(dsn = "Data/Local Foods Inventory/Local_Foods_Inventory.shp")
plot(localfoods["geometry"])

# subset Upper Coastal Plain counties
UP_localfoods <- localfoods %>%
  filter(COUNTY %in% c("Edgecombe", "Halifax", "Nash", "Northampton", "Wilson"))
plot(UP_localfoods["geometry"])

# check CRS
st_crs(UP_localfoods) # no CRS

# transform CRS
UP_localfoods <- st_set_crs(UP_localfoods, 2264)
plot(UP_localfoods["geometry"])

# write shapefile
st_write(UP_localfoods, "UP_localfoods.shp")

##### CREATE MAPS #####

# view unique categories
unique(UP_localfoods$CATEGORY)

# ALL Categories
localfoodsMap <- 
  tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(integrity_subset) + # USDA certified organic operations
  tm_bubbles(col = "purple", size = .3, alpha = 0.6,
             popup.vars = c("Name" = "Name",
                            "Certifier" = "Certifier",
                            "Address" = "addresses",
                            "County" = "CountyName"
             )) +
  tm_shape(UP_localfoods) +
  tm_bubbles("CATEGORY", size = .5, alpha = 0.7,
             popup.vars=c("Category"="CATEGORY", 
                          "Name"="NAME",
                          "City"="CITY",
                          "County" = "COUNTY")) +
  tm_add_legend(type = "fill", 
                labels = "Organic Operations",
                shape = "bubble",
                col = "purple", alpha = 0.6) +
  tm_layout(frame = FALSE)

localfoodsMap

# food infrastructure, no organic 
tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(UP_localfoods) +
  tm_bubbles("CATEGORY", size = .5, alpha = 0.7,
             popup.vars=c("Category"="CATEGORY", 
                          "Name"="NAME",
                          "City"="CITY",
                          "County" = "COUNTY")) +
  tm_layout(frame = FALSE)

# dairy
dairy <- 
  UP_localfoods %>%
  filter(CATEGORY == "Dairy Processing/Cheeses")
dairyMap <- 
tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(dairyprocessing) +
  tm_bubbles("CATEGORY", size = .5, alpha = 0.7,
             popup.vars=c("Category"="CATEGORY", 
                          "Name"="NAME",
                          "City"="CITY",
                          "County" = "COUNTY")) +
  tm_layout(frame = FALSE)

# fruit and veg processing
fvprocessing <- 
  UP_localfoods %>%
  filter(CATEGORY == "F&V Processing")
fvprocessingMap <- 
  tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(fvprocessing) +
  tm_bubbles("CATEGORY", size = .5, alpha = 0.7,
             popup.vars=c("Category"="CATEGORY", 
                          "Name"="NAME",
                          "City"="CITY",
                          "County" = "COUNTY")) +
  tm_layout(frame = FALSE)

# fruit and veg wholesale & distribution
fvwd <- 
  UP_localfoods %>%
  filter(CATEGORY == "F&V W/D")
fvwdMap <- 
  tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(fvwd) +
  tm_bubbles("CATEGORY", size = .5, alpha = 0.7,
             popup.vars=c("Category"="CATEGORY", 
                          "Name"="NAME",
                          "City"="CITY",
                          "County" = "COUNTY")) +
  tm_layout(frame = FALSE)

# farmers markets
farmersmarket <- 
  UP_localfoods %>%
  filter(CATEGORY == "Farmers Market")
farmersmarketMap <- 
  tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(farmersmarket) +
  tm_bubbles("CATEGORY", size = .5, alpha = 0.7,
             popup.vars=c("Category"="CATEGORY", 
                          "Name"="NAME",
                          "City"="CITY",
                          "County" = "COUNTY")) +
  tm_layout(frame = FALSE)

# meat processing
meat <- 
  UP_localfoods %>%
  filter(CATEGORY == "Meat Processing")
meatMap <-   
  tm_shape(UP_counties) +
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(meat) +
  tm_bubbles("CATEGORY", size = .5, alpha = 0.7,
             popup.vars=c("Category"="CATEGORY", 
                          "Name"="NAME",
                          "City"="CITY",
                          "County" = "COUNTY")) +
  tm_layout(frame = FALSE)
meatMap
