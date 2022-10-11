
library(icesTAF)
library(data.table)
library(icesVMS)
library(sfdSAR)
library(dplyr)
library(ggplot2)
library(sf)

source("utilities.R")

mkdir("model")


for (yr in 2021:2009) {

if (file.exists(paste0("model/request_", yr, ".RData"))) next

try({
  msg("doing ", yr)
  vms <- fread("data/vms_complete.csv")

  vms <- vms %>% filter(year == yr)

  vms_output <-
    vms %>%
    filter(
        !is.na(gear_group) & gear_group != "" & c_square != "" & country != "NO"
    ) %>%
    mutate(quarter = ceiling(month / 12 * 4)) %>%
    group_by(year, quarter, gear_group, c_square) %>%
    vms_summarise() %>%
    select(
      year, quarter, c_square, gear_group, kw_fishinghours, surface_sar
    ) %>%
    vms_add_spatial()

  save(vms_output, file = paste0("model/output_", yr, ".RData"))
})

}
