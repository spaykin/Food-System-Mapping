##############################################
##### COMMUNITY / DEMOGRAPHIC / SES Data #####
##############################################

# load libraries
library(sf)
library(tidyverse)
library(readr)
# visualization packages
library(tmap)
library(leaflet)

# Population
popMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "Population", alpha = 0.8, palette = "BuGn") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)
popMap

            
# "% Free or Reduced Lunch"
lunchMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "% Free or Reduced Lunch", alpha = 0.8, palette = "BuGn") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)

# "Household Income" Map
incomeMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "Household Income", alpha = 0.8, palette = "BuGn") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE, 
            title = "Household Median Income")


# "% Severe Housing Cost Burden" 
housingcostMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "% Severe Housing Cost Burden", alpha = 0.8, palette = "BuGn") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)

# "Segregation index"
segregationMap <- 
  tm_shape(health_merge) +
  tm_borders(col = "black", lw = 0.2) +
  tm_fill(col = "Segregation Index", alpha = 0.8, palette = "BuGn") +
  tm_text(text = "NAME") +
  tm_layout(frame = FALSE)

