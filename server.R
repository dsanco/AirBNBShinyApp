


shinyServer(function (input, output) {
    
    # Take inputs from filters: neighborhood groups, room type and price range
    map_react <- reactive({
        filtered_airbnb <- airbnb %>% dplyr::filter(room_type %in% input$cb_room_type & 
                                     neighbourhood_group %in% input$cb_neighbourhood_group &
                                     price >= input$sli_price[1] &
                                     price <= input$sli_price[2])
        return(filtered_airbnb)
    })
    
    # Create custom icons
    
    # use icon for 
    trainIcon <- makeIcon(
            iconUrl = "https://cdn2.iconfinder.com/data/icons/pittogrammi/142/14-512.png",
            iconWidth = 15, iconHeight = 15
        )
    
    # Plot static map
    output$map <- renderLeaflet({
        leaflet() %>% setView(lng = -73.98928, lat = 40.75042, zoom = 14) %>%
            addProviderTiles("CartoDB.Positron", layerId = "basetile", options = providerTileOptions(minZoom = 10))
    })
    
    # Replot every time the filters change
    observe(leafletProxy("map", data = map_react()) %>%
                clearMarkers() %>%
                clearControls() %>% 
                
                # Plot markers for Airbnb listings
                addCircleMarkers
                (
                    lng = ~longitude, 
                    lat = ~latitude,
                    radius = 3, 
                    stroke = FALSE, 
                    fillOpacity = 0.25,
                    color = ~colPal(p_range),
                    #color = ~getColor(map_react()),
                    # Popup content
                    popup = ~paste
                    (
                        "<b>", name, "</b><br/>",
                        as.character(room_type), "<br/>",
                        "Price: ", as.character(price), "$<br/>"
                    )
                ) %>% 
                
                # Plot markers for Subway stops
                addMarkers
                (
                    data = subways,
                    lng = ~Station.Longitude, 
                    lat = ~Station.Latitude,
                    popup = ~paste
                    (
                        "<b>", Station.Name, "</b><br/>",
                        "Line: ", as.character(subway.line), "<br/>"
                    ),
                    label = ~as.character(subway.line),
                    icon = trainIcon
                ) %>% 
            
                addLegend
                (
                    "bottomright", 
                    pal = colPal, 
                    values = ~p_range,
                    title = "Price Range",
                    opacity = 1
                )
        )
    
    # Plot barplot by neighbourhood_group
    output$bar_nbg <-renderPlot({
        ggplot(airbnb, aes(neighbourhood_group)) +
            geom_bar(aes(fill = room_type)) +
            labs(fill = "Room Type") + 
            xlab("Borough") +
            ylab("Count")
    })
    
    # Plot barplot by room_type
    output$bar_rmtype <-renderPlot({
        ggplot(airbnb, aes(room_type)) +
            geom_bar(aes(fill = neighbourhood_group)) +
            labs(fill = "Borough") + 
            xlab("Room Type") +
            ylab("Count")
    })
    
    # Plot scatter plot for relationship between price and distance
    output$scatter <-renderPlot({
        ggplot(airbnb, aes(x = price, y = closest_subway_dis)) +
            geom_point(aes(color = neighbourhood_group)) +
            labs(fill = "Borough") + 
            xlab("Price") +
            ylab("Closest Subway Distance(m)")
    })
})


# add legend or colors with pricing