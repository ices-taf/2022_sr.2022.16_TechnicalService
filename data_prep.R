library(icesTAF)
library(data.table)
library(dplyr)
library(icesVMS)

mkdir("data")

# get benthis lookup
metier_lookup <-
  get_metier_lookup() %>%
    tibble() %>%
    select(leMetLevel6, benthisMetiers)

# write out for posterity - should be in bootstrap
write.taf(metier_lookup, dir = "data")

# get vms (remember to run vms.R first)

vms_all <-
  lapply(
    dir(taf.data.path("vms"), full = TRUE),
    fread
  ) %>%
  do.call(what = "rbind")

vms_all <-
  vms_all %>%
  filter(country != "NO") %>% 
  rename(
    c_square = "cSquare", LE_MET_level6 = "leMetLevel6",
    AnonVessels = "anonVessels", UniqueVessels = "uniqueVessels",
    gear_code = "gearCode", vessel_length_category = "vesselLengthCategory"
  )

dim(vms_all)

# join and filter
vms <-
  vms_all %>%
  filter(!is.na(c_square)) %>% 
  left_join(
    metier_lookup,
    by = c(LE_MET_level6 = "leMetLevel6")
  )

# maybe have a vms_clean...

# set to 3
vms$AnonVessels[is.na(vms$UniqueVessels)] <- ""
vms$UniqueVessels[is.na(vms$UniqueVessels)] <- 3

fwrite(vms, file = "data/vms.csv")
