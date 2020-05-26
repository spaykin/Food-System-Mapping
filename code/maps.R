library(sf)
library(tidyverse)
library(readr)
library(ggmap)
library(rgdal)
library(raster)

# visualization packages
library(tmap)
library(leaflet)
library(RColorBrewer)

tmap_mode("view")

test <- tm_shape(UP_counties) +               # county boundaries
  tm_borders() +
  tm_text(text = "CountyName") +
  tm_shape(UP_localfoods) +             # local food infrastructure
  tm_dots(col = "darkblue", size = .5) +
  tm_shape(UP_integrity) +              # USDA integrity
  tm_dots(col = "green", size = .2) +
  tm_layout(frame = FALSE)

test

test_diabetes <- 
  tm_shape(health_merge) +                # health
  tm_fill(col = "% Diabetic") +
  tm_text(text = "NAME") +
  tm_shape(UP_counties) +               # county boundaries
  tm_borders() +
  tm_shape(UP_localfoods) +             # local food infrastructure
  tm_dots(col = "darkblue", size = .5) +
  tm_shape(UP_integrity) +              # USDA integrity
  tm_dots(col = "green", size = .2) +
  tm_layout(frame = FALSE)

test_diabetes

# simple raster plot
tmap_mode("plot")
tmap_mode("view")

############################
###### CROPPED RASTER ######
############################

# cdl_subset
tm_shape(cdl_subset) +
  tm_raster(palette = colortable, legend.show = FALSE)

tm_shape(cdl_subset) +
  tm_raster("")





#### RASTER test with merged land cover data ######
tmap_mode("plot")


tm_shape(cdl_subset) +
  tm_raster("catCode.catCode") +
  tmap_options(max.raster = c(plot = 12083784, view = 12083784))


library(rasterVis)

levelplot(cdl_subset, 
          col.regions = rev(brewer.pal('BuPu')))

levelplot(cdl_subset,
          col.regions = cdl_subset$catCode)




###########################
###### MASKED RASTER ######
###########################

# plot masked raster
tm_shape(mask_cdl) +
  tm_raster(palette = colortable, 
            colorNA = "#ff000000")


testRaster1 <- tm_shape(mask_cdl, bbox = UP_counties) +
  tm_raster(colorNA = "#ff000000") +
    tm_shape(UP_counties) + 
    tm_borders() +
  tm_layout(frame = FALSE) +
  tmap_options(max.raster = c(plot = 17721954, view = 17721954))

testRaster1

testRaster2 <- tm_shape(mask_cdl) +
  tm_rgb() +
  tm_shape(UP_counties) + 
  tm_borders() +
  tm_layout(frame = FALSE) +
  tmap_options(max.raster = c(plot = 100000, view = 100000)) 

testRaster2

tmap_mode("view")
testRaster1
testRaster2

# testing plot vector plus raster!!!!
test + 
  tm_shape(mask_cdl) +
  tm_raster(alpha = 0.7)

test + 
  tm_shape(cdl_subset) +
  tm_raster(alpha = 0.7, legend.show = FALSE)
  
# interactive raster plot
tmap_mode("view")
tmap_mode("plot")

tm_shape(cdl_subset) +
  tm_raster(palette = colortable, alpha = 0.7, legend.show = FALSE, title = "USDA Cropland Data Layer")

tm_shape(mask_cdl) +
  tm_raster(alpha = 0.7, legend.show = FALSE, title = "USDA Cropland Data Layer")

tm_shape(crop_cdl) +
  tm_raster(alpha = .8) +
  tm_shape(UP_counties2) +
  tm_borders(col = "black")

