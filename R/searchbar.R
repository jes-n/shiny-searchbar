`%AND%` <- shiny:::`%AND%`
# `%_%` <- function(x, y) {
#   paste(x, y, sep='_')
# }

#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
searchbar <- function(inputId, context, label=NULL, width=NULL,
    placeholder=NULL, highlight="#f1c40f", cycler=TRUE
  ) {
  addResourcePath(prefix='js', directoryPath=system.file("assets/js", package='shinySearchbar'))
  addResourcePath(prefix='css', directoryPath=system.file("assets/css", package='shinySearchbar'))

 
  tagList(
    singleton(tags$head(
      tags$script(src="js/jquery.mark.min.js"),
      tags$script(src="js/shinySearchbarBinding.js"),

      tags$link(rel="stylesheet", type="text/css", href="css/shinySearchbar.css")
    )),
 
 
    div(class = "form-group shiny-input-container",
      style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"),
      label %AND% tags$label(label, `for` = inputId),
      
      # <input type="text">
      tags$input(type="text", id=inputId, class="shiny-searchbar",
        placeholder = placeholder,
        `data-context` = context
      )
    )
  )
}
