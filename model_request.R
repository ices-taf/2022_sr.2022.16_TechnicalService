
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

  msg("doing request part a")
  req_a <-
    vms %>%
    filter(
      gear_group_a != "" & c_square != ""
    ) %>%
    group_by(year, gear_group_a, c_square) %>%
    vms_summarise() %>%
    select(
      year, c_square, gear_group_a, kw_fishinghours, anonymous
    ) %>%
    rename(
      gear_group = "gear_group_a"
    ) %>%
    group_by(
      gear_group
    ) %>%
    mutate(
      kw_fishinghours_cat = get_cat(kw_fishinghours),
      kw_fishinghours_cat_low = catlow(kw_fishinghours_cat),
      kw_fishinghours_cat_high = cathigh(kw_fishinghours_cat)
    ) %>%
    ungroup() %>%
    vms_add_spatial()


  msg("doing request part b")
  req_b0 <-
    vms %>%
    filter(
      !is.na(surface) & c_square != ""
    ) %>%
    group_by(year, c_square) %>%
    vms_summarise() %>%
    select(
      year, c_square, fishing_hours, kw_fishinghours, totweight, totvalue, surface, subsurface, surface_sar, subsurface_sar, anonymous
    ) %>%
    mutate(
      gear_group = "total"
    ) %>%
    vms_categorise_b()



  req_b1 <-
    vms %>%
    filter(
      !is.na(surface) & c_square != ""
    ) %>%
    group_by(year, gear_group_b, c_square) %>%
    vms_summarise() %>%
    select(
      year, c_square, fishing_hours, kw_fishinghours, totweight, totvalue, surface, subsurface, surface_sar, subsurface_sar, gear_group_b, anonymous
    ) %>%
    rename(
      gear_group = "gear_group_b"
    ) %>%
    vms_categorise_b()


  req_b <-
    rbind(req_b0, req_b1) %>%
    vms_add_spatial()

  save(req_a, req_b, file = paste0("model/request_", yr, ".RData"))
})

}
