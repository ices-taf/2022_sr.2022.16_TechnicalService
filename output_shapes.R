## Extract results of interest, write TAF output tables

## Before:
## After:

library(icesTAF)
library(tidyr)
library(dplyr)
library(sf)

mkdir("output")

for (yr in 2013:2019) {
  msg("doing ", yr)
  load(paste0("model/output_", yr, ".RData"))

  # output shape
  vms_output <- 
    vms_output %>%
      rename(
        fhr = "fishinghours",
        fhr_c = "fishinghours_cat",
        fhr_cl = "fishinghours_cat_low",
        fhr_ch = "fishinghours_cat_high",
        totwt = "totweight",
        totwt_c = "totweight_cat",
        totwt_cl = "totweight_cat_low",
        totwt_ch = "totweight_cat_high",
        sar = "surface_sar"
      )

  st_write(
    vms_output,
    file.path("output", paste0("fishing_effort_", yr, ".shp")),
    append = FALSE
  )

  st_write(
    vms_output,
    file.path("output", "fishing_effort.csv"),
    layer_options = "GEOMETRY=AS_WKT",
    append = TRUE
  )
}
