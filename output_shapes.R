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
  vms_output %>%
    rename(
      kwfhr = "kw_fishinghours",
      sar = "surface_sar",
    ) %>%
    st_write(
      file.path("output", paste0("fishing_effort_", yr, ".shp")),
      append = FALSE
    )
}

