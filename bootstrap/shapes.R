#' Shapefiles for area of interest from Norway
#'
#' VMS data from the ICES VMS and Logbook Database
#'
#' @name shapes
#' @format csv file
#' @tafOriginator ICES
#' @tafYear 2020
#' @tafAccess Restricted
#' @tafSource script

library(icesTAF)
library(sf)
library(ggplot2)

unzip(
  taf.boot.path("initial", "data", "Area.zip"),
  junkpaths = TRUE,
  exdir = "temp"
)
shpfile <- dir("temp", pattern = "*.shp", full.names = TRUE)
area <- read_sf(shpfile)
unlink("temp", recursive = TRUE)

# drop depth
area <- st_zm(area, drop = TRUE)
# convert to wgs 84
area <- st_transform(area, crs = 4326)

st_write(area, "area.csv", layer_options = "GEOMETRY=AS_WKT")
