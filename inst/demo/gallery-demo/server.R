server <- function(input, output) {
  callModule(examples$server, "examples")
  callModule(configuration$server, "configuration")
}
