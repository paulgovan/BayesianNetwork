# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package Overview

BayesianNetwork is an R package that wraps bnlearn’s Bayesian network
functions into an interactive Shiny web application. The single exported
function
[`BayesianNetwork()`](http://paulgovan.github.io/BayesianNetwork/reference/BayesianNetwork.md)
launches the bundled Shiny app from `inst/bn/`.

## Common Commands

``` r
# Install dependencies
install.packages(c("bnlearn", "shiny", "shinydashboard", "shinyWidgets", "shinyAce",
                   "rintrojs", "networkD3", "plotly", "heatmaply", "lattice"))

# Load and run the app locally
devtools::load_all()
BayesianNetwork()

# Regenerate documentation (NAMESPACE, man/*.Rd)
devtools::document()

# Run R CMD check
devtools::check()

# Build pkgdown site locally
pkgdown::build_site()
```

## Architecture

The package has two layers:

1.  **R package wrapper** (`R/`): Contains only `BayesianNetwork.R`,
    which exports the single
    [`BayesianNetwork()`](http://paulgovan.github.io/BayesianNetwork/reference/BayesianNetwork.md)
    function that calls
    `shiny::runApp(system.file("bn", package = "BayesianNetwork"))`.

2.  **Shiny application** (`inst/bn/`): The actual application logic
    split across four files:

    - `global.R` — Loads demo datasets from bnlearn (alarm,
      gaussian.test, hailfinder, insurance, learning.test), sets upload
      limits, defines introjs help text, enables URL bookmarking.
    - `ui.R` — shinydashboard UI with 5 tabs: Home, Structure,
      Parameters, Inference, Measures.
    - `server.R` — Reactive server logic: data loading, network
      structure learning (12 algorithms), parameter fitting,
      visualization, scoring, and inference.
    - `dependencies.R` — Explicit
      [`require()`](https://rdrr.io/r/base/library.html) calls for core
      dependencies.

## Data Flow

User uploads CSV or selects a demo dataset → structure learning
algorithm runs via bnlearn → parameters are fit → network is visualized
with networkD3 → inference queries run against the fitted model →
results displayed with plotly/heatmaply.

## Key Dependencies

- **bnlearn**: Core statistical engine for all structure learning,
  parameter fitting, and inference
- **networkD3**: Force-directed network graph visualization
- **shinydashboard + shinyWidgets + rintrojs + shinyAce**: UI components
  and help system
- **plotly + heatmaply + lattice**: Result visualization

## No Formal Tests

There is no testthat suite. Validation is done via `R CMD check` in CI
(`.github/workflows/R-CMD-check.yaml`) and by running the live app. The
`options(shiny.testmode=TRUE)` call in `server.R` is a placeholder — no
shinytest tests exist.

## CI/CD

- `R-CMD-check.yaml`: Runs `rcmdcheck` on macOS, Windows, Ubuntu
  (devel/release/oldrel) on every push/PR.
- `pkgdown.yaml`: Builds and deploys the documentation website to GitHub
  Pages.
- `pkgcheck.yaml`: Runs ropensci-review-tools static checks (manually
  triggered).
