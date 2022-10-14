library(shinydashboard)
library(leaflet)
library(DT)
library(plotly)


# user interface
ui <- function() {

  header <- dashboardHeader(title = "WGSFD data review 2022")

  body <- dashboardBody(
    tags$style(type = "text/css", "#vmsMap {height: calc(100vh - 120px) !important;}"),
    fluidRow(
      column(
        width = 8,
        box(
          width = NULL, solidHeader = TRUE,
          leafletOutput("vmsMap", height = "100%")
        )
      ),
      column(
        width = 4,
        box(
          width = NULL,
          plotlyOutput("legend")
        ),
        box(
          width = NULL,
          actionButton("submit", label = "Submit"),
          uiOutput("fileSelect"),
          uiOutput("gearSelect"),
          uiOutput("valueSelect"),
          splitLayout(
            cellWidths = c("50%", "50%"),
            selectInput("trans", "Transform", choices = c("sqrt", "cuberoot", "4throot", "log", "identity"), selected = "sqrt"),
            selectInput("ncuts", "No. categories", choices = 10:2, selected = 10)
          )
        )
      )
    )
  )

  dashboardPage(
    header,
    dashboardSidebar(disable = TRUE),
    body
  )
}