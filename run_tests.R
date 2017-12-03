install.packages("Cairo", INSTALL_opts = "--no-test-load")

testthat::test_that("Application works", {
  shinytest::expect_pass(shinytest::testApp("inst/bn", "mytest", compareImages = FALSE))
})
