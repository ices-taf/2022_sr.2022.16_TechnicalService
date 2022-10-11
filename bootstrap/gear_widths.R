#' Gear width table from VMS DB
#'
#' Gear width table
#'
#' @name gear_widths
#' @format csv file
#' @tafOriginator ICES
#' @tafYear 2020
#' @tafAccess Public
#' @tafSource script

library(icesTAF)
library(icesVMS)
library(dplyr)

gear_widths <- icesVMS::get_benthis_parameters() %>% select(-id)

write.taf(gear_widths)
