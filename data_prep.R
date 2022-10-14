library(icesTAF)
library(data.table)
library(dplyr)
library(icesVMS)
library(sf)
library(ggplot2)

source("utilities.R")

mkdir("data")

metier_lookup <- read.taf(taf.data.path("metiers", "metier_lookup.csv"))

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

# load shape
bannana <- read_sf("bootstrap/data/shapes/area.csv", )
st_crs(bannana) <- 4326

c_squares <-
  tibble(
    c_square = unique(vms_all[["c_square"]])
  ) %>%
  vms_add_spatial()


ggplot() +
  geom_sf(data = c_squares) +
  geom_sf(data = bannana, fill = NA)

# spatial filter
int <- st_contains(bannana, c_squares, sparse = FALSE)
dim(int)
any(int)

c_squares_bananna <- c_squares[which(int),]

ggplot() +
  geom_sf(data = c_squares_bananna) +
  geom_sf(data = bannana, fill = NA)


# join and filter
vms <-
  vms_all %>%
  filter(c_square %in% c_squares_bananna$c_square) %>% 
  left_join(
    metier_lookup,
    by = c(LE_MET_level6 = "leMetLevel6")
  )

# maybe have a vms_clean...

# set to 3
vms$AnonVessels[is.na(vms$UniqueVessels)] <- ""
vms$UniqueVessels[is.na(vms$UniqueVessels)] <- 3

fwrite(vms, file = "data/vms.csv")
