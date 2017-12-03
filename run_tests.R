library(testthat)
library(shinytest)

testthat::test_that("Application works", {
  shinytest::expect_pass(shinytest::testApp("inst/bn", "mytest", compareImages = FALSE))
})
