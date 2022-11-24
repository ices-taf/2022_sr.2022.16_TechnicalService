#' ICES Data Disclaimer
#'
#' ICES Data Disclaimer for special requests, a template is modified
#' to create a specific disclaimer for this product
#'
#' @name disclaimer
#' @format txt file
#' @tafOriginator ICES
#' @tafYear 2020
#' @tafAccess Public
#' @tafSource script

# read correct disclaimer template
github_raw_url <- "https://raw.githubusercontent.com"
disclaimer_repo <- "ices-tools-prod/disclaimers"
disclaimer_tag <- "1adaffbbe80ae8b155ff557cfa7ecc996c25308f"
disclaimer_fname <- "disclaimer_vms_data_ouput.txt"

disclaimer_url <-
  paste(
    github_raw_url,
    disclaimer_repo,
    disclaimer_tag,
    disclaimer_fname,
    sep = "/"
  )

disclaimer <- readLines(disclaimer_url)

# specific entries
data_specific <- "The zip file contains ESRI shapefiles and a geographic CSV with a well known text column.  The data provided are of hours fished and total landings, for pelagic and benthic gears, and swept area ratio values for the surface of the sea bed due to bottom contacting gears. Data is provided by year and quarter for 2013 to 2021.  The spatial extent of the data is the area of the Norwegian EEZ and international waters specified in the request, and the spatial resolution is 0.05 x 0.05 degrees."

recomended_citation <- "ICES. 2022. Norwegian special request on the production of spatial data layers of fishing in areas relevant to future extraction of deep sea minerals. In Report of the ICES Advisory Committee, 2022. ICES Advice 2022, sr.2022.16. https://doi.org/10.17895/ices.advice.10.17895"

metadata <- "https://doi.org/10.17895/ices.advice.10.17895"

# apply to sections
# data specific info
line <- grep("3. DATA SPECIFIC INFORMATION", disclaimer)
disclaimer <-
  c(
    disclaimer[1:line],
    data_specific,
    disclaimer[(line + 1):length(disclaimer)]
  )

# recomended citation
line <- grep("Recommended citation:", disclaimer)
disclaimer <-
  c(
    disclaimer[1:line],
    recomended_citation,
    disclaimer[(line + 1):length(disclaimer)]
  )

# metadata section
line <- grep("7. METADATA", disclaimer)
disclaimer <-
  c(
    disclaimer[1:(line)],
    paste0(disclaimer[line + 1], metadata)
  )

cat(disclaimer, file = "disclaimer.txt", sep = "\n")