library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(ggplot2)
library(geosphere)

############### RETRIEVE DATA FROM CSV FILES ###############

# Airbnb data
airbnb = read.csv("Airbnb.csv", header = TRUE, stringsAsFactors = FALSE)

# NYC Subways
subways = read.csv("Subways.csv", header = TRUE, stringsAsFactors = FALSE)

############################################################

############### START AIRBNB BASIC STATS ###############

# Full Dataset
airbnb_stats <- airbnb %>% 
  dplyr::summarise(count = n(), avg_price = mean(price), lowest_price = min(price), highest_price = max(price))

# Dataset grouped by neighbourhood_group
airbnb_by_nbg <- airbnb %>% 
  group_by(neighbourhood_group) %>% 
  dplyr::summarise(pct_count = n()/NROW(airbnb), count = n(), avg_price = mean(price), lowest_price = min(price), highest_price = max(price))

# Dataset grouped by room_type
airbnb_by_roomtype <- airbnb %>% 
  group_by(room_type) %>% 
  dplyr::summarise(pct_count = n()/NROW(airbnb), count = n(), avg_price = mean(price), lowest_price = min(price), highest_price = max(price))

# info stats
info_nbg <- filter(airbnb_by_nbg, neighbourhood_group == 'Brooklyn' | neighbourhood_group == 'Manhattan')
info_roomtype <- filter(airbnb_by_roomtype, room_type == 'Entire home/apt')

############### END AIRBNB BASIC STATS ###############


############### DEFINE CHOICES FOR CHECKBOX GROUPS ###############

# Unique choices for checkbox groups
choices_nbg = unique(airbnb$neighbourhood_group)
choices_rmtype = unique(airbnb$room_type)

# Values for slider
min_price = min(airbnb$price, na.rm=T)
max_price = max(airbnb$price, na.rm=T)

#################################################################