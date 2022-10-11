## Collect data, web files, and create the shiny app

## Before:
## After:

library(TAF)
library(rmarkdown)

mkdir("shiny")

# create shiny app data folder
mkdir("shiny/data")

# copy in required data
cp("model/*", "shiny/data")

# copy over www folder
#mkdir("shiny/www")
#cp(taf.data.path("www"), "shiny")

# copy in server and ui scripts
cp("shiny_ui.R", "shiny/ui.R")
cp("shiny_server.R", "shiny/server.R")

msg("Created shiny app. To run, use: \n\n\trunApp('shiny')\n\n")
