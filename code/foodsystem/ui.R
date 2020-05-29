library(shiny)
library(leaflet)
library(spData)
library(tidyverse)
library(tmap)
library(shinydashboard)
library(shinyWidgets)


ui <- 

fluidPage(
    
    setBackgroundColor(color = "lightgray"),
    
    titlePanel("Upper Coastal Plain, NC: Food System Map"),
    
    sidebarLayout(
        
        sidebarPanel(
    
            selectInput(
                "maps",
                h4("Explore Data:"),
                choices = c(
                    "Agricultural Value Chain",
                    "Health",
                    "Community",
                    "Cropland"
                )),
        
        conditionalPanel(
            condition = "input.maps == 'Agricultural Value Chain'",
            radioButtons("select_theme",
                               label = "",
                               choices = c("All",
                                            "Dairy Processing/Cheeses",
                                           "Fruit & Veg Processing",
                                           "Fruit & Veg Wholesale/Distribution",
                                           "Farmers Markets",
                                           "Meat Processing",
                                           "Certified Organic Operations"))),

            conditionalPanel(
                condition = "input.maps == 'Health'",
                radioButtons("select_health",
                                   label = "",
                                   choices = c("Diabetes", 
                                               "Food Insecurity",
                                               "Insurance Coverage",
                                               "Physical Distress",
                                               "Mental Distress"
                                               ))),

        conditionalPanel(
            condition = "input.maps == 'Community'",
            radioButtons("select_community",
                               label = "",
                               choices = c("Population", 
                                           "Household Income",
                                           "Housing Costs",
                                           "Free or Reduced Lunch",
                                           "Segregation"
                                           ))),

        conditionalPanel(
            condition = "input.maps == 'Cropland'",
            radioButtons("select_cropland",
                               label = "Cropland Data Layer",
                               choices = c("Leaflet", "Tmap"),
                        ),
            img(src="US_2019_CDL_legend.jpg", height = 500, width = 300)
            )
        
        ),
        
        
        mainPanel(
            
            conditionalPanel(
                condition = "input.maps == 'Agricultural Value Chain'",
                leafletOutput("mapValueChain")),
                
            conditionalPanel(
                condition = "input.maps == 'Health'", 
                leafletOutput("mapHealth")),
            
            conditionalPanel(
                condition = "input.maps == 'Community'", 
                leafletOutput("mapCommunity")),
            
            conditionalPanel(
                condition = "input.maps == 'Cropland'", 
                leafletOutput("mapCropland"),
                h2("Top 10 Crops by Acreage, 2019"),
                tableOutput("tableCropland")
            )
            
            
        )

    )
)

  