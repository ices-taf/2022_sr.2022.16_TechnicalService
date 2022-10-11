## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)

mkdir("data")

sourceTAF("data_prep.R")

sourceTAF("data_subsets.R")

sourceTAF("data_sar_variables.R")

#sourceTAF("data_qc.R")
