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

mkdir("data")

vms <- fread("data/vms.csv")

# create a column for gear groupings
vms$gear_group <- NA_character_
vms$gear_group[vms$gear_code %in% c("OTM", "PTM")] <- "pelagic"
vms$gear_group[!is.na(vms$benthisMetiers) & vms$benthisMetiers != ""] <- "benthic"

table(vms$gear_group)

fwrite(vms, file = "data/vms_subsets.csv")
