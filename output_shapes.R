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
      kwfhr_c = "kw_fishinghours_cat",
      kwfhr_cl = "kw_fishinghours_cat_low",
      kwfhr_ch = "kw_fishinghours_cat_high",
      totwt = "totweight",
      totwt_c = "totweight_cat",
      totwt_cl = "totweight_cat_low",
      totwt_ch = "totweight_cat_high",
      sar = "surface_sar",
    ) %>%
    st_write(
      file.path("output", paste0("fishing_effort_", yr, ".shp")),
      append = FALSE
    )
}
