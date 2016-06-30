#' Bayesian Network modeling and analysis.
#'
#' BayesianNetwork is a Shiny web application for Bayesian Network modeling and
#' analysis.
#'
BayesianNetwork <- function() {
  shiny::runApp(system.file('bn', package='BayesianNetwork'))
}
