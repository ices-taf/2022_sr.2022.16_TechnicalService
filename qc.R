
library(sf)
library(dplyr)
library(ggplot2)

intensity <-
  read_sf(
    file.path(
      "output",
      "intensity.shp"
    )
  )

intensity %>%
  ggplot(aes(gear_group, sur_sar)) +
  geom_violin() +
  scale_y_continuous(trans='log10')
