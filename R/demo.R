demos = list(
  "basic" = "basic-demo",
  "cycler" = "cycler-demo",
  "overflow" = "overflow-demo",
  "configurator" = "configurator-demo",
  "iframe" = "iframe-demo",
  "counter" = "counter-demo"
)

#' Demo
#' 
#' Run a demo.
demo <- function(name="basic", display.mode="showcase", port=6169, ...) {
  if (!(name %in% names(demos))) {
    stop(sprintf("Invalid demo `%s`, available demos include: %s", name, paste(names(demos), collapse=" ")))
  }

  shiny::runApp(
    system.file(
      file.path("demo", demos[[name]]),
      package="shinySearchbar", 
      mustWork=TRUE
    ), 
    display.mode=display.mode, port=port,
    ...
  )
}
