
library(icesTAF)
library(data.table)
library(icesVMS)
library(sfdSAR)
library(dplyr)
library(ggplot2)
library(sf)

source("utilities.R")

mkdir("model")


for (yr in 2013:2019) {

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
      year, quarter, c_square, gear_group, fishinghours, totweight, surface_sar, anonymous
    ) %>%
    mutate(
      fishinghours_cat = get_cat(fishinghours),
      fishinghours_cat_low = catlow(fishinghours_cat),
      fishinghours_cat_high = cathigh(fishinghours_cat),
      fishinghours = replace(fishinghours, !anonymous, NA),
      totweight_cat = get_cat(totweight),
      totweight_cat_low = catlow(totweight_cat),
      totweight_cat_high = cathigh(totweight_cat),
      totweight = replace(totweight, !anonymous, NA)
    ) %>%
    vms_add_spatial()

  save(vms_output, file = paste0("model/output_", yr, ".RData"))
})

}
