shinyUI <- 
    dashboardPage(
        dashboardHeader
        (
            title = "NYC Airbnb"
        ),
        
        dashboardSidebar
        (
            sidebarMenu
            (
                menuItem
                (
                    "Listings", 
                    tabName = "listings", 
                    icon = icon("bed")
                ),
                
                menuItem
                (
                    "Statistics", 
                    tabName = "stats", 
                    icon = icon("chart-bar")
                ),
                
                menuItem
                (
                    "Comparison", 
                    tabName = "comparison", 
                    icon = icon("chart-line")
                )
            )
        ),
        
        dashboardBody
        (
            tabItems
            (
                # First tab with main map and plots of airbnb and subways
                tabItem
                (
                    tabName = "listings",
                    
                    fluidRow
                    (
                        box
                        (
                            leafletOutput("map"),
                            width = 8
                        ),
                        
                        box
                        (
                            title = "Filters",
                            
                            # multi select checkbox for neighborhood groups
                            # choices_nbg are all unique values for neigborhood groups
                            # choices are defaulted to all choices
                            checkboxGroupInput
                            (
                                inputId = "cb_neighbourhood_group", 
                                label = "Borough:",
                                choices = choices_nbg,
                                selected = choices_nbg
                            ),
                            
                            # multi select checkbox for room type
                            # choices_rmtype are all unique values for room type
                            # choices are defaulted to all choices
                            checkboxGroupInput
                            (
                                inputId = "cb_room_type", 
                                label = "Room Type:",
                                choices = choices_rmtype,
                                selected = choices_rmtype
                            ),
                            
                            # slider for the price range
                            # slider limited to 0 - 1000$ only airbnbs that are over 1000$ have been excluded
                            sliderInput
                            (
                                inputId = "sli_price",
                                label = "Price", min = 0, max = 1000,
                                value = c(0, 1000, 100)
                                
                            ),
                            
                            width = 4
                        )
                    )
                ),
                
                # Basic stats tab
                tabItem
                (
                    tabName = "stats",
                    fluidRow
                    (
                        # Static valueBoxes for whole dataset
                        valueBox(airbnb_stats$count, "Listings", icon = icon("bed"), color = "blue", width = 3),
                        valueBox(paste0("$", format(round(airbnb_stats$avg_price, 2), nsmall = 2)), "Average Price", icon = icon("dollar-sign"), color = "purple", width = 3),
                        valueBox(paste0("$", airbnb_stats$lowest_price), "Lowest Price", icon = icon("dollar-sign"), color = "green", width = 3),
                        valueBox(paste0("$", airbnb_stats$highest_price), "Highest Price", icon = icon("dollar-sign"), color = "orange", width = 3)
                    ),
                    
                    fluidRow
                    (  
                        infoBox("% of Brooklyn and Manhattan Listings", paste0(format(round(sum(info_nbg$pct_count) * 100, 2), nsmall = 1), "%")),
                        infoBox("% of Entire home/apartment Listings", paste0(format(round(info_roomtype$pct_count * 100, 2), nsmall = 1), "%"))
                    ),
                    
                    fluidRow
                    (
                        # Put a little margin on the sides
                        column
                        (
                            width = 5,
                            offset = 1,
                            plotOutput("bar_nbg")
                        ),
                        
                        # Put a little margin on the sides
                        column
                        (
                            width = 5,
                            plotOutput("bar_rmtype")
                        )
                    )
                    
                    #fluidRow
                    #(
                    #    column
                    #    (
                    #        width = 6,
                    #        # Static valueBoxes dataset grouped by neighbourhood_group
                    #        #valueBox(airbnb_by_nbg$count, "Listings", icon = icon("bed"), color = "blue", width = 3),
                    #        infoBox(paste0("$", format(round(airbnb_by_nbg$avg_price, 2), nsmall = 2)), "Average Price", icon = icon("dollar-sign"), color = "purple", width = 4),
                    #        infoBox(paste0("$", airbnb_by_nbg$lowest_price), "Lowest Price", icon = icon("dollar-sign"), color = "green", width = 4),
                    #        infoBox(paste0("$", airbnb_by_nbg$highest_price), "Highest Price", icon = icon("dollar-sign"), color = "orange", width = 4)
                    #    ),
                    #    
                    #    column
                    #    (
                    #        width = 6,
                    #        # Static valueBoxes dataset grouped by neighbourhood_group and room type
                    #        #valueBox(airbnb_by_nbg_roomtype$count, "Listings", icon = icon("bed"), color = "blue", width = 3),
                    #        infoBox(paste0("$", format(round(airbnb_by_nbg_roomtype$avg_price, 2), nsmall = 2)), "Average Price", icon = icon("dollar-sign"), color = "purple"),
                    #        infoBox(paste0("$", airbnb_by_nbg_roomtype$lowest_price), "Lowest Price", icon = icon("dollar-sign"), color = "green"),
                    #        infoBox(paste0("$", airbnb_by_nbg_roomtype$highest_price), "Highest Price", icon = icon("dollar-sign"), color = "orange")
                    #    )
                    #)
                ),
                
                # Price vs distance to subway tab
                tabItem
                (
                    tabName = "comparison",
                    plotOutput("scatter")
                )
            )
        )
    )