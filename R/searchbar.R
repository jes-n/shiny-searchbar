#' @include utils.R
NULL

#' Configuration Options for Mark.js mark()
#'
#' These are all the available options for Mark.js v8.11.1,
#' excluding the element option (used internally) and the callback
#' functions: each, filter, noMatch, and done (some of which are
#' used internally.
#'
#' See https://markjs.io/#mark for a detailed description of each option.
#' Also see https://markjs.io/configurator.html for these options in action.
#'
configurator <- list(
  className="",
  separateWordSearch=TRUE,
  accuracy=c("partially", "complementary", "exactly"),
  diacritics=TRUE,
  synonyms=list(),
  iframes=FALSE,
  iframesTimeout=5000,
  acrossElements=FALSE,
  caseSensitive=FALSE,
  ignoreJoiners=FALSE,
  ignorePunctuation=c(),
  wildcards=c("disabled", "enabled", "withSpaces"),
  debug=FALSE
)

#' <Add Title>
#'
#' <Add Description>
#'
#' @import jsonlite
#' @export
searchbar <- function(inputId, context, label=NULL, width=NULL, placeholder=NULL,
    cycler=FALSE, counter=FALSE, scrollBehavior=c("smooth", "auto"),
    markOpts=configurator, highlight="yellow", highlight2="orange"
  ) {

  # Check no invalid (or misspelled) options are passed to markOpts
  # Take 'seperateWordSearch' instead of 'separateWordSearch' for example...
  invalidOpts <- markOpts %nin% configurator
  if (length(invalidOpts) > 0) {
    msg <- paste(
      sprintf("Invalid option(s) in 'markOpts' argument: %s", paste(invalidOpts, collapse=" ")),
      sprintf("  Should be %s", paste(names(configurator), collapse=" ")),
      sep = "\n"
    )
    warning(msg, call.=FALSE)
  }

  # Set or check argument values against default options
  scrollBehavior <- default(scrollBehavior, message="See https://developer.mozilla.org/en-US/docs/Web/API/ScrollToOptions for more details.")
  markOpts$accuracy <- default(markOpts$accuracy, choices=configurator$accuracy, message="See https://markjs.io/#mark for more details.")
  markOpts$wildcards <- default(markOpts$wildcards, choices=configurator$wildcards, message="See https://markjs.io/#mark for more details.")

  addResourcePath(prefix='js', directoryPath=system.file("assets/js", package='shinySearchbar'))
  addResourcePath(prefix='css', directoryPath=system.file("assets/css", package='shinySearchbar'))

  searchbarTags <- tagList(
    tags$input(type="text", id=inputId %_% "keyword", placeholder=placeholder)
  )

  # Add the cycler buttons to the list, if enabled
  if (cycler) {
    searchbarTags <- tagList(
      searchbarTags,
      tags$button(class="btn btn-xs", type="button", id=inputId %_% "next", `data-search`="next", HTML("&darr;")),
      tags$button(class="btn btn-xs", type="button", id=inputId %_% "prev", `data-search`="prev", HTML("&uarr;"))
    )
  }

  # And the counter element to the tag list, if enabled
  if (counter) {
    searchbarTags <- tagList(
      searchbarTags,
      tags$small(class="sb-counter", id=inputId %_% "counter", `data-search`="counter")
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
        `data-cycler` = jsonlite::toJSON(cycler, auto_unbox=TRUE),
        `data-counter` = jsonlite::toJSON(counter, auto_unbox=TRUE),
        `data-scroll-behavior` = if (cycler) scrollBehavior else "null",
        `data-mark-options` = jsonlite::toJSON(markOpts, auto_unbox=TRUE)
      )
    )
  )
}
