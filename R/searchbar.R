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
  accuracy=c("partially", "complementary", "exactly"),
  synonyms=list(),

  ignorePunctuation=c(),
  wildcards=c("disabled", "enabled", "withSpaces"),

  iframes=FALSE,
  iframesTimeout=5000,

  separateWordSearch=TRUE,
  diacritics=TRUE,
  acrossElements=FALSE,
  caseSensitive=FALSE,
  ignoreJoiners=FALSE,
  debug=FALSE
)

#' <Add Title>
#'
#' <Add Description>
#'
#' @import jsonlite
#' @export
searchbar <- function(inputId, context, value=NULL, label=NULL, width=NULL, placeholder=NULL,
    counter=FALSE, cycler=FALSE, scrollBehavior=c("smooth", "auto"),
    markOpts=configurator
  ) {

  # Check no invalid (or misspelled) options are passed to markOpts
  # Take 'seperateWordSearch' instead of 'separateWordSearch', for example...
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
    tags$input(class="form-control", type="text", id=inputId %_% "keyword", placeholder=placeholder, value=value)
  )

  if (counter) {
    # Append the counter element to the tag list
    searchbarTags <- searchbarTags %>% tagList(
      tags$div(class="btm-addon",
        tags$small(class="text-muted sb-counter", id=inputId %_% "counter", `data-search`="counter")
      )
    )
  }

  if (cycler) {
    # Append the cycler buttons to the list
    searchbarTags <- searchbarTags %>% tagList(
      tags$span(class="input-group-btn", style = if (cycler) "vertical-align: top;",
        tags$button(class="btn sb-btn", type="button", id=inputId %_% "next", `data-search`="next", HTML("&darr;")),
        tags$button(class="btn sb-btn", type="button", id=inputId %_% "prev", `data-search`="prev", HTML("&uarr;"))
      )
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
      shiny:::shinyInputLabel(inputId, label),

      div(id=inputId, class = if (cycler) "input-group shiny-sb" else "shiny-sb",
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

#' <Add Title>
#'
#' <Add Description>
#'
#' @import shiny
#' @export
updateMarkOptions <- function(id, markOpts, session=shiny::getDefaultReactiveDomain()) {
  message <- list(id=id, markOpts=markOpts)
  session$sendCustomMessage("updateMarkOptions", message)
}