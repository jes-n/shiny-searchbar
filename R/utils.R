#' Import shiny's internal `%AND%` function
`%AND%` <- shiny:::`%AND%`

#' Inspired by shiny's `%.%` function which joins two arguments with a '.'
#' Instead of a '.', this implementation uses a '_' (more suitable for HTML)
`%_%` <- function(x, y) {
  paste(x, y, sep='_')
}

#' Non-blocking match.arg with better error reporting.
#'
#' Performs similar traceback as match.arg for default argument values. Unlike
#' match.arg, this function does not stop execution. It simply emits a detailed
#' warning including the invalid argument value, the calling funcation, and 
#' the expected argument values.
#'
#' @examples
#' f <- function(a=c(1, 2)) {
#'   a <- default(a)
#'   return(a)
#' }
#'
#' f(1)
#' [1] 1
#'
#' f(3)
#' Warning: Invalid option a='3' in 'f' call.
#'   Should be one of 1, 2
#' [1] 3
#'
#' @import tools
default <- function(arg) {
  tryCatch({
    # Determine the name of the calling function (i.e. which=-1)
    # sys.call returns the entire call syntax, including the arguments
    # as.list splits the syntax into a numbered list, with the function first and the arguments following
    # The elements in this list are Language objects, so deparse is used to represent them as characters
    f <- deparse(as.list(sys.call(-1))[[1]])

    # Get the formal name of the argument passed to this function
    name <- as.character(substitute(arg))

    # Get the formal arguments of the calling function
    # Here sys.function returns the entire function definition of the calling function
    proto <- formals(sys.function(-1))

    # Extract the default arguments, given in the formal argument definition of the calling function
    # sys.frame is used to get the environment of the calling function
	  choices <- eval(proto[[name]], envir=sys.frame(-1))

    # Used match.arg to issue a warning if the defined argument is not in the list of default arguments
    # This entire function is based off the match.arg function
    return(match.arg(arg, choices))
  }, error = function(e) {
    # If match.arg raises an error, parse its error message and provide more details to the user
    # This includes the given argument value, the name of the calling function, and the expected value(s)
    msg <- sprintf(
      "Invalid option %s='%s' in '%s' call.\n  S%s",
      name, arg, f, sub("'.*' s", "", e$message)
    )

    # Raise a warning, then continue with execution
    warning(msg, call.=FALSE)
  })

  # If match.arg is not successful, return the original argument
  return(arg)
}