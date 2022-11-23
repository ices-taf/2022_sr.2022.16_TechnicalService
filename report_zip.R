## Prepare plots and tables for report

## Before:
## After:

library(icesTAF)

mkdir("report")

# zip up with disclaimer, and advice document
files <-
  c(
#    taf.data.path("nor.2022.16.pdf"),
    taf.data.path("disclaimer", "disclaimer.txt"),
    "README.md",
    dir("output", full.names = TRUE)
  )

zip(
  file.path(
    "report",
    "ICES.2022.norwegian-SR-spatial-data-layers-of-fishing.zip"
  ),
  files,
  extras = "-j"
)
