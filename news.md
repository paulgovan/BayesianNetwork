# BayesianNetwork 0.4

## New features

- Added unit tests using `testthat` and `shinytest2` for improved
  reliability.
- Added download handlers for the adjacency matrix (CSV), fitted network
  (BIF format), and network parameters (RDS).
- Added inline help text describing each of the 12 supported structure
  learning algorithms.
- Added support for multi-node evidence in inference: users can now
  accumulate evidence across multiple nodes before querying.
- Added Gaussian network inference using likelihood-weighting sampling
  ([`bnlearn::cpdist()`](https://rdrr.io/pkg/bnlearn/man/cpquery.html)),
  with kernel density visualization of the posterior.

## Minor improvements and bug fixes

- Refactored `server.R` and `ui.R` for improved code quality.
- Updated R-CMD-check CI/CD workflow.
- Added `knitr` and `rmarkdown` vignette builder support.

# BayesianNetwork 0.3.2

## Minor improvements and bug fixes

- Updated contact info and citation.

# BayesianNetwork 0.2

## Minor improvements and bug fixes

- Parameter learning methods no longer return error.
- [`BayesianNetwork()`](http://paulgovan.github.io/BayesianNetwork/reference/BayesianNetwork.md)
  now has the same UI locally as on shinyapps.io.

# BayesianNetwork 0.1.5

## Minor changes

- Added orcid
- Minor UI improvements
