ui <- fluidPage(

  titlePanel("Shiny Searchbar Gallery"),

  tabsetPanel(
    tabPanel("Widget",
      examples$ui("examples")
    ),

    tabPanel("Options",
      textOutput("result-counter")
    )
  )
)
