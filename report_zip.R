
# zip up
shp_files <- dir("output")
zip(
  "report/shapefiles.zip",
  file.path("output", shp_files),
  extras = "-j"
)
