## Prepare plots and tables for report

## Before:
## After:

library(icesTAF)
library(tmap)
library(dplyr)
library(sf)
library(htmlwidgets)
library(tidyr)

mkdir("report")
mkdir("zip")

load("model/request.RData")

if (FALSE) {
  value <- "kw_fishinghours"
  igear <- "Purse_seines"
  iyear <- 2021
  iquarter <- 2
}


make_tmap <- function(data, value, igear, iyear, iquarter, fname = NULL) {

  if (is.null(fname)) {
    fname <- sprintf("%s-%s-%i-%i.png", igear, value, iyear, iquarter)
  }

  msg(igear, " ", iyear, " q", iquarter, " ", value)

  map_data <-
    data %>%
    filter(gear_group == igear & year == iyear & quarter == iquarter) %>%
    mutate(
      rounded_value =
        prettyNum(
          round(.[["value"]]),
          big.mark = ",", scientific = FALSE
        )
    ) %>%
    select(map_data, rounded_value, value)

  if (nrow(map_data) == 0) {
    return(NULL)
  }

  m <-
    tm_shape(map_data) +
    tm_polygons(value,
      style = "quantile",
      title = paste0(value, " \n", igear, " ", iyear, " q", iquarter)
    )

  tmap_save(m, fname)
  cp(fname, "report", move = TRUE)

  invisible(m)
}

# fishing effort
for (igear in unique(req_a$gear_group)) {
  for (iyear in 2021) {
    for (iquarter in 1:4) {
      fname <- sprintf("req_a_%s-%i-q%i.png", igear, iyear, iquarter)

      if (file.exists(file.path("report", fname))) {
        next
      }

      make_tmap(req_a, "kw_fishinghours", igear, iyear, iquarter, fname = fname)
    }
  }
}

# fishing intensity
for (igear in unique(req_b$gear_group)) {
  for (iyear in 2021) {
    for (iquarter in 1:4) {
      for (value in c("surface_sar", "subsurface_sar")) {
        fname <- sprintf("req_b_%s-%s-%i-q%i.png", igear, value, iyear, iquarter)

        if (file.exists(file.path("report", fname))) {
          next
        }

        make_tmap <- function(req_b, value, igear, iyear, iquarter, fname = fname)
      }
    }
  }
}
