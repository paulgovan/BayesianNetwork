#' Bayesian Network modeling and analysis.
#'
#' BayesianNetwork is a Shiny web application for Bayesian Network modeling and
#' analysis.
#' @import bnlearn
#' @import d3heatmap
#' @import lattice
#' @import networkD3
#' @import rhandsontable
#' @import shiny
#' @import shinydashboard
#' @export
BayesianNetwork <- function() {
  shiny::runApp(system.file('bn', package='BayesianNetwork'))
}
