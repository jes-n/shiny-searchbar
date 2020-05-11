library(shiny)
library(shinipsum)
library(shinySearchbar)

examples <- new.env()
sys.source("examples.R", envir=examples)

configuration <- new.env()
sys.source("configuration.R", envir=configuration)

#' Load internal lorem ipsum text
lorem <- shinySearchbar:::lorem

ui <- fluidPage(
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="style.css")
  ),

  titlePanel("Shiny Searchbar Gallery"),

  tabsetPanel(
    tabPanel("Searchbar Widget", examples$ui("examples")),
    tabPanel("Configurable Options", configuration$ui("configuration"))
  )
)

server <- function(input, output) {
  callModule(examples$server, "examples")
  callModule(configuration$server, "configuration")
}

shinyApp(ui, server)