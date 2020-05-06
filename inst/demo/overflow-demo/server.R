server <- function(input, output) {
  output$text <- renderText({
    random_text(nwords = 5000)
  })

  output$result <- renderPrint({
    str(input$searchbar)
  })
}
