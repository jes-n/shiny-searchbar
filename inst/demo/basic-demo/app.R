library(shiny)
library(shinySearchbar)

lorem <- shinySearchbar:::lorem
addtext <- function(lines, addition="shinySearchbar") {
  paste(lapply(strsplit(lines, "\\. "), paste, collapse=sprintf(" %s. ", addition)), collapse="\n\n")
}

ui <- shinyUI(
  pageWithSidebar(
    headerPanel("Basic Shiny Searchbar Example"),

    sidebarPanel(
      searchbar("searchbar", context="text", placeholder="Search text here..."),

      tags$div(
        tags$label("Result:"),
        verbatimTextOutput("result")
      ),

      tags$hr(),
      helpText(HTML(paste(
        "Shiny-Searchbar is tied to an element containing text using the `context` argument.",
        "<br><br>",
        "In this case, it is applied to the textOutput element with id=\"text\", defined in ui.R.",
        sep=""
      )))
    ),

    mainPanel(
      textOutput("text",
        container=function(...) tags$div(..., style="white-space: pre-line;")
      )
    )
  )
)

server <- function(input, output) {
  output$text <- renderText(addtext(lorem))

  output$result <- renderPrint({
    str(input$searchbar)
  })
}

shinyApp(ui, server)