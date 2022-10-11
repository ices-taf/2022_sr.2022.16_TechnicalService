


vms_summarise <- function(x) {
  x %>%
    summarise(
      fishing_hours = sum(fishingHours, na.rm = TRUE),
      kw_fishinghours = sum(kwFishinghours, na.rm = TRUE),
      totweight = sum(totweight, na.rm = TRUE),
      totvalue = sum(totvalue, na.rm = TRUE),
      surface = sum(surface, na.rm = TRUE),
      subsurface = sum(subsurface, na.rm = TRUE),
      surface_sar = sum(surface_sar, na.rm = TRUE),
      subsurface_sar = sum(subsurface_sar, na.rm = TRUE),
      UniqueVessels = sum_distinct_vessels(AnonVessels, UniqueVessels),
      AnonVessels = sum_vessel_ids(AnonVessels, UniqueVessels),
      .groups = "drop"
    ) %>%
    mutate(
      anonymous = UniqueVessels > 2
    ) %>%
    select(
      -UniqueVessels, -AnonVessels
    )
}


catlow <- function(x) {
  pmax(as.numeric(sapply(strsplit(gsub("[(]|[]]", "", x), ","), "[", 1)), 0)
}

cathigh <- function(x) {
  as.numeric(sapply(strsplit(gsub("[(]|[]]", "", x), ","), "[", 2))
}


vms_categorise_b <- function(x) {
  x %>%
    group_by(
      gear_group
    ) %>%
    mutate(
      kw_fishinghours_cat = get_cat(kw_fishinghours),
      kw_fishinghours_cat_low = catlow(kw_fishinghours_cat),
      kw_fishinghours_cat_high = cathigh(kw_fishinghours_cat),
      #kw_fishinghours = replace(kw_fishinghours, !anonymous, NA),

      totweight_cat = get_cat(totweight),
      totweight_cat_low = catlow(totweight_cat),
      totweight_cat_high = cathigh(totweight_cat),
      #totweight = replace(totweight, !anonymous, NA),

      totvalue_cat = get_cat(totvalue),
      totvalue_cat_low = catlow(totvalue_cat),
      totvalue_cat_high = cathigh(totvalue_cat),
      #totvalue = replace(totvalue, !anonymous, NA),

      fishing_hours_cat = get_cat(fishing_hours),
      fishing_hours_cat_low = catlow(fishing_hours_cat),
      fishing_hours_cat_high = cathigh(fishing_hours_cat),
      #fishing_hours = replace(fishing_hours, !anonymous, NA)
    ) %>%
    ungroup()
}

vms_add_spatial <- function(x) {
  x %>%
    group_by(
      c_square
    ) %>%
    mutate(
      lat = sfdSAR::csquare_lat(c_square),
      lon = sfdSAR::csquare_lon(c_square)
    ) %>%
    mutate(
      wkt = wkt_csquare(lat, lon)
    ) %>%
    ungroup() %>%
    st_as_sf(wkt = "wkt", crs = 4326)
}

get_cat <- function(x) {
  cuts <- min(floor(length(x) / 2), 10)
  if (cuts < 1) cuts <- 2
  as.character(cut(x, cuts))
}


if (FALSE) {
  value <- "kw_fishinghours"
  gear <- "DRB_MOL"
  year <- 2021
}


make_map <- function(value, gear, map_sf) {
  msg("doing: ", value, " - ", gear)

  map_data <-
    map_sf %>%
    filter(benthisMetiers == gear)

  # palatte
    rvalues <- range(map_data$value)
    pal <- colorNumeric("Spectral", rvalues,
      na.color = "transparent", reverse = TRUE
    )

  msg("  making map")
  m <-
    leaflet() %>%
    addProviderTiles(providers$Esri.OceanBasemap)

  # add layers

    m <- addPolygons(m, data = map_data)


  for (year in unique(map_data$year)) {
    m <- addRasterImage(m, rasts[[layer]], colors = pal, opacity = 0.8, group = rnames[[layer]])
  }

  # add legend
  m <- addLegend(m,
    pal = pal, values = rvalues,
    title = sprintf("%s (%s)", value, gear), opacity = .8,
    labFormat = labelFormat(transform = trans_inv)
  )

  # add controls
  m <- addLayersControl(m,
    baseGroups = rnames,
    options = layersControlOptions(collapsed = FALSE)
  )

  m <- addScaleBar(
    m,
    position = "bottomright",
    options = scaleBarOptions()
  )

  m
}
