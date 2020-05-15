demos = list(
  "overflow" = "overflow-demo",
  "gallery" = "gallery-demo"
)

#' Shiny Searchbar Demos
#' 
#' Run one of the the shinySearchbar demos: "gallery" and "overflow".
#' 
#' @param name Name of the demo, either "gallery" or "overflow".
#' @param ... Remaining arguments are passed to \code{shiny::runApp}, e.g.
#'   `'port'`, `'display.mode'`, etc.
#' 
#' @examples
#' if (interactive()) {
#'   shinySearchbar:::demo("gallery")
#' }
#'
#' @import shiny
demo <- function(name="gallery", ...) {
  if (!(name %in% names(demos))) {
    stop(sprintf("Invalid demo `%s`, available demos include: %s", name, paste(names(demos), collapse=" ")))
  }

  shiny::runApp(
    system.file(
      file.path("app", demos[[name]]),
      package="shinySearchbar", 
      mustWork=TRUE
    ), 
    ...
  )
}