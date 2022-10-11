## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)
library(data.table)
library(icesVMS)
library(sfdSAR)
library(dplyr)
library(ggplot2)
library(sf)
library(sfdSAR)

mkdir("data")

vms <- fread("data/vms_subsets.csv")

# get sar variables
gear_widths <- read.taf(taf.data.path("gear_widths", "gear_widths.csv"))

vms <-
  vms %>%
  left_join(gear_widths, by = c("benthisMetiers" = "benthisMet")) %>%
  rename(
    avg_oal = "avgOal", avg_kw = "avgKw", a = "firstFactor", b = "secondFactor"
  )

# calculate the gear width model
vms$gearWidth_model <-
  predict_gear_width(vms$gearModel, vms$gearCoefficient, vms)

# do the fillin for gear width:

# select provided average gear width, then modelled gear with, then benthis
# average if no kw or aol supplied
vms$gearWidth_filled <-
  with(
    vms,
    ifelse(!is.na(avgGearWidth) & avgGearWidth > 0, avgGearWidth / 1000,
      ifelse(!is.na(gearWidth_model), gearWidth_model / 1000,
        gearWidth
      )
    )
  )

# calculate surface contact
vms$surface <-
  predict_surface_contact(
    vms$contactModel,
    vms$fishingHours,
    vms$gearWidth_filled,
    vms$avgFishingSpeed
  )

# calculate subsurface contact
vms$subsurface <- vms$surface * as.numeric(vms$subsurfaceProp) * .01

# get csquare area
vms$c_square_area <- csquare_area(vms$c_square)

# calculate SAR
vms$surface_sar <- vms$surface / vms$c_square_area
vms$subsurface_sar <- vms$subsurface / vms$c_square_area

# write out for model section
fwrite(
  vms %>%
  select(-id, -importDate, -recordtype),
  file = "data/vms_complete.csv"
)
