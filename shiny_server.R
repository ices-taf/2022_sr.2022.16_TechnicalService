
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

load(file.path("data", dir("data", pattern = "*.RData")[1]))
#load(file.path("model", dir("model", pattern = "*.RData")[1]))


server <- function(input, output, session) {
  getVMSData <- eventReactive( input$submit, {

    load(file.path("data", input$dataFile), envir = baseEnv)
    # possibly warn of object loaded is not called vms_output

    vms <- vms_output %>%
      filter(gear_group == input$dataGear) %>%
      mutate(value = as.numeric(.[[input$dataValue]])) %>%
      select(year, value)

    if (all(is.na(vms$value))) {
      return(NULL)
    }

    nlevs <- pmin(length(unique(vms$value)), as.integer(input$ncuts))
    
    if (nlevs == 1) {
      print(nlevs)
      print(unique(vms$value))
      return(NULL)
    }
    
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
    view_centre <- rowMeans(matrix(st_bbox(vms_output), 2, 2))
    
    leaflet() %>%
      # set view to europe
      leaflet::setView(view_centre[1], view_centre[2], zoom = 4) %>%
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
  
    if (!is.null(vmsData)) {

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
    } else {
      m <- leafletProxy("vmsMap") %>% clearShapes()
      
      m
    }
  })

  output$legend <- renderPlotly({
    vmsData <- getVMSData()
    
    if (!is.null(vmsData)) {
      
    trans <-
      switch(input$trans,
        identity = identity,
        log = exp,
        sqrt = function(x) x^2,
        "cuberoot" = function(x) x^3,
        "4throot" = function(x) x^4
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
    } else {
      ggplot()
    }
    
  })


  # year selecter; values based on those present in the dataset
  output$fileSelect <- renderUI({
    fileRange <- dir("data", pattern = "*.RData")
    selectInput("dataFile", "File", choices = fileRange, selected = fileRange[1])
  })

  output$gearSelect <- renderUI({

    gearRange <- sort(unique(vms_output$gear_group), decreasing = TRUE)

    selectInput("dataGear", "Gear", choices = gearRange, selected = gearRange[1])
  })
  
  output$valueSelect <- renderUI({
    valueRange = c(
      "kw_fishinghours", "fishinghours", "totweight",
      "totvalue", "surface", "subsurface", "surface_sar", "subsurface_sar",
      "anonymous"
    )
    
    # only select from columns that exist
    valueRange <- intersect(valueRange, names(vms_output))
    
    selectInput("dataValue", "Value", choices = valueRange, selected = valueRange[1])
  })
}