
library(dplyr)
library(tidyr)
library(leaflet)
library(rgdal)
library(DT)
library(sf)
library(shiny)
library(plotly)

# map layers
ices_layer <- "ICES areas"

baseEnv <- environment()


# preload somthing
load(paste0("data/request_2009.RData"))

server <- function(input, output, session) {
  getVMSData <- eventReactive( input$submit, {
    if (length(input$dataYear) == 0) {
      dataYear <- 2021
      dataGear <- "Traps"
      dataValue <- "kw_fishinghours"
    } else {
      dataYear <- input$dataYear
      dataGear <- input$dataGear
      dataValue <- input$value
    }

    load(paste0("data/request_", dataYear, ".RData"), envir = baseEnv)

    if (input$set == "Others") {
      vms <- req_a
    } else {
      vms <- req_b
    }

    vms <- vms %>%
      filter(gear_group == dataGear) %>%
      mutate(value = as.numeric(.[[dataValue]])) %>%
      select(year, value)

    nlevs <- pmin(length(unique(vms$value)), as.integer(input$ncuts))
    trans <-
      switch(input$trans,
        "4throot" = function(x) x^.25,
        cuberoot = function(x) x^(1 / 3),
        match.fun(input$trans)
      )
    
    vms$cats <- cut(trans(vms$value), nlevs)
    
    vms
  })

  # Due to use of leafletProxy below, this should only be called once
  output$vmsMap <- renderLeaflet({
    leaflet() %>%
      # set view to europe
      leaflet::setView(-4, 55, zoom = 4) %>%
      # esri ocean basemap
      addProviderTiles(providers$Esri.WorldImagery,
        options = providerTileOptions(opacity = 0.5)
      ) %>%
      addWMSTiles("http://gis.ices.dk/gis/services/ICES_reference_layers/ICES_Areas/MapServer/WMSServer?",
        layers = "0",
        options = WMSTileOptions(format = "image/png", transparent = TRUE, crs = "EPSG:4326"),
        attribution = "ICES, The GEBCO_2014 Grid, version 20150318, www.gebco.net.", group = ices_layer
      )
  })



  observe({
    vmsData <- getVMSData()

    # If the data changes, the polygons are cleared and redrawn, however, the map (above) is not redrawn
    m <- 
      leafletProxy("vmsMap", data = vmsData) %>%
      clearShapes() %>%
      addPolygons(
        data = vmsData %>% st_union(),
        fillColor = NULL,
        fillOpacity = 0,
        stroke = TRUE,
        color = "black",
        weight = 0.5,
        opacity = 1
      )

    colours <- viridisLite::viridis(nlevels(vmsData$cats))

    for (i in 1:nlevels(vmsData$cats)) {
      
      layerData <- vmsData %>% filter(cats == levels(vmsData$cats)[i])
      if (nrow(layerData) == 0) next
      
      m <-
        addPolygons(
          m,
          data = layerData %>% st_union(),
          fillColor = colours[i],
          fillOpacity = 0.7,
          stroke = FALSE
        )
    }
    
    m
  })

  output$legend <- renderPlotly({
    vmsData <- getVMSData()
    
    trans <-
      switch(input$trans,
        identity = identity,
        log = exp,
        sqrt = function(x) x^2,
        "cuberoot" = function(x) x^3,
        "4throot" = function(x) x^4
      )
    
    #
    vmsData <- req_b %>%
      filter(gear_group == "TBB_MOL") %>%
      tibble() %>%
      mutate(
        value = kw_fishinghours,
        cats = cut(value, 10)
      ) %>%
      select(
        value, year, cats
      )
    
    plotData <-
      vmsData %>%
      tibble() %>%
      filter(!is.na(value)) %>%
      count(
        cats,
        .drop = FALSE
      ) %>%
      rename(
        count = n
      ) %>%
      mutate(
        cat_lower = sapply(
          strsplit(
            gsub("[(]|[]]", "", levels(cats)),
            ","
          ),
          function(x) trans(as.numeric(x[1]))
        ),
        cat_upper = sapply(
          strsplit(
            gsub("[(]|[]]", "", levels(cats)),
            ","
          ),
          function(x) trans(as.numeric(x[2]))
        ),
        cat_width = cat_upper - cat_lower,
        categories = (cat_lower + cat_upper)/2,
        cats = paste(round(cat_lower, 1), "-", round(cat_upper, 1)),
        cats = factor(cats, levels = cats)
      )

    colours <- viridisLite::viridis(nlevels(plotData$cats))

    p <- ggplot(data = plotData, aes(x = categories, y = count, fill = cats, width = cat_width)) +
      geom_bar(stat = "identity") +
      scale_fill_manual(values = colours) +
      theme(axis.text.x = element_blank())

    ggplotly(p)
  })


  # year selecter; values based on those present in the dataset
  output$yearSelect <- renderUI({
    yearRange <- 2021:2009
    selectInput("dataYear", "Year", choices = yearRange, selected = yearRange[1])
  })

  output$gearSelect <- renderUI({
    if (input$set == "Others") {
      gearRange <- sort(unique(req_a$gear_group), decreasing = TRUE)
    } else {
      gearRange <- sort(unique(req_b$gear_group), decreasing = TRUE)
    }

    selectInput("dataGear", "Gear", choices = gearRange, selected = gearRange[1])
  })
  
  output$valueSelect <- renderUI({
    if (input$set == "Others") {
      valueRange = c("kw_fishinghours", "anonymous")
    } else {
      valueRange = c(
        "kw_fishinghours", "fishinghours", "totweight",
        "totvalue", "surface", "subsurface", "surface_sar", "subsurface_sar", 
        "anonymous"
      )
    }
    selectInput("value", "Value", choices = valueRange, selected = valueRange[1])
  })
}