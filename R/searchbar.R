`%AND%` <- shiny:::`%AND%`

`%_%` <- function(x, y) {
  paste(x, y, sep='_')
}

#' <Add Title>
#'
#' <Add Description>
#'
#' @export
searchbar <- function(inputId, context, label=NULL, width=NULL, placeholder=NULL,
    cycler=FALSE, highlight="yellow", highlight2="orange"
  ) {
  addResourcePath(prefix='js', directoryPath=system.file("assets/js", package='shinySearchbar'))
  addResourcePath(prefix='css', directoryPath=system.file("assets/css", package='shinySearchbar'))

  searchbarTags <- tagList(
    tags$input(type="text", id=inputId %_% "keyword", placeholder=placeholder)
  )

  # Add the cycler buttons to the list if enabled
  if (cycler) {
    searchbarTags <- tagList(
      searchbarTags,
      tags$button(class="btn btn-xs", type="button", id=inputId %_% "next", `data-search`="next", HTML("&darr;")),
      tags$button(class="btn btn-xs", type="button", id=inputId %_% "prev", `data-search`="prev", HTML("&uarr;"))
    )
  }

  tagList(
    singleton(tags$head(
      tags$script(src="js/jquery.mark.min.js"),
      tags$script(src="js/shinySearchbarBinding.js"),
      tags$link(rel="stylesheet", type="text/css", href="css/shinySearchbar.css")
    )),

    div(class = "form-group shiny-input-container",
      style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"),
      label %AND% tags$label(label, `for` = inputId),

      div(id=inputId, class="input-group shiny-searchbar",
        searchbarTags,
        `data-context` = context,
        `data-cycler` = if (cycler) "true" else "false"
      )
    )
  )
}
