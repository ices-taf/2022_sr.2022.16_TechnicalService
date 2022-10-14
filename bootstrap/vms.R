#' VMS data from the ICES VMS and Logbook Database
#'
#' VMS data from the ICES VMS and Logbook Database
#'
#' @name vms
#' @format csv file
#' @tafOriginator ICES
#' @tafYear 2020
#' @tafAccess Restricted
#' @tafSource script

library(icesTAF)
library(icesVMS)
library(data.table)

# download
# note to access download a token for the current R session using
# update_token({ices username})

# to get all years (year = 0)
for (yr in 2013:2019) {
  msg("downloading vms for ", yr)
  fname <- paste0("vms_", yr, ".csv")
  if (!file.exists(fname)) {
    vms <- get_vms(year = yr)
    msg("saving ... ", yr)
    fwrite(vms, file = fname)
  }
}
