library(shiny)
library(leaflet)
library(leafem)
library(tidyverse)
library(tmap)
library(raster)
library(htmlwidgets)

shinyServer(function(input, output) {
    
    # output maps - Agricultural Value Chain
    output$mapValueChain <- renderLeaflet({
        if (input$select_theme == "All") {
            localfoodsMap <-
                tm_shape(UP_counties) +
                tm_borders() +
                tm_text(text = "CountyName") +
                tm_shape(integrity_subset) + # USDA certified organic operations
                tm_bubbles(
                    col = "purple",
                    size = .3,
                    alpha = 0.6,
                    popup.vars = c(
                        "Name" = "Name",
                        "Certifier" = "Certifier",
                        "Address" = "addresses",
                        "County" = "CountyName"
                    )
                ) +
                tm_shape(UP_localfoods) +
                tm_bubbles(
                    "CATEGORY",
                    size = .5,
                    alpha = 0.7,
                    popup.vars = c(
                        "Category" = "CATEGORY",
                        "Name" = "NAME",
                        "City" = "CITY",
                        "County" = "COUNTY"
                    )
                ) +
                tm_add_legend(
                    type = "fill",
                    labels = "Organic Operations",
                    shape = "bubble",
                    col = "purple",
                    alpha = 0.6
                ) +
                tm_layout(frame = FALSE)
            
            tmap_leaflet(localfoodsMap)
            
        } else if (input$select_theme == "Dairy Processing/Cheeses") {
            tmap_leaflet(dairyMap)
            
        } else if (input$select_theme == "Fruit & Veg Processing") {
            tmap_leaflet(fvprocessingMap)
            
        } else if (input$select_theme == "Fruit & Veg Wholesale/Distribution") {
            tmap_leaflet(fvwdMap)
            
        } else if (input$select_theme == "Farmers Markets") {
            tmap_leaflet(farmersmarketMap)
            
        } else if (input$select_theme == "Meat Processing") {
            tmap_leaflet(meatMap)
            
        } else if (input$select_theme == "Certified Organic Operations") {
            tmap_leaflet(organicMap)
        }
    })
    
    # output maps - Health Indicators
    output$mapHealth <- renderLeaflet({
        if (input$select_health == "Diabetes") {
            tmap_leaflet(diabetesMap)
            
        } else if (input$select_health == "Food Insecurity") {
            tmap_leaflet(foodinsecureMap)
            
        } else if (input$select_health == "Insurance Coverage") {
            tmap_leaflet(uninsuredMap)
            
        } else if (input$select_health == "Physical Distress") {
            tmap_leaflet(physicaldistressMap)
            
        } else if (input$select_health == "Mental Distress") {
            tmap_leaflet(mentaldistressMap)
        }
        
    })
    
    # output maps - Community
    output$mapCommunity <- renderLeaflet({
        if (input$select_community == "Population") {
            tmap_leaflet(popMap)
            
        } else if (input$select_community == "Household Income") {
            tmap_leaflet(incomeMap)
            
        } else if (input$select_community == "Housing Costs") {
            tmap_leaflet(housingcostMap)
            
        } else if (input$select_community == "Free or Reduced Lunch") {
            tmap_leaflet(lunchMap)
            
        } else if (input$select_community == "Segregation") {
            tmap_leaflet(segregationMap)
        }
    })
    
    
    # output maps - Cropland
    
    output$mapCropland <- renderLeaflet({
        if (input$select_cropland == "Leaflet") {
            croplandMapLeaflet
            
        } else if (input$select_cropland == "Tmap") {
            tmap_leaflet(croplandMap)
        }
    })
    
    # output table - Cropland
    
    output$tableCropland <-
        
        renderTable({
            topCrops
        })
    
})