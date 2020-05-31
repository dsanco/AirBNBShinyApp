library(dplyr)
library(geosphere)

############### RETRIEVE DATA FROM CSV FILES ###############

# Airbnb data
airbnb = read.csv("AB_NYC_2019.csv", header = TRUE, stringsAsFactors = FALSE)

# NYC Subways
subways = read.csv("NYCSubways.csv", header = TRUE, stringsAsFactors = FALSE)

############################################################

############### BEGIN ARIRBNB DATASET CLEANUP ###############

# Take off data with price over 1000$ 
# Add price range column

airbnb <- airbnb %>%
  filter(price > 0 & price < 1001) %>% 
  mutate
(
  airbnb$p_range = case_when
  (
    airbnb$price >= 0 & airbnb$price < 201 ~ "1 - 200",
    airbnb$price >= 201 & airbnb$price < 401~ "201 - 400",
    airbnb$price >= 401 & airbnb$price < 601~ "401 - 600",
    airbnb$price >= 601 & airbnb$price < 801~ "601 - 800",
    TRUE ~ "801 - 1000"
  )
)

# Define color range for prices
# This will be used by the legend and the circle markers on the map
colPal <- colorFactor(palette = "YlGnBu", levels = unique(airbnb$p_range))

############### END ARIRBNB DATASET CLEANUP ###############


############### BEGIN SUBWAY DATASET CLEANUP ###############

# Limit to columns needed
subways <- select(subways, 2:16)

# Convert columns to character, some were int 
subways$Route8 <- as.character(subways$Route8)
subways$Route9 <- as.character(subways$Route9)
subways$Route10 <- as.character(subways$Route10)
subways$Route11 <- as.character(subways$Route11)

# Replace na with blank
subways$Route8[is.na(subways$Route8)] <- ""
subways$Route9[is.na(subways$Route9)] <- ""
subways$Route10[is.na(subways$Route10)] <- ""
subways$Route11[is.na(subways$Route11)] <- ""

# Get unique rows in subways dataset
# Since I took off columns that were needed, some rows are completely identical
subways <- unique(subways)

# Columns to paste together
cols <- c('Route1', 'Route2', 'Route3', 'Route4', 'Route5', 'Route6',
          'Route7', 'Route8', 'Route9', 'Route10', 'Route11')

# Create a new column subway.line with the columns specified in cols
subways$subway.line <- apply( subways[,cols], 1, paste, collapse = " ")

# Remove white spaces
subways$subway.line <- trimws(subways$subway.line) 

# Remove the columns on the list since they have all been combined into one
subways <- subways[, !( names(subways) %in% cols)]

############### END SUBWAY DATASET CLEANUP ###############

write.csv(subways,'~/Desktop/DS_ANCO/R/Shiny Project/Anco_ShinyProject/Subways.csv', row.names = TRUE)

############### BEGIN CLOSEST SUBWAY CALC ###############
#nrow(head(airbnb))
#nrow(airbnb)
#breakdown into segments, took too long
for(x in 1:nrow(airbnb))
{
  tempdis = 999999999999999;
  
  for(i in 1:nrow(subways))
  {
    calcdis <- distm(c(airbnb$longitude[x], airbnb$latitude[x]), c(subways$Station.Longitude[i], subways$Station.Latitude[i]), fun = distHaversine)
    
    #print(paste0("calcdis ", calcdis, " tempdis ", tempdis))
    
    if(calcdis < tempdis)
    {
      tempdis <- calcdis
      #airbnb$closest_subway_dis[x] <- calcdis
      
      #closest <- calcdis
      #subway <- subways$Station.Name[i]
      #print(paste0("new calcdis ", calcdis, " new tempdis ", tempdis))
    }
    airbnb$closest_subway_dis[x] <- tempdis
  }
  #print(paste0(airbnb$name[x], " ", airbnb$longitude[x], " ", airbnb$latitude[x]))
  #print(paste0("Closet Subway is ", subway, " distance is ", closest))
}

#for loop thru all airbnbs
#for loop thru all subway stops
#calculate distance between two points
#first distance save, then if second is smaller. save the second number else keep the first


############### END CLOSEST SUBWAY CALC ###############


write.csv(airbnb,'~/Desktop/DS_ANCO/R/Shiny Project/Anco_ShinyProject/Airbnb.csv', row.names = TRUE)

