#' @include utils.R
NULL


#' Configuration Options List for mark.js API
#'
#' These are all the available options for mark.js v8.11.1,
#' excluding the callback functions: each, filter, noMatch, and done.
#'
#' See the \href{https://markjs.io/#mark}{mark.js API} for a detailed
#' description of each option. Also see the mark.js
#' \href{https://markjs.io/configurator.html}{Configurator} for these
#' options in action.
#' 
#' @param element HTML element to wrap matches (default: \code{"mark"}).
#' @param className Class named appended to the match element
#'   (default: \code{""}).
#' @param exclude Exclude HTML elements when matching
#'   (default: \code{list()}).
#' @param accuracy Match type, see mark.js API for more detail
#'   (default: \code{"partially"}).
#' @param synonyms key-value pairs to consider equivalent when matching
#'   (default: \code{c()}).
#' @param ignorePunctuation Punctuation marks to ignore when matching
#'   (default: \code{list()}).
#' @param wildcards Matching using wildcards such as "?" and "*", see mark.js
#'   API for more detail (default: \code{"disabled"}).
#' @param iframes Search within iframe elements (default: \code{FALSE}).
#' @param iframesTimeout Maximum time (in ms) to wait for `load` before
#'   skipping an iframe element (default: \code{5000}).
#' @param seperateWordSearch Search for each word separated by a blank instead
#'   of the complete term (default: \code{TRUE}).
#' @param diacritics Match using diacritic characters (default: \code{TRUE}).
#' @param acrossElements Search for matches across HTML elements
#'   (default: \code{FALSE}).
#' @param caseSensitive Match letter case (default: \code{FALSE}).
#' @param ignoreJoiners Skip soft hyphen, zero width space, zero width
#'   non-joiner and zero width joiner (default: \code{FALSE}).
#' @param debug Print debug information to the brower's console\
#'   (default: \code{FALSE}).
configurator <- list(
  element="mark", # Changing this will prevent default highlighting behavior
  className="",
  exclude=list(),
  accuracy=c("partially", "complementary", "exactly"),
  synonyms=c(),
  ignorePunctuation=list(),
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
#' Create a text input like searchbar which can search through and highlight
#' the user's input within another element (the _context_).
#' 
#' The _counter_ and _cycler_ arguments add additional functionality to the
#' searchbar. The _counter_ shows the user how many matches were found in
#' the _context_ and the _cycler_ gives the user a interface to cycle through
#' each match with automatic scrolling (using either the buttons or Enter
#' and Shift+Enter).
#' 
#' The _markOpts_ are a list of options to pass to the underlying mark.js API,
#' which handles finding and highlighting the matches in the _context_.
#' 
#' @param inputId The \code{input} slot that will be used to access the value.
#' @param context The \code{input} slot of the element to be searched and
#'   highlighted.
#' @param value Initial value.
#' @param label Display label for the control, or \code{NULL} for no label.
#' @param width The width of the input, e.g. `'400px'`, or `'100%'`;
#'   see [shiny::validateCssUnit()].
#' @param placeholder A character string giving the user a hint as to what can
#'   be entered into the control. Internet Explorer 8 and 9 do not support this
#'   option.
#' @param counter Include a counter to display the number of matches found.
#' @param cycler Include an interface to cycle between the matches.
#' @param scrollBehavior Behavior of automatic scrolling, either 'auto' or
#'   'smooth' (requires \code{cycler=TRUE}); see
#'   \url{https://developer.mozilla.org/en-US/docs/Web/API/ScrollToOptions}
#'   for more details.
#' @param markOpts Options to be passed to mark.js;
#'   see [configurator] and the \href{https://markjs.io/#mark}{mark.js API}
#'   for more details.
#' @param quiet Supress any warning related to incorrect arguments.
#' @return A text input like control that can be added to a Shiny UI
#'   definition.
#' 
#' @seealso [updateMarkOptions]
#' 
#' @examples
#' if (interactive()) {
#'   ui <- fluidPage(
#'     searchbar("sb", "text", label="Shiny Searchbar",
#'       placeholder="Trying typing 'hello' here...", counter=TRUE
#'     ),
#'     textOutput("text")
#'   )
#'   server <- function(input, output) {
#'     output$text <- renderText("Hello world!")
#'   }
#'   shinyApp(ui, server)
#' }
#'
#' @importFrom jsonlite toJSON
#' @importFrom magrittr %>%
#' @export
searchbar <- function(inputId, context, value=NULL, label=NULL, width=NULL, placeholder=NULL,
    counter=FALSE, cycler=FALSE, scrollBehavior=c("smooth", "auto"),
    markOpts=configurator, quiet=FALSE
  ) {

  # Set or check argument values against default options
  markOpts <- if (quiet) suppressWarnings(validateMarkOpts(markOpts)) else validateMarkOpts(markOpts)
  scrollBehavior <- default(scrollBehavior, message="See https://developer.mozilla.org/en-US/docs/Web/API/ScrollToOptions for more details.")

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
#' @param inputId The \code{input} slot of the initialized searchbar widget.
#' @param markOpts Options to update within mark.js API.
#' 
#' @seealso [configurator]
#' 
#' @import shiny
#' @export
updateMarkOptions <- function(inputId, markOpts, session=shiny::getDefaultReactiveDomain()) {
  message <- list(id=inputId, markOpts=markOpts)
  session$sendCustomMessage("updateMarkOptions", message)
}