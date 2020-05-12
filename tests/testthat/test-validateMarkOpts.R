test_that("Warn user about invalid or incorrect options", {
  opts <- function(...) searchbar(NULL, NULL, markOpts=list(...))

  # Invalid options
  expect_warning( opts(x=1) )
  expect_warning( opts(seperateWordSearch=FALSE) )

  # Protected options
  expect_warning( opts(element="span") )
  expect_warning( opts(each=NULL, filter=NULL, noMatch=NULL, done=NULL) )
  expect_warning( opts(done=NULL) )

  # Default options
  expect_warning( opts(accuracy="incorrect") )
  expect_warning( opts(wildcards="incorrect") )
})

test_that("Expected behavior of default values and quiet option", {
  # No warning when passing the configurator
  expect_warning(
    searchbar(NULL, NULL, markOpts=shinySearchbar:::configurator),
    regexp = NA
  )

  # Suppress warning with quiet=TRUE
  expect_warning(
    searchbar(NULL, NULL, markOpts=list(seperateWordSearch=FALSE), quiet=TRUE),
    regexp = NA
  )
})