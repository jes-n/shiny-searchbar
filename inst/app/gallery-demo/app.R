library(shiny)
library(shinySearchbar)

examples <- new.env()
sys.source("examples.R", envir=examples)

configuration <- new.env()
sys.source("configuration.R", envir=configuration)

#' Load internal lorem ipsum text
lorem <- shinySearchbar:::lorem

#' Redefinition of shiny::tabsetPanel
#' 
#' Allows for additional 'nav-' class options by not forcing match.args().
#' See: https://getbootstrap.com/docs/3.4/components/#nav
tabsetPanel <- function(..., id=NULL, selected=NULL, type=c('tabs', 'pills')) {
  if (!is.null(id))
    selected <- restoreInput(id = id, default = selected)

  tabs <- list(...)
  type <- type # Removed match.args()

  tabset <- shiny:::buildTabset(tabs, paste0("nav nav-", type), NULL, id, selected)

  tags$div(class = "tabbable", tabset$navList, tabset$content)
}

addtext <- function(lines, addition="shinySearchbar") {
  paste(lapply(strsplit(lines, "\\. "), paste, collapse=sprintf(" %s. ", addition)), collapse="\n\n")
}

ui <- fluidPage(
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="style.css")
  ),

  titlePanel("Shiny Searchbar Gallery"),

  tabsetPanel(type="tabs nav-justified",
    tabPanel("Searchbar Widget", examples$ui("examples")),
    tabPanel("Configuration", configuration$ui("configuration"))
  )
)

server <- function(input, output) {
  callModule(examples$server, "examples")
  callModule(configuration$server, "configuration")
}

shinyApp(ui, server)