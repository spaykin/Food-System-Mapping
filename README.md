# Mapping Regional Food Systems
*Using geocomputation methods in R to map food and farm assets*
---------------------

## Authorship 
Susan Paykin, M.P.P., University of Chicago Harris School of Public Policy

Questions or comments can be directed to susan.paykin@gmail.com. 

Last updated: June 2020

## Overview
Understanding local and regional food systems is more important than ever. In light of the current pandemic, impacts of climate change, and economic forces interrupting global food supply chains, regions are investing in questions around how and where their communities’ food is grown and consumed. Food is not only linked to health implications, but farm and food activity can also be a significant player in the regional economic landscape. This project provides a framework for mapping food systems, centered around a case study using the Upper Coastal Plain region in northeastern North Carolina. 

The code was written in R using geocomputation techniques and methods. In addition to cleaning, geocoding, transforming and visualizing data as static and interactive maps, I also created a data dashboard using the Shiny package to allow users to explore the data in an interactive, accessible format. 

## Goals & Objectives

The goals and objectives of this project are to: 

* Improve understanding of local and regional food system, with a focus on access to healthy foods

* Use geocomputational methods and techniques in R to perform:

  * Asset Mapping: Identify current strengths and assets of the local and regional food system and agricultural value chain

  * Gap Analysis: Examine and describe the disparity between the current state of healthy food access and the desired future goal, and identify gaps where targeted investment would be most impactful

* Create R Shiny dashboard to share mapping and initial findings in a public-facing and accessible format

## Data Description

### NCDOT County Boundaries
*	**Description:** The NC State County Boundary GIS data set is to provide location information for the North Carolina State and County Boundary lines with best available information to facility at plan siting, impact analysis in the 100 counties of NC.
*	**Variables:**  NAME, ShapeSTAre, ShapeSTLen, geometry
* **Temporal Resolution:** none 
*	**Spatial Resolution:** counties: Edgecombe, Halifax, Nash, Northhampton, Wilson
*	**File format**: .shp
*	**Source:** North Carolina County Boundaries, 2018 - North Carolina Department of Transportation / NC Geodetic Survey. Available at https://www.arcgis.com/home/item.html?id=d192da4d0ac249fa9584109b1d626286 (accessed May 15, 2020). NCDOT. 

### USDA NASS Cropland Data Layer
* **Description:** The Cropland Data Layer (CDL) is a raster, geo-referenced crop-specific land cover data layer created annually for the U.S. using moderate resolution satellite imagery and extensive agricultural ground truth. According to USDA, the purpose of the Cropland Data Layer Program is to use satellite imagery to provide acreage estimates to the Agricultural Statistics Board for major commodities and to produce digital, crop-specific, categorized geo-referenced output products.
*	**Variables:** crop types
*	**Temporal Resolution:** year – 2019 
*	**Spatial Resolution:** raster, cropped to area of counties of focus
*	**File format:** .tif 
*	**Source:** USDA National Agricultural Statistics Service Cropland Data Layer. 2019.  Published crop-specific data layer [Online]. Available at https://nassgeodata.gmu.edu/CropScape/ (accessed May 15, 2020). USDA-NASS, Washington, DC.

### USDA Organic Integrity Database 
*	**Description:** List of all USDA certified organic operations (farms, processors, distributors, handlers and more). 
*	**Variables:
  * Operation Name
  * Organic Certification Status
  * Addresses
* **Temporal Resolution:** year – 2019 
* **Spatial Resolution:** address, zip code
* **File format:** .csv
* **Source:** USDA Agricultural Marketing Service. (2018). The Organic INTEGRITY Database. USDA Agricultural Marketing Service. https://data.nal.usda.gov/dataset/organic-integrity-database. Accessed May 20, 2020. 

### North Carolina Rankings Data, County Health Rankings (Robert Wood Johnson Foundation)
*	**Description**: The annual Rankings provide a snapshot of how health is influenced by where people live, work and play. This dataset contains measures and ranks of the health outcomes of residents in North Carolina counties’, from clinical care to social and economic factors to health factors and more. 
* **Variables** ([full 2019 Data Dictionary])(https://www.countyhealthrankings.org/sites/default/files/DataDictionary_2019.pdf):
  * countycode – county FIPS code 
  * county – county name 
  * v060_rawvalue – diabetes prevalence raw value
  * v005_rawvalue – preventable hospital stays raw value 
  * v139_rawvalue – food insecurity raw value
  * v083_rawvalue – limited access to healthy foods raw value
  * v063_rawvalue – median household income raw value
  * v065_rawvalue – children eligible for free or reduced price lunch raw value
* **Temporal Resolution:** year – 2019 
* **Spatial Resolution:** counties
* **File format:** .csv
* **Source:** Robert Wood Johnson Foundation, County Health Rankings and Roadmaps, North Carolina Rankings Data. (2019). https://www.countyhealthrankings.org/app/north-carolina/2018/downloads Accessed May 20, 2020. 

### NC Local Foods Infrastructure Inventory Map
*  **Description:** The NC Local Foods Infrastructure Inventory maps inventory of businesses that serve as intermediary steps in local food supply chains. This includes value-added processors, fresh produce wholesalers/distributors/ multi-farm CSAs, food hubs, community kitchens, incubator farms, and cold storage facilities. It does not include information on end retailers (e.g. restaurants, grocery stores, etc).  
* **Variables**:
  * COUNTY
  * CATEGORY 
  * NAME
* **Temporal Resolution:** none (year captured – 2017)
* **Spatial Resolution:** counties
* **File format:** .csv --> .shp (merged with county boundaries dataset)
* **Source:** North Carolina Growing Together Project, NC Local Food Infrastructure Inventory. (2017). https://www.arcgis.com/apps/webappviewer/index.html?id=f62735865c1c4d0f83ad40baeb66d864 Accessed May 20, 2020. 


## Future Work

Future work on this project will include: 

*	Add additional data layers: USDA Agricultural Census, food retail landscape, higher resolution boundaries (i.e. towns, census tracts) and health data

* Refine R Shiny dashboard design: add HTML elements to improve user experience and format

* Improve raster interactivity in the Shiny dashboard and perform additional analysis on USDA Cropland data to further explore agricultural production and outputs

* Identify gaps in regional food system and opportunities to strengthen local food production and healthy food access

* Create code template to be used to examine a variety of regional food systems, perhaps focused on US major city metropolitan area, or expanding on state-wide regions, i.e. North Carolina Council of Government (COG) regions
