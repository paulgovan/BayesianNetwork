#' Bayesian Network modeling and analysis.
#'
#' BayesianNetwork is a Shiny web application for Bayesian Network modeling and
#' analysis.
#' @import bnlearn
#' @import d3heatmap
#' @import rintrojs
#' @import lattice
#' @import networkD3
#' @import shiny
#' @import shinyAce
#' @import shinydashboard
#' @export
#' @seealso \url{http://paulgovan.github.io/BayesianNetwork/}
#' @examples
#' if (interactive()) {
#'   BayesianNetwork()
#' }
BayesianNetwork <- function() {
  shiny::runApp(system.file('bn', package = 'BayesianNetwork'))
}
