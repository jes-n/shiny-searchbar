#' @include utils.R
NULL


#' Configuration Options List for mark.js API
#'
#' All API options for mark.j v8.11.1, excluding the callback functions:
#' `each`, `filter`, `noMatch`, and `done`.
#' 
#' See the \href{https://markjs.io/#mark}{mark.js API} for a detailed
#' description of each option. Also see the mark.js
#' \href{https://markjs.io/configurator.html}{Configurator} for these
#' options in action.
#' 
#' @format List with 15 name elements.
#' \describe{
#'   \item{element}{Element tag to wrap matches, default is `"mark"`.}
#'   \item{className}{Class named appended to the match element,
#'     default is `""`.}
#'   \item{exclude}{Vector of element selectors to exclude from match,
#'     default is `c()`.}
#'   \item{accuracy}{Match algorithm (`"partially"`, `"complementary"`,
#'     or `"exactly"`), default is `"partially"`.
#'     (see \href{https://markjs.io/#mark}{mark.js API} for more details).}
#'   \item{synonyms}{List of key-value pairs to consider equivalent,
#'     default is `list()`.}
#'   \item{ignorePunctuation}{Vector of punctuation marks to ignore,
#'     default is `c()`.}
#'   \item{wildcards}{Matching using wildcards such as "?" and "*"
#'     (`"disabled"`, `"enabled"`, or `"withSpaces"`), default is `"disabled"`
#'     (see \href{https://markjs.io/#mark}{mark.js API} for more details).}
#'   \item{iframes}{Search within iframe elements, default is `FALSE`.}
#'   \item{iframesTimeout}{Maximum time (in ms) to wait for load before
#'     skipping an iframe element, default is `5000`.}
#'   \item{seperateWordSearch}{Search for each space-seperated word instead
#'     of the complete input, default is `TRUE`.}
#'   \item{diacritics}{Match using diacritic characters, default is `TRUE`.}
#'   \item{acrossElements}{Search for matches across elements,
#'     default is `FALSE`.}
#'   \item{caseSensitive}{Case sensitive matching, default is `FALSE`.}
#'   \item{ignoreJoiners}{Skip soft hyphen, zero width space, zero width
#'     non-joiner and zero width joiner, default is `FALSE`.}
#'   \item{debug}{Print debug information to the brower's console,
#'     default is `FALSE`.}
#' }
configurator <- list(
  element="mark", # Changing this will prevent default highlighting behavior
  className="",
  exclude=c(),
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


#' Create the searchbar widget.
#'
#' Create a textInput-like searchbar which can search through and highlight
#' the user's input within another element.
#' 
#' The _counter_ and _cycler_ arguments add additional functionality to the
#' searchbar. The _counter_ shows the user how many matches were found and
#' the _cycler_ gives the user an interface to cycle through each match with
#' automatic scrolling (using either the buttons or Enter and Shift+Enter).
#' 
#' The _markOpts_ are a list of options to pass to the underlying
#' \href{https://markjs.io/#mark}{mark.js API}, which handles finding and
#' highlighting the matches in element identified by _contextId_.
#' 
#' @param inputId The `input` slot that will be used to access the value.
#' @param contextId The `input` slot of the element to be searched and
#'   highlighted.
#' @param value Initial value.
#' @param label Display label for the control, or `NULL` for no label.
#' @param width The width of the input, e.g. `'400px'`, or `'100%'`;
#'   see `shiny::validateCssUnit()``.
#' @param placeholder A character string giving the user a hint as to what can
#'   be entered into the control. Internet Explorer 8 and 9 do not support this
#'   option.
#' @param counter Include a counter to display the number of matches found.
#' @param cycler Include an interface to cycle between the matches.
#' @param scrollBehavior Behavior of scrolling with `cycler`, either `"auto"` or
#'   "`smooth`"). The default is `"smooth"`.
#' @param markOpts Options to be passed to mark.js;
#'   see [configurator] and the \href{https://markjs.io/#mark}{mark.js API}
#'   for more details.
#' @param quiet Supress any warning related to incorrect/invalid arguments.
#' 
#' @seealso [updateMarkOptions], [configurator]
#' 
#' @examples
#' if (interactive()) {
#'   ui <- fluidPage(
#'     searchbar("sb", "text"),
#'     textOutput("text")
#'   )
#'   server <- function(input, output) {
#'     output$text <- renderText("Hello world!")
#'   }
#'   shinyApp(ui, server)
#' }
#'
#' @importFrom jsonlite toJSON
#' @export
searchbar <- function(inputId, contextId, value=NULL, label=NULL, width=NULL, placeholder=NULL,
    counter=TRUE, cycler=TRUE, scrollBehavior=c("smooth", "auto"),
    markOpts=configurator, quiet=FALSE
  ) {

  # Set or check argument values against default options
  markOpts <- if (quiet) suppressWarnings(validateMarkOpts(markOpts)) else validateMarkOpts(markOpts)
  scrollBehavior <- default(scrollBehavior, message="See https://developer.mozilla.org/en-US/docs/Web/API/ScrollToOptions for more details.")

  addResourcePath(prefix='shinySearchbar', directoryPath=system.file("assets", package='shinySearchbar'))

  searchbarTags <- tagList(
    tags$input(class="form-control", type="text", id=inputId %_% "keyword", placeholder=placeholder, value=value)
  )

  if (counter) {
    # Append the counter element to the tag list
    searchbarTags <- tagList(searchbarTags,
      tags$div(class="btm-addon",
        tags$small(class="text-muted sb-counter", id=inputId %_% "counter", `data-search`="counter")
      )
    )
  }

  if (cycler) {
    # Append the cycler buttons to the list
    searchbarTags <- tagList(searchbarTags,
      tags$span(class="input-group-btn", style = if (cycler) "vertical-align: top;",
        tags$button(class="btn sb-btn", type="button", id=inputId %_% "next", `data-search`="next", HTML("&darr;")),
        tags$button(class="btn sb-btn", type="button", id=inputId %_% "prev", `data-search`="prev", HTML("&uarr;"))
      )
    )
  }

  tagList(
    singleton(tags$head(
      tags$script(src="shinySearchbar/jquery.mark.min.js"),
      tags$script(src="shinySearchbar/shinySearchbarBinding.js"),
      tags$link(rel="stylesheet", type="text/css", href="shinySearchbar/shinySearchbar.css")
    )),

    div(class = "form-group shiny-input-container",
      style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"),
      shinyInputLabel(inputId, label),

      div(id=inputId, class = if (cycler) "input-group shiny-sb" else "shiny-sb",
        searchbarTags,
        `data-context` = contextId,
        `data-cycler` = toJSON(cycler, auto_unbox=TRUE),
        `data-counter` = toJSON(counter, auto_unbox=TRUE),
        `data-scroll-behavior` = if (cycler) scrollBehavior else "null",
        `data-mark-options` = toJSON(markOpts, auto_unbox=TRUE)
      )
    )
  )
}


#' Update mark.js Options for an Initialized Searchbar Widget
#'
#' Only the options explicitly passed with this function are updated, the
#' previous options are left unchanged.
#' 
#' @param inputId The `input` slot of the initialized searchbar widget.
#' @param markOpts Options to update for mark.js API.
#' @param session The `session` object passed to function given to
#'   `shinyServer`.
#' 
#' @seealso [configurator]
#' 
#' @import shiny
#' @export
updateMarkOptions <- function(inputId, markOpts, session=shiny::getDefaultReactiveDomain()) {
  message <- list(id=inputId, markOpts=markOpts)
  session$sendCustomMessage("updateMarkOptions", message)
}