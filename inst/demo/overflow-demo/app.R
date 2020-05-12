library(shiny)
library(shinySearchbar)

ui <- shinyUI(
  pageWithSidebar(
    headerPanel("Overflow Shiny Searchbar Example"),

    sidebarPanel(
      tags$h4("Automatic Scrolling"),
      helpText(HTML(sprintf(
        "With the %s option enable, the searchbar can cycle between and automatically scroll to each match. Scrolling is done in both the x- and y-overflow.",
        tags$i("cycler")
      ))),

      searchbar("searchbar", context="text", placeholder="Try searching for 'shinySearchbar'",
        cycler=TRUE, scrollBehavior="smooth"
      ),

      tags$hr(),
      tags$div(
        tags$label("Result:"),
        verbatimTextOutput("result")
      )      
    ),

    mainPanel(
      textOutput("text",
        container=function(...) tags$div(..., style="border: 1px solid #ccc; white-space: pre; max-height: 350px; overflow: scroll;")
      )
    )
  )
)

lorem <- shinySearchbar:::lorem
addtext <- function(lines, addition="shinySearchbar") {
  paste(lapply(strsplit(lines, "\\. "), paste, collapse=sprintf(" %s. ", addition)), collapse="\n\n")
}

server <- function(input, output) {
  output$text <- renderText(addtext(lorem))

  output$result <- renderPrint({
    str(input$searchbar)
  })
}

shinyApp(ui, server)