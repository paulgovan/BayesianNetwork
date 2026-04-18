data(learning.test, package = "bnlearn")
data(gaussian.test, package = "bnlearn")

# ── Structure learning ──────────────────────────────────────────────────────

test_that("hc learns a directed structure on discrete data", {
  dag <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  expect_s3_class(dag, "bn")
  expect_true(bnlearn::directed(dag))
  expect_gt(bnlearn::nnodes(dag), 0L)
})

test_that("hc learns a directed structure on gaussian data", {
  dag <- bnlearn::cextend(bnlearn::hc(gaussian.test), strict = FALSE)
  expect_s3_class(dag, "bn")
  expect_true(bnlearn::directed(dag))
  expect_gt(bnlearn::nnodes(dag), 0L)
})

test_that("gs learns a structure on discrete data", {
  dag <- bnlearn::cextend(bnlearn::gs(learning.test), strict = FALSE)
  expect_s3_class(dag, "bn")
  expect_equal(bnlearn::nnodes(dag), ncol(learning.test))
})

# ── Parameter fitting ───────────────────────────────────────────────────────

test_that("MLE parameter fitting works on discrete networks", {
  dag <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  fit <- bnlearn::bn.fit(dag, learning.test, method = "mle")
  expect_s3_class(fit, "bn.fit")
  expect_equal(length(fit), ncol(learning.test))
})

test_that("Bayesian parameter fitting works on discrete networks", {
  dag <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  fit <- bnlearn::bn.fit(dag, learning.test, method = "bayes")
  expect_s3_class(fit, "bn.fit")
  expect_equal(length(fit), ncol(learning.test))
})

test_that("MLE-g (Gaussian) parameter fitting works on continuous networks", {
  dag <- bnlearn::cextend(bnlearn::hc(gaussian.test), strict = FALSE)
  fit <- bnlearn::bn.fit(dag, gaussian.test, method = "mle-g")
  expect_s3_class(fit, "bn.fit")
  expect_equal(length(fit), ncol(gaussian.test))
})

# ── Inference ───────────────────────────────────────────────────────────────

test_that("cpdist returns conditional samples for discrete inference", {
  dag <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  fit <- bnlearn::bn.fit(dag, learning.test, method = "mle")

  evidence <- list("a")
  names(evidence) <- "A"
  samples <- bnlearn::cpdist(fit, "B", evidence = evidence, method = "lw")

  expect_s3_class(samples, "data.frame")
  expect_gt(nrow(samples), 0L)
  nodeProbs <- prop.table(table(samples))
  expect_true(abs(sum(nodeProbs) - 1) < 1e-9)
})

test_that("cpdist returns continuous samples for Gaussian inference", {
  dag <- bnlearn::cextend(bnlearn::hc(gaussian.test), strict = FALSE)
  fit <- bnlearn::bn.fit(dag, gaussian.test, method = "mle-g")

  evidence <- list(as.numeric(mean(gaussian.test$A)))
  names(evidence) <- "A"
  samples <- bnlearn::cpdist(fit, "B", evidence = evidence, method = "lw")

  expect_s3_class(samples, "data.frame")
  expect_gt(nrow(samples), 0L)
  # Samples should be numeric, not factor
  expect_true(is.numeric(samples[[1]]))
  # Density estimation should succeed
  dens <- density(samples[[1]])
  expect_s3_class(dens, "density")
})

# ── Scoring ─────────────────────────────────────────────────────────────────

test_that("log-likelihood score is finite and negative for discrete network", {
  dag <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  sc <- bnlearn::score(dag, learning.test, type = "loglik")
  expect_true(is.finite(sc))
  expect_lt(sc, 0)
})

test_that("log-likelihood score is finite and negative for Gaussian network", {
  dag <- bnlearn::cextend(bnlearn::hc(gaussian.test), strict = FALSE)
  sc <- bnlearn::score(dag, gaussian.test, type = "loglik-g")
  expect_true(is.finite(sc))
  expect_lt(sc, 0)
})

test_that("BIC score is computable for both data types", {
  dag_d <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  dag_g <- bnlearn::cextend(bnlearn::hc(gaussian.test), strict = FALSE)
  expect_true(is.finite(bnlearn::score(dag_d, learning.test, type = "bic")))
  expect_true(is.finite(bnlearn::score(dag_g, gaussian.test, type = "bic-g")))
})

# ── Network measures ─────────────────────────────────────────────────────────

test_that("amat returns a square adjacency matrix", {
  dag <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  adj <- bnlearn::amat(dag)
  expect_true(is.matrix(adj))
  expect_equal(nrow(adj), ncol(adj))
  expect_equal(nrow(adj), ncol(learning.test))
  expect_true(all(adj %in% c(0L, 1L)))
})

test_that("nnodes and narcs return non-negative integers", {
  dag <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  expect_gte(bnlearn::nnodes(dag), 0L)
  expect_gte(bnlearn::narcs(dag), 0L)
})

# ── File I/O ─────────────────────────────────────────────────────────────────

test_that("write.bif writes a readable BIF file for a fitted network", {
  dag <- bnlearn::cextend(bnlearn::hc(learning.test), strict = FALSE)
  fit <- bnlearn::bn.fit(dag, learning.test, method = "mle")

  tmp <- tempfile(fileext = ".bif")
  on.exit(unlink(tmp), add = TRUE)

  bnlearn::write.bif(tmp, fit)

  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0L)
  content <- readLines(tmp, warn = FALSE)
  expect_true(any(grepl("network", content, ignore.case = TRUE)))
})
