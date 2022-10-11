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

gear_groups <-
  list(
    a =
      list(
        Pelagic_trawls = c("OTM", "PTM"),
        Longlines = c("LL", "LLS", "LLD", "LX"),
        Traps = c("FPO", "FYK", "FPN"),
        Nets = c("GNS", "GTR", "GND", "GTN")
      )
  )

gear_group <- function(x) {
  out <- rep(names(x), sapply(x, length))
  names(out) <- unlist(x, use.names = FALSE)
  out
}

gear_group_a <- gear_group(gear_groups$a)

vms$gear_group_a <- unname(gear_group_a[vms$gear_code])
vms$gear_group_b <- vms$benthisMetiers

table(vms$gear_group_a)
table(vms$gear_group_b)

fwrite(vms, file = "data/vms_subsets.csv")
