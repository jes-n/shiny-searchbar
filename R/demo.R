demos = list(
  "basic" = "basic-demo",
  "overflow" = "overflow-demo",
  "gallery" = "gallery-demo"
)

#' Demo
#' 
#' Run a demo.
#'
#' @import shiny
demo <- function(name="gallery", port=6169, ...) {
  if (!(name %in% names(demos))) {
    stop(sprintf("Invalid demo `%s`, available demos include: %s", name, paste(names(demos), collapse=" ")))
  }

  shiny::runApp(
    system.file(
      file.path("demo", demos[[name]]),
      package="shinySearchbar", 
      mustWork=TRUE
    ), 
    port=port, ...
  )
}
