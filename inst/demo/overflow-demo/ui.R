ui <- shinyUI(
  pageWithSidebar(
    headerPanel("Overflow Shiny Searchbar Example"),

    sidebarPanel(
      searchbar("searchbar", context="text", placeholder="Search text here...",
        cycler=TRUE
      ),

      tags$div(
        tags$label("Result:"),
        verbatimTextOutput("result")
      ),

      tags$hr(),
      helpText(HTML(paste(
        "The `cycler` option can automatically scroll to the currently selected keyword.",
        "<br><br>",
        "This div element uses:",
        "<br>",
        "style='max-height: 600px; overflow-y: scroll;'",
        sep=""
      )))
    ),

    mainPanel(
      textOutput("text",
        container=function(...) tags$div(..., style="max-height: 600px; overflow-y: scroll;")
      )
    )
  )
)
