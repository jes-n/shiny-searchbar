server <- function(input, output) {
  output$text <- renderText({
    random_text(nwords = 500)
  })

  output$result <- renderPrint({
    str(input$searchbar)
  })
}
