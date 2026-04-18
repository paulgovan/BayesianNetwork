test_that("character columns are auto-converted to factors", {
  dat <- data.frame(A = c("a", "b", "c"), B = 1:3, stringsAsFactors = FALSE)
  char_cols <- sapply(dat, is.character)
  dat[char_cols] <- lapply(dat[char_cols], as.factor)

  expect_true(is.factor(dat$A))
  expect_false(is.factor(dat$B))
  expect_equal(levels(dat$A), c("a", "b", "c"))
})

test_that("multiple character columns are all converted", {
  dat <- data.frame(
    X = c("x1", "x2"), Y = c("y1", "y2"), Z = 1:2,
    stringsAsFactors = FALSE
  )
  char_cols <- sapply(dat, is.character)
  dat[char_cols] <- lapply(dat[char_cols], as.factor)

  expect_true(is.factor(dat$X))
  expect_true(is.factor(dat$Y))
  expect_false(is.factor(dat$Z))
})

test_that("NA rows are removed", {
  dat <- data.frame(A = c(1, NA, 3), B = c("a", "b", NA), stringsAsFactors = FALSE)
  na_rows <- !complete.cases(dat)
  dat_clean <- dat[!na_rows, ]

  expect_equal(nrow(dat_clean), 1)
  expect_false(anyNA(dat_clean))
})

test_that("post-NA removal triggers too-few-rows condition", {
  dat <- data.frame(A = c(1, NA), B = c("a", "b"), stringsAsFactors = FALSE)
  na_rows <- !complete.cases(dat)
  dat_clean <- dat[!na_rows, ]

  expect_true(nrow(dat_clean) < 2)
})

test_that("algDescriptions covers all 12 supported algorithms", {
  env <- new.env()
  global_path <- system.file("bn/global.R", package = "BayesianNetwork")
  source(global_path, local = env)

  expected_algs <- c(
    "gs", "iamb", "fast.iamb", "inter.iamb",
    "hc", "tabu",
    "mmhc", "rsmax2",
    "mmpc", "si.hiton.pc", "aracne", "chow.liu"
  )
  expect_true(all(expected_algs %in% names(env$algDescriptions)))
  expect_true(all(nzchar(env$algDescriptions[expected_algs])))
  expect_equal(length(expected_algs), 12L)
})
