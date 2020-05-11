library(shiny)
library(shinipsum)
library(shinySearchbar)

examples <- new.env()
sys.source("examples.R", envir=examples)

configuration <- new.env()
sys.source("configuration.R", envir=configuration)

#' Load internal lorem ipsum text
lorem <- shinySearchbar:::lorem

addtext <- function(lines, addition="shinySearchbar") {
  paste(lapply(strsplit(lines, "\\. "), paste, collapse=sprintf(" %s. ", addition)), collapse="\n\n")
}

ui <- fluidPage(
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="style.css")
  ),

  titlePanel("Shiny Searchbar Gallery"),

  tabsetPanel(
    tabPanel("Searchbar Widget", examples$ui("examples")),
    tabPanel("Configuration", configuration$ui("configuration"))
  )
)

server <- function(input, output) {
  callModule(examples$server, "examples")
  callModule(configuration$server, "configuration")
}

shinyApp(ui, server)