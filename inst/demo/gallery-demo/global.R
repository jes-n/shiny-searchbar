library(shiny)
library(shinipsum)
library(shinySearchbar)

examples <- new.env()
sys.source("examples.R", envir=examples)

configuration <- new.env()
sys.source("configuration.R", envir=configuration)

#' Load internal lorem ipsum text
lorem <- shinySearchbar:::lorem