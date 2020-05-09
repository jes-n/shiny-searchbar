
test_that("default() determines default values", {
  f <- function(a=c('A','B','C')) default(a)

  expect_equal(f(), 'A')
  expect_equal(f('B'), 'B')
  expect_warning(f('D'))
})

test_that("default() determines previously defined default values", {
  opts = list(a=c('A','B','C'))
  f <- function(o=opts) default(o$a, opts$a)

  expect_equal(f(), 'A')
  expect_equal(f(list(a='B')), 'B')
  expect_warning(f(list(a='D')))
})

test_that("default() reraises correct match.arg error", {
  f <- function(a=c('A','B','C')) default(a)

  expect_error(f(a=NA))
  expect_error(f(a=list()))
})


test_that("`%nin%`: names-not-in operator", {
  a <- list(A=1, B=2, C=3)

  expect_equal(list(A=1, B=2, D=4) %nin% a, c('D'))
  expect_equal(list(A=1, D=4, E=5) %nin% a, c('D', 'E'))
})

test_that("`%_%`: underscore join operator", {
  expect_equal("lorem" %_% "ipsum", "lorem_ipsum")
})

test_that("`%AND%`: shiny's basic internal truthy operator", {
  expect_equal( NULL %AND% TRUE,  NULL)
  expect_equal(   NA %AND% TRUE,  NULL)

  expect_equal( TRUE %AND% NULL,  NULL)
  expect_equal( TRUE %AND% NA,    NULL)

  expect_equal( TRUE %AND% TRUE,  TRUE)
  expect_equal(FALSE %AND% TRUE,  TRUE)
  expect_equal(FALSE %AND% FALSE, FALSE)
})