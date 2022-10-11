#' Metier lookup table from VMS DB
#'
#' Metier lookup table
#'
#' @name metiers
#' @format csv file
#' @tafOriginator ICES
#' @tafYear 2020
#' @tafAccess Public
#' @tafSource script

library(icesTAF)
library(icesVMS)
library(dplyr)

# get benthis lookup
metier_lookup <-
  get_metier_lookup() %>%
  tibble() %>%
  select(leMetLevel6, benthisMetiers)

# write out for posterity - should be in bootstrap
write.taf(metier_lookup)
