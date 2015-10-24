# Copyright 2015 Paul Govan

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

library(shiny)
library(shinyapps)
library(shinydashboard)
library(networkD3)
library(rhandsontable)
library(d3heatmap)

dashboardPage(skin="green",
              dashboardHeader(title = "BayesianNetwork",
                              dropdownMenu(type = "messages",
                                           messageItem(
                                             from = "Support",
                                             message = "Welcome to BayesianNetwork!"
                                           )
                              )),
              dashboardSidebar(
                sidebarMenu(
                  menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
                  menuItem("Structure", icon = icon("globe"), tabName = "structure",
                           badgeLabel = "New", badgeColor = "green"),
                  menuItem("Parameters", tabName = "paramaters", icon = icon("bar-chart")),
                  menuItem("Inference", icon = icon("arrow-right"), tabName = "inference",
                           badgeLabel = "Coming Soon", badgeColor = "yellow"),
                  menuItem("Measures", tabName = "measures", icon = icon("table")),
                  menuItem("Simulation", tabName = "simulation", icon = icon("random"))
                  
                )),
              dashboardBody(
                tags$head(tags$link(rel = "icon", type = "image/png", href = "favicon.png"),
                          tags$title("BayesianNetwork")),
                tabItems(
                  tabItem(tabName = "dashboard",
                          fluidRow(
                            box(
                              title = "BayesianNetwork", status = "success", solidHeader = TRUE, width = 8,
                              img(src = "favicon.png", height = 50, width = 50),
                              h3("Welcome to BayesianNetwork!"),
                              h4("BayesianNetwork is a ",
                                 a(href = 'http://shiny.rstudio.com', 'Shiny'),
                                 "web application for Bayesian network modeling and analysis, powered by",
                                 a(href = 'http://www.bnlearn.com', 'bnlearn'),
                                 'and',
                                 a(href = 'http://christophergandrud.github.io/networkD3/', 'networkD3')),
                              h4("Click", em("Structure"), " in the sidepanel to get started"),
                              
                              h4('Copyright 2015 By Paul Govan. ',
                                 a(href = 'http://www.apache.org/licenses/LICENSE-2.0', 'Terms of Use.'))
                            ),
                            uiOutput("nodesBox"),
                            uiOutput("arcsBox")
                          )
                  ),
                  tabItem(tabName = "structure",
                          fluidRow(
                            column(width = 4,
                                   box(
                                     title = "Network Input", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                                     helpText("Select a sample network or upload your Bayesian network data:"),
                                     selectInput("net", h5("Bayesian Network:"), 
                                                 c("Sample Discrete Network"=1,
                                                   "Sample Gaussian Network"= 2,
                                                   "Sample Insurance Network"=3,
                                                   "Sample Hailfinder Network"=4,
                                                   "Upload your Bayesian network data"=5
                                                 )),
                                     conditionalPanel(condition = "input.net == 5",
                                                      p('Note: your data should be structured as a ',
                                                        a(href = 'http://en.wikipedia.org/wiki/Comma-separated_values', 'csv file')),
                                                      fileInput('file', strong('File Input:'),
                                                                accept = c(
                                                                  'text/csv',
                                                                  'text/comma-separated-values',
                                                                  'text/tab-separated-values',
                                                                  'text/plain',
                                                                  '.csv',
                                                                  '.tsv'
                                                                )
                                                      ),
                                                      checkboxInput('header', 'Header', TRUE),
                                                      selectInput('sep', strong('Separator:'),
                                                                  c(Comma=',',
                                                                    Semicolon=';',
                                                                    Tab='\t'),
                                                                  ','))
                                   ),
                                   box(
                                     title = "Structural Learning", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                                     helpText("Select a structural learning algorithm:"),
                                     selectizeInput("alg", h5("Learning Algorithm:"), 
                                                    choices = list("Constraint-based Learning"=
                                                                     c("Grow-Shrink"="gs",
                                                                       "Incremental Association"="iamb",
                                                                       "Fast IAMB"="fast.iamb",
                                                                       "Inter IAMB"="inter.iamb"),
                                                                   "Score-based Learning"=
                                                                     c("Hill Climbing"="hc",
                                                                       "Tabu"="tabu"),
                                                                   "Hybrid Learning"=
                                                                     c("Max-Min Hill Climbing"="mmhc",
                                                                       "2-phase Restricted Maximization"='rsmax2'),
                                                                   "Local Discovery Learning"=
                                                                     c("Max-Min Parents and Children"='mmpc',
                                                                       "Semi-Interleaved HITON-PC"="si.hiton.pc",
                                                                       "ARACNE"="aracne", 
                                                                       "Chow-Liu"="chow.liu"))
                                     )
                                   ),
                                   box(
                                     title = "Network Score", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                                     selectInput("type", h5("Network Score:"),
                                                 c("Log-Likelihood"="loglik",
                                                   "Akaike Information Criterion"="aic",
                                                   "Bayesian Information Criterion"="bic",
                                                   "Bayesian Equivalent"="be"),
                                                 'loglik-g'),
                                     verbatimTextOutput("score")
                                   )
                            ),
                            column(width = 8,
                                   box(
                                     title = "Bayesian Network", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                                     simpleNetworkOutput("netPlot")
                                   )
                            )
                          )
                  ),
                  tabItem(tabName = "paramaters",
                          fluidRow(
                            column(width = 4,
                                   box(
                                     title = "Paramater Learning", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                                     helpText("Select a parameter learning method:"),
                                     selectInput("met", h5("Learning Method:"), 
                                                 c("Maximum Likelihood Estimation"="mle",
                                                   "Bayesian Estimation"="bayes"
                                                 ))
                                   ),
                                   box(
                                     title = "Paramater Infographic", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                                     helpText("Select a paramater infographic:"),
                                     selectInput("param", label = h5("Paramater Infographic:"),
                                                 ""),
                                     conditionalPanel("input.param == 'barchart' || input.param == 'dotplot'",
                                                      selectInput("Node", label = h5("Node:"), ""))
                                   )
                                   #                                    box(
                                   #                                      title = "Expert Knowledge", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL, height = 1000,
                                   #                                      selectInput("Node", label = h5("Node:"),
                                   #                                                  ""),
                                   #                                      helpText("Add expert knowledge to your model (Experimental):"),
                                   #                                      actionButton("saveBtn", "Save"),
                                   #                                      rHandsontableOutput("hot")                                   
                                   #                                    )
                            ),
                            column(width = 8,
                                   box(
                                     title = "Network Paramaters", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                                     plotOutput("condPlot")                                   )
                            )
                          )
                  ),
                  #                   tabItem(tabName = "inference",
                  #                           fluidRow(
                  #                             column(width = 4,
                  #                                    box(
                  #                                      title = "Inference Method", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                  #                                      helpText("Select an inference method:"),
                  #                                      selectInput("inf", h5("Inference Method:"), 
                  #                                                  c("logic sampling"="ls",
                  #                                                    "likelihood weighting"="lw"
                  #                                                  ))
                  #                                    ),
                  #                                    box(
                  #                                      title = "Evidence", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                  #                                      fluidRow(
                  #                                        column(6,
                  #                                               selectInput("evidence", label = h5("Evidence Node:"),
                  #                                                           "")
                  #                                        ),
                  #                                        column(6,
                  #                                               numericInput("val", label = h5("Evidence:"), value = 1)
                  #                                        )
                  #                                      )
                  #                                    ),
                  #                                    box(
                  #                                      title = "Event", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                  #                                      selectInput("event", label = h5("Event Node:"),
                  #                                                  "")                              
                  #                                    )
                  #                             ),
                  #                             column(width = 8,
                  #                                    box(
                  #                                      title = "Event Paramater", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                  #                                      textOutput("distPrint")
                  #                                    )
                  #                             )
                  #                           )
                  #                   ),
                  tabItem(tabName = "measures",
                          fluidRow(
                            box(
                              title = "Node Control", status = "success", solidHeader = TRUE, collapsible = TRUE, width = 4,
                              helpText("Select a node measure:"),
                              selectInput("nodeMeasure", h5("Node Measure:"), 
                                          c("Markov Blanket"="mb",
                                            "Neighborhood"="nbr",
                                            "Parents"="parents",
                                            "Children"="children", 
                                            "In Degree"="in.degree",
                                            "Out Degree"="out.degree",
                                            "Incident Arcs"="incident.arcs",
                                            "Incoming Arcs"="incoming.arcs",
                                            "Outgoing Arcs"="outgoing.arcs"
                                          )),
                              selectInput("nodeNames", label = h5("Node:"),
                                          "")
                            ),
                            box(
                              title = "Node Measure", status = "success", solidHeader = TRUE, collapsible = TRUE, width = 8,
                              verbatimTextOutput("nodeText")
                            )
                          ),
                          fluidRow(
                            box(
                              title = "Network Control", status = "success", solidHeader = TRUE, collapsible = TRUE, width = 4,
                              helpText("Select a network measure:"),
                              selectInput("dendrogram", h5("Dendrogram:"), 
                                          c("Both"="both",
                                            "Row"="row",
                                            "Column"="column",
                                            "None"="none"
                                          ))
                            ),
                            box(
                              title = "Network Measure", status = "success", solidHeader = TRUE, collapsible = TRUE, width = 8,
                              d3heatmapOutput("netTable")
                            )
                          )
                  ),
                  tabItem(tabName = "simulation",
                          fluidRow(
                            column(width = 4,
                                   box(
                                     title = "Network Simulation", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL,
                                     helpText("Simulate random data from your network and download for future use:"),
                                     numericInput("n", label = h5("N (Sample Size):"), value = 100, min = 0),
                                     downloadButton('downloadData', 'Download')
                                   )
                            )
                          )
                  )
                )
              )
)
