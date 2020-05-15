#' Shiny's internal \code{%AND%} function
#' 
#' Reproduced since it is not exported in the Shiny namespace.
#' 
#' @keywords internal
`%AND%` <- function(x, y) {
  if (!is.null(x) && !isTRUE(is.na(x))) 
    if (!is.null(y) && !isTRUE(is.na(y))) 
      return(y)
  return(NULL)
}


#' Shiny's internal \code{shinyInputLabel} function
#' 
#' Reproduced since it is not exported in the Shiny namespace.
#' 
#' @keywords internal
shinyInputLabel <- function(inputId, label=NULL) {
  tags$label(label,
    class = "control-label",
    class = if (is.null(label)) "shiny-label-null",
    `for` = inputId
  )
}


#' Underscore Join Operator
#' 
#' Inspired by Shiny's \code{%.%} operator which joins two arguments with a
#' period (.), instead this uses an underscore (_) which is more suitable
#' for HTML `id` attributes.
#' 
#' @keywords internal
`%_%` <- function(x, y) paste(x, y, sep='_')


#' Names-Not-In Operator
#' 
#' Shorthand to determine object names in `x` but not in `y`
#' 
#' @keywords internal
`%nni%` <- function(x, y) names(x)[!(names(x) %in% names(y))]


#' Non-blocking match.arg with better error reporting.
#'
#' Performs similar traceback as match.arg for default argument values. Unlike
#' match.arg, this function does not stop execution. It simply emits a detailed
#' warning including the invalid argument value, the calling funcation, and 
#' the expected argument values.
#'
#' @keywords internal
default <- function(arg, choices, message=NULL) {
  arg <- tryCatch({
    # Determine the name of the calling function (i.e. which=-1)
    # sys.call returns the entire call syntax, including the arguments
    # as.list splits the syntax into a numbered list, with the function first and the arguments following
    # The elements in this list are Language objects, so deparse is used to represent them as characters
    f <- deparse(as.list(sys.call(-1))[[1]])

    # Get the formal name of the argument passed to this function
    name <- deparse(substitute(arg))

    if (missing(choices)) {
      # Get the formal arguments of the calling function
      # Here sys.function returns the entire function definition of the calling function
      proto <- formals(sys.function(-1))

      # Extract the default arguments, given in the formal argument definition of the calling function
      # sys.frame is used to get the environment of the calling function
      choices <- eval(proto[[name]], envir=sys.frame(-1))
    }

    # Used match.arg to issue a warning if the defined argument is not in the list of default arguments
    # This entire function is based off the match.arg function
    return(match.arg(arg, choices))

  }, error = function(e) {
    # match.arg can raise many diffrent errors
    # Make sure the correct one is caught, if not raise it again
    if (!grepl("'arg' should be one of", e$message))
      stop(e)

    # If match.arg raises an error, parse its error message and provide more details to the user
    # This includes the given argument value, the name of the calling function, and the expected value(s)
    msg <- c(
      sprintf("Invalid option %s='%s' in '%s' call.", name, arg, f),
      sprintf("  S%s", sub("'.*' s", "", e$message))
    )

    # Append the optional user message
    if (!is.null(message))
      msg <- c(msg, sprintf("  %s", message))

    # Raise a warning, instead of stopping the execution
    warning(paste(msg, collapse="\n"), call.=FALSE)

    # If match.arg is not successful, return the original argument
    return(arg)
  })

  return(arg)
}


#' Validate the Options Passed to mark.js API
#' 
#' @keywords internal
validateMarkOpts <- function(opts) {
  valid <- configurator

  # Include additional options that *shouldn't* be set by the user
  valid$each <- NA
  valid$filter <- NA
  valid$noMatch <- NA
  valid$done <- NA
  valid$log <- NA

  # Check no invalid (or misspelled) options are passed to markOpts
  # Take 'seperateWordSearch' instead of 'separateWordSearch', for example...
  invalid <- opts %nni% valid
  if (length(invalid) > 0) {
    warning(paste(
      sprintf("Invalid option(s) in 'markOpts' argument: %s", paste(invalid, collapse=" ")),
      sprintf("  Should be %s", paste(names(configurator), collapse=" ")),
      sep = "\n"
    ), call.=FALSE)
  }

  # Warn about changing the default mark.js element from 'mark'
  if (("element" %in% names(opts)) && (opts$element != "mark")) {
    warning(sprintf(paste(
        "Setting the mark.js option 'element' to '%s' (default 'mark') could prevent the default shinySearchbar CSS highlighting.",
        "  Using the 'className' option could be a better option, depending on the usecase.",
        sep = "\n"
      ), opts$element
    ), call.=FALSE)
  }

  # Warn about the various mark.js callback options
  if (any(c('each', 'filter', 'noMatch', 'done') %in% names(opts))) {
    warning(paste(
      "The mark.js callback options (each, filter, noMatch, and done) must be implemented in JavaScript.",
      "  No JavaScript specific syntax is checked, check the brower's console for error messages.",
      sep = "\n"
    ), call.=FALSE)
  }

  # Warn about important behavior of the 'done' callback option
  if ('done' %in% names(opts))
    warning(
      "Incorrectly changing the 'done' mark.js callback option will break the counter and scrolling behavior in shinySearchbar.",
      call.=FALSE
    )

  # Default the options which have defined values
  opts$accuracy <- default(opts$accuracy,
    choices=configurator$accuracy,
    message="See https://markjs.io/#mark for more details."
  )
  opts$wildcards <- default(opts$wildcards,
    choices=configurator$wildcards,
    message="See https://markjs.io/#mark for more details."
  )

  # mark.js expects 'exclude' as an Array, 'synonyms' as an Object, and 'ignorePunctuation' as an Array
  # jsonlite makes assumptions for R data types of length 0, as described here: https://cran.r-project.org/web/packages/jsonlite/vignettes/json-mapping.pdf
  # Such as c(1, 2, 3) becomes [1, 2, 3] while c() becomes {}
  # If these options are of length 0, set them to the correct R data type for conversion with jsonlite
  if (length(opts$exclude) == 0)
    opts$exclude <- list()
  if (length(opts$synonyms) == 0)
    opts$synonyms <- c()
  if (length(opts$ignorePunctuation) == 0)
    opts$ignorePunctuation <- list()

  return(opts)
}