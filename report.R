## Prepare plots and tables for report

## Before:
## After:

library(icesTAF)
library(tmap)
library(dplyr)
library(sf)
library(htmlwidgets)
library(tidyr)

mkdir("report")
mkdir("zip")

#sourceTAF("report_maps.R")

sourceTAF("report_zip.R")
