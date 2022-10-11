
unlink("zip", recursive = TRUE)
mkdir("zip")

# zip up
shp_files <- dir("output")
zip(
  "zip/shapefiles.zip",
  file.path("output", shp_files),
  extras = "-j"
)

# zip up
#files <- dir("report", full = TRUE, pattern = "*.png")               
#zip(file.path("zip", "maps.zip", files)

# zip up
files <-
  c(
#    "zip/maps.zip",
    "zip/shapefiles.zip"
  )

zip(
  file.path("zip", "wgsfd-data-review-files.zip"),
  files,
  extras = "-j"
)
