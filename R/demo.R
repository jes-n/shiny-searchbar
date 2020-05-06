#' Demo
#' 
#' Run a demo.
#' 
#' @export
demo <- function(){
  shiny::runApp(
    system.file("demo/basic-demo/", package = "shinySearchbar", 
      mustWork = TRUE
    ), 
    display.mode = "showcase", port=6169
  )
}
