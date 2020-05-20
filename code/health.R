library(sf)
library(tidyverse)
library(readr)

# visualization packages
library(tmap)
library(leaflet)

#### County Health Rankings - categorical data

# load state county-level health data
library(readxl)
NC_health <- read_csv("Data/County Health/AdditionalMeasureData.csv", skip = 1)

# subset Upper Coastal Plain counties
health <- 
  NC_health %>%
  filter(County %in% c("Edgecombe", "Halifax", "Nash", "Northampton", "Wilson"))

# merge health data with county boundaries
health_merge <- merge(UP_counties, health, by.x = "CountyName", by.y = "County")
plot(health_merge["geometry"])

# check CRS
st_crs(health_merge)

# save health shapefile
st_write(health_merge, "Data/County Health/health.shp")

# basic health map
tmap_mode("view")

tm_shape(health_merge) +
  tm_borders() +
  tm_fill(col = "% Diabetic") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE, title = "Upper Coastal Plain, North Carolina",
            title.position = c("center", "TOP"))


