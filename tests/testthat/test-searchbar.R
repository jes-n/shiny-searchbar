#' Given a named list, extract the elements with `name`
#' and concatenate them with a space.
#' 
#' Works for named lists with repeating names (such as those from
#' Shiny tagLists)
attribute <- function(name, el) {
  attr <- c()
  for (i in 1:length(el)) {
    key <- names(el[i])
    value <- el[[i]]
    if (key == name)
      attr <- c(attr, value)
  }
  return(paste(attr, collapse=" "))
}

test_that("Basic HTML structure", {
  # Generates the searchbar widget HTML tag
  # Contains a <head> (singleton) and <div> (container) element
  inputID = "sb"
  contextID = "text"
  tag <- searchbar(inputID, context=contextID)

  # The singleton includes the JS/CSS dependencies
  head <- tag[[1]]

  # Extract dependencies from the singleton
  deps <- lapply(head$children ,function(el) {
    if (el$name == "script")
      return(el$attribs$src)
    else
      return(el$attribs$href)
  }) %>% unlist(use.name=FALSE)

  expect_true( "js/jquery.mark.min.js" %in% deps )
  expect_true( "js/shinySearchbarBinding.js" %in% deps )
  expect_true( "css/shinySearchbar.css" %in% deps )


  # The container includes the remaining widget tags
  container <- tag[[2]]

  # <div class="form-group shiny-input-container">
  expect_true( grepl("shiny-input-container", container$attribs) )

  label <- container$children[[1]]

  # <label class="control-label" for="sb"></label>
  expect_equal( "label", label$name )
  expect_equal( inputID, label$attribs$`for` )
  expect_true( grepl("control-label", label$attribs$class) )


  widget <- container$children[[2]]

  # <div id="sb" class="shiny-sb" data-context=... data-cycler=... data-counter=... data-mark-options=...>
  expect_equal( inputID, widget$attribs$id )
  expect_equal( contextID, widget$attribs$`data-context` )
  expect_equal( "shiny-sb", widget$attribs$class )
  expect_true( "data-counter" %in% names(widget$attribs) )
  expect_true( "data-cycler" %in% names(widget$attribs) )
  expect_true( "data-mark-options" %in% names(widget$attribs) )


  searchbar <- widget$children[[1]][[1]]

  # <input class="form-control" type="text" id="sb_keyword"/>
  expect_equal( "input", searchbar$name )
  expect_equal( "text", searchbar$attribs$type )
  expect_equal( "form-control", searchbar$attribs$class )
  expect_equal( inputID %_% "keyword", searchbar$attribs$id )

})
