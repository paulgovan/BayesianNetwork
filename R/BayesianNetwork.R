#' Bayesian Network modeling and analysis.
#'
#' BayesianNetwork is a Shiny web application for Bayesian Network modeling and
#' analysis.
#' @import bnlearn
#' @import heatmaply
#' @import plotly
#' @import rintrojs
#' @import lattice
#' @import networkD3
#' @import shiny
#' @import shinyAce
#' @import shinydashboard
#' @import shinyWidgets
#' @export
#' @seealso \url{http://paulgovan.github.io/BayesianNetwork/}
#' @return A Shiny web application for Bayesian Network modeling and analysis.
#' @examples
#' if (interactive()) {
#'   BayesianNetwork()
#' }
BayesianNetwork <- function() {
  shiny::runApp(system.file("bn", package = "BayesianNetwork"))
}
