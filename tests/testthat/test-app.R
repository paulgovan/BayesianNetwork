skip_if_not_installed("shinytest2")
skip_on_cran()

# Skip if no Chrome/Chromium is available
skip_if(
  inherits(
    tryCatch(chromote::find_chrome(), error = function(e) e),
    "error"
  ),
  message = "Chrome/Chromium not available"
)

app_dir <- system.file("bn", package = "BayesianNetwork")

make_app <- function() {
  shinytest2::AppDriver$new(
    app_dir,
    timeout = 30000,
    load_timeout = 30000
  )
}

# DOM helpers — shinydashboard suspends hidden-tab outputs, so navigate to the
# relevant tab before reading its outputs via the browser DOM.
get_text <- function(app, id) {
  app$get_js(sprintf(
    "var el = document.getElementById('%s'); el ? el.textContent.trim() : ''",
    id
  ))
}

has_shiny_error <- function(app, id) {
  isTRUE(app$get_js(sprintf(
    "!!document.querySelector('#%s.shiny-output-error')", id
  )))
}

# ── Startup ───────────────────────────────────────────────────────────────────

test_that("app loads and home tab is active", {
  app <- make_app()
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle(timeout = 20000)
  expect_equal(app$get_value(input = "sidebarMenu"), "home")
})

# ── Discrete workflow ─────────────────────────────────────────────────────────

test_that("discrete network produces a finite log-likelihood score", {
  app <- make_app()
  on.exit(app$stop(), add = TRUE)

  # Navigate to Structure tab so its outputs are un-suspended and computed
  app$set_inputs(sidebarMenu = "structure")
  app$wait_for_idle(timeout = 25000)

  score_text <- get_text(app, "score")
  expect_true(nzchar(score_text))
  score_num <- suppressWarnings(as.numeric(score_text))
  expect_true(is.finite(score_num))
  expect_lt(score_num, 0)
})

test_that("home tab shows node and arc count value boxes", {
  app <- make_app()
  on.exit(app$stop(), add = TRUE)

  # Structure tab triggers dag() computation; then go home to see value boxes
  app$set_inputs(sidebarMenu = "structure")
  app$wait_for_idle(timeout = 25000)
  app$set_inputs(sidebarMenu = "home")
  app$wait_for_idle(timeout = 5000)

  nodes_text <- get_text(app, "nodesBox")
  arcs_text  <- get_text(app, "arcsBox")
  expect_true(nzchar(nodes_text))
  expect_true(nzchar(arcs_text))
})

# ── Gaussian workflow ─────────────────────────────────────────────────────────

test_that("gaussian network produces a finite score", {
  app <- make_app()
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(dataInput = "1", net = "2")
  app$set_inputs(sidebarMenu = "structure")
  app$wait_for_idle(timeout = 25000)

  score_text <- get_text(app, "score")
  expect_true(nzchar(score_text))
  expect_true(is.finite(suppressWarnings(as.numeric(score_text))))
})

test_that("gaussian inference renders without a Shiny error", {
  app <- make_app()
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(dataInput = "1", net = "2")
  app$wait_for_idle(timeout = 25000)

  # Navigate to Inference tab and set event node
  app$set_inputs(sidebarMenu = "inference")
  app$set_inputs(event = "B")
  app$wait_for_idle(timeout = 15000)

  expect_false(has_shiny_error(app, "distPlot"))
})

# ── Algorithm descriptions ────────────────────────────────────────────────────

test_that("algorithm description updates when algorithm changes", {
  app <- make_app()
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(sidebarMenu = "structure")
  app$wait_for_idle(timeout = 25000)

  alg_help_gs <- get_text(app, "algHelp")
  expect_true(grepl("Grow-Shrink", alg_help_gs, fixed = TRUE))

  app$set_inputs(alg = "hc")
  app$wait_for_idle(timeout = 5000)

  alg_help_hc <- get_text(app, "algHelp")
  expect_true(grepl("Hill Climbing", alg_help_hc, fixed = TRUE))
  expect_false(identical(alg_help_gs, alg_help_hc))
})

# ── Multi-evidence ────────────────────────────────────────────────────────────

test_that("adding evidence updates the evidence panel", {
  app <- make_app()
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(sidebarMenu = "inference")
  app$wait_for_idle(timeout = 25000)

  panel_before <- get_text(app, "evidencePanel")
  expect_true(grepl("No additional evidence", panel_before, fixed = TRUE))

  # learning.test column A has levels a, b, c
  app$set_inputs(evidenceNode = "A")
  app$wait_for_idle(timeout = 5000)
  app$set_inputs(evidenceValue = "a")
  app$click("addEvidence")
  app$wait_for_idle(timeout = 5000)

  panel_after <- get_text(app, "evidencePanel")
  expect_true(grepl("A", panel_after, fixed = TRUE))
})

test_that("clearing evidence resets the evidence panel", {
  app <- make_app()
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(sidebarMenu = "inference")
  app$wait_for_idle(timeout = 25000)

  app$set_inputs(evidenceNode = "A")
  app$wait_for_idle(timeout = 5000)
  app$set_inputs(evidenceValue = "b")
  app$click("addEvidence")
  app$wait_for_idle(timeout = 5000)

  app$click("clearEvidence")
  app$wait_for_idle(timeout = 5000)

  panel_cleared <- get_text(app, "evidencePanel")
  expect_true(grepl("No additional evidence", panel_cleared, fixed = TRUE))
})
