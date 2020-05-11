ui <- fluidPage(

  tags$head(
    tags$style(HTML("
      .control-label {
        font-size: smaller;
      }
    "))
  ),

  titlePanel("Shiny Searchbar Gallery"),

  tabsetPanel(
    tabPanel("Widget",
      examples$ui("examples")
    ),

    tabPanel("Options",
      configuration$ui("configuration")
    )
  )
)
