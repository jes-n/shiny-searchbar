ui <- shinyUI(
  pageWithSidebar(
    headerPanel("Shiny Searchbar Example using Cycler"),

    sidebarPanel(
      searchbar("searchbar", context="text", placeholder="Search text here...",
        cycler=TRUE
      ),

      tags$div(
        tags$label("Result:"),
        verbatimTextOutput("result")
      ),

      tags$hr(),
      helpText("The `cycler` option adds a next and previous button for cycling between all the matches.")
    ),

    mainPanel(
      textOutput("text")
    )
  )
)
