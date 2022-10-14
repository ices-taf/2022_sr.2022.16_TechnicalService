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

sourceTAF("report_zip.R")

message('\nRun:\n TAF::sourceTAF("shiny"); shiny::runApp("shiny")\n\n to run the shiny app.')
