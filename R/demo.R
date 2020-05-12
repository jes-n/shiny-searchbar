demos = list(
  "overflow" = "overflow-demo",
  "gallery" = "gallery-demo"
)

#' Shiny Searchbar Demos
#' 
#' Run one of the the shinySearchbar demos: "gallery" and "overflow".
#' 
#' @param name Name of the demo, either "gallery" or "overflow"
#' 
#' @examples
#' if (interactive()) {
#'   shinySearchbar:::demo("gallery")
#' }
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