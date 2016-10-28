shinydashboard::dashboardPage(
  skin = "green",
  shinydashboard::dashboardHeader(
    title = "BayesianNetwork"
  ),
  shinydashboard::dashboardSidebar(
    shinydashboard::sidebarMenu(
      shinydashboard::menuItem(
        "Home",
        tabName = "dashboard",
        icon = shiny::icon("home")
      ),
      shinydashboard::menuItem(
        "Structure",
        icon = shiny::icon("globe"),
        tabName = "structure"
      ),
      shinydashboard::menuItem(
        "Parameters",
        tabName = "paramaters",
        icon = shiny::icon("bar-chart")
      ),
      shinydashboard::menuItem(
        "Inference",
        icon = shiny::icon("arrow-right"),
        tabName = "inference",
        badgeLabel = "Coming Soon",
        badgeColor = "yellow"
      ),
      shinydashboard::menuItem(
        "Measures",
        tabName = "measures",
        icon = shiny::icon("table"),
        badgeLabel = "New",
        badgeColor = "green"
      ),
      shinydashboard::menuItem(
        "Simulation",
        tabName = "simulation",
        icon = shiny::icon("random")
      ),
      br(),
      shinydashboard::menuItem("Help",
                               icon = icon("info-circle"),
                               href = "http://paulgovan.github.io/BayesianNetwork/"),
      shinydashboard::menuItem("Source Code",
                               icon = icon("code"),
                               href = "https://github.com/paulgovan/BayesianNetwork")
    )
  ),
  shinydashboard::dashboardBody(
    tags$head(
      tags$link(rel = "icon", type = "image/png", href = "favicon.png"),
      tags$title("BayesianNetwork")
    ),
    shinydashboard::tabItems(
      shinydashboard::tabItem(
        tabName = "dashboard",
        shiny::fluidRow(
          shinydashboard::box(
            title = "",
            status = "success",
            width = 8,
            shiny::img(
              src = "favicon.png",
              height = 50,
              width = 50
            ),
            shiny::h3("Welcome to BayesianNetwork!"),
            br(),
            shiny::h4(
              "BayesianNetwork is a ",
              shiny::a(href = 'http://shiny.rstudio.com', 'Shiny'),
              "web application for Bayesian network modeling and analysis, powered by",
              shiny::a(href = 'http://www.bnlearn.com', 'bnlearn'),
              'and',
              shiny::a(href = 'http://christophergandrud.github.io/networkD3/', 'networkD3'),
              '.'
            ),
            shiny::h4(
              "Click",
              shiny::em("Structure"),
              " in the sidepanel to get started"
            ),
            br(),
            shiny::h4(
              shiny::HTML('&copy'),
              '2016 By Paul Govan. ',
              shiny::a(href = 'http://www.apache.org/licenses/LICENSE-2.0', 'Terms of Use.')
            )
          ),
          shiny::uiOutput("nodesBox"),
          shiny::uiOutput("arcsBox")
        )
      ),
      shinydashboard::tabItem(tabName = "structure",
                              shiny::fluidRow(
                                shiny::column(
                                  width = 4,
                                  shinydashboard::box(
                                    title = "Network Input",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::helpText("Select a sample network or upload your Bayesian network data:"),
                                    shiny::selectInput(
                                      "net",
                                      h5("Bayesian Network:"),
                                      c(
                                        "Sample Discrete Network" = 1,
                                        "Sample Gaussian Network" = 2,
                                        "Sample Insurance Network" = 3,
                                        "Sample Hailfinder Network" = 4,
                                        "Upload your Bayesian network data" = 5
                                      )
                                    ),
                                    shiny::conditionalPanel(
                                      condition = "input.net == 5",
                                      shiny::p(
                                        'Note: your data should be structured as a ',
                                        shiny::a(href = 'http://en.wikipedia.org/wiki/Comma-separated_values', 'csv file')
                                      ),
                                      shiny::fileInput(
                                        'file',
                                        strong('File Input:'),
                                        accept = c(
                                          'text/csv',
                                          'text/comma-separated-values',
                                          'text/tab-separated-values',
                                          'text/plain',
                                          '.csv',
                                          '.tsv'
                                        )
                                      ),
                                      shiny::checkboxInput('header', 'Header', TRUE),
                                      shiny::selectInput(
                                        'sep',
                                        shiny::strong('Separator:'),
                                        c(
                                          Comma = ',',
                                          Semicolon =
                                            ';',
                                          Tab =
                                            '\t'
                                        ),
                                        ','
                                      )
                                    )
                                  ),
                                  shinydashboard::box(
                                    title = "Structural Learning",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::helpText("Select a structural learning algorithm:"),
                                    shiny::selectizeInput(
                                      "alg",
                                      shiny::h5("Learning Algorithm:"),
                                      choices = list(
                                        "Constraint-based Learning" =
                                          c(
                                            "Grow-Shrink" = "gs",
                                            "Incremental Association" = "iamb",
                                            "Fast IAMB" = "fast.iamb",
                                            "Inter IAMB" = "inter.iamb"
                                          ),
                                        "Score-based Learning" =
                                          c("Hill Climbing" = "hc",
                                            "Tabu" = "tabu"),
                                        "Hybrid Learning" =
                                          c(
                                            "Max-Min Hill Climbing" = "mmhc",
                                            "2-phase Restricted Maximization" = 'rsmax2'
                                          ),
                                        "Local Discovery Learning" =
                                          c(
                                            "Max-Min Parents and Children" = 'mmpc',
                                            "Semi-Interleaved HITON-PC" = "si.hiton.pc",
                                            "ARACNE" = "aracne",
                                            "Chow-Liu" = "chow.liu"
                                          )
                                      )
                                    )
                                  ),
                                  shinydashboard::box(
                                    title = "Network Score",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::selectInput(
                                      "type",
                                      h5("Network Score:"),
                                      c(
                                        "Log-Likelihood" = "loglik",
                                        "Akaike Information Criterion" = "aic",
                                        "Bayesian Information Criterion" = "bic",
                                        "Bayesian Equivalent" = "be"
                                      ),
                                      'loglik-g'
                                    ),
                                    shiny::verbatimTextOutput("score")
                                  )
                                ),
                                shiny::column(
                                  width = 8,
                                  shinydashboard::box(
                                    title = "Bayesian Network",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    networkD3::simpleNetworkOutput("netPlot")
                                  )
                                )
                              )),
      shinydashboard::tabItem(tabName = "paramaters",
                              shiny::fluidRow(
                                shiny::column(
                                  width = 4,
                                  shinydashboard::box(
                                    title = "Paramater Learning",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::helpText("Select a parameter learning method:"),
                                    shiny::selectInput(
                                      "met",
                                      shiny::h5("Learning Method:"),
                                      c(
                                        "Maximum Likelihood Estimation" = "mle",
                                        "Bayesian Estimation" = "bayes"
                                      )
                                    )
                                  ),
                                  shinydashboard::box(
                                    title = "Paramater Infographic",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    helpText("Select a paramater infographic:"),
                                    selectInput("param", label = h5("Paramater Infographic:"),
                                                ""),
                                    shiny::conditionalPanel(
                                      "input.param == 'barchart' || input.param == 'dotplot'",
                                      shiny::selectInput("Node", label = shiny::h5("Node:"), "")
                                    )
                                  )
                                  #                                    shinydashboard::box(
                                  #                                      title = "Expert Knowledge", status = "success", solidHeader = TRUE, collapsible = TRUE, width = NULL, height = 1000,
                                  #                                      shiny::selectInput("Node", label = h5("Node:"),
                                  #                                                  ""),
                                  #                                      shiny::helpText("Add expert knowledge to your model (Experimental):"),
                                  #                                      shiny::actionButton("saveBtn", "Save"),
                                  #                                      rhandsontable::rHandsontableOutput("hot")
                                  #                                    )
                                ),
                                shiny::column(
                                  width = 8,
                                  shinydashboard::box(
                                    title = "Network Paramaters",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::plotOutput("condPlot")
                                  )
                                )
                              )),
      shinydashboard::tabItem(tabName = "inference",
                              shiny::fluidRow(
                                shiny::column(
                                  width = 4,
                                  shinydashboard::box(
                                    title = "Evidence",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    helpText("Select evidence to add to the model:"),
                                    shiny::fluidRow(
                                      shiny::column(6,
                                                    shiny::selectInput(
                                                      "evidenceNode", label = shiny::h5("Evidence Node:"),
                                                      ""
                                                    )),
                                      shiny::column(6,
                                                    shiny::selectInput(
                                                      "evidence", label = shiny::h5("Evidence:"),
                                                      ""
                                                    )
                                      )
                                    )
                                  ),
                                  shinydashboard::box(
                                    title = "Event",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    helpText("Select an event of interest:"),
                                    shiny::selectInput("event", label = shiny::h5("Event Node:"),
                                                       "")
                                  )
                                ),
                                shiny::column(
                                  width = 8,
                                  shinydashboard::box(
                                    title = "Event Paramater",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::plotOutput("distPlot")
                                  )
                                )
                              )),
      shinydashboard::tabItem(
        tabName = "measures",
        shiny::fluidRow(
          shinydashboard::box(
            title = "Node Control",
            status = "success",
            collapsible = TRUE,
            width = 4,
            shiny::helpText("Select a node measure:"),
            shiny::selectInput(
              "nodeMeasure",
              h5("Node Measure:"),
              c(
                "Markov Blanket" = "mb",
                "Neighborhood" = "nbr",
                "Parents" = "parents",
                "Children" = "children",
                "In Degree" = "in.degree",
                "Out Degree" = "out.degree",
                "Incident Arcs" = "incident.arcs",
                "Incoming Arcs" = "incoming.arcs",
                "Outgoing Arcs" = "outgoing.arcs"
              )
            ),
            shiny::selectInput("nodeNames", label = shiny::h5("Node:"),
                               "")
          ),
          shinydashboard::box(
            title = "Node Measure",
            status = "success",
            collapsible = TRUE,
            width = 8,
            shiny::verbatimTextOutput("nodeText")
          )
        ),
        fluidRow(
          shinydashboard::box(
            title = "Network Control",
            status = "success",
            collapsible = TRUE,
            width = 4,
            shiny::helpText("Select a network measure:"),
            shiny::selectInput(
              "dendrogram",
              h5("Dendrogram:"),
              c(
                "Both" = "both",
                "Row" = "row",
                "Column" = "column",
                "None" = "none"
              )
            )
          ),
          shinydashboard::box(
            title = "Network Measure",
            status = "success",
            collapsible = TRUE,
            width = 8,
            d3heatmap::d3heatmapOutput("netTable")
          )
        )
      ),
      shinydashboard::tabItem(tabName = "simulation",
                              shiny::fluidRow(
                                shiny::column(
                                  width = 4,
                                  shinydashboard::box(
                                    title = "Network Simulation",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::helpText(
                                      "Simulate random data from your network and download for future use:"
                                    ),
                                    shiny::numericInput(
                                      "n",
                                      label = h5("N (Sample Size):"),
                                      value = 100,
                                      min = 0
                                    ),
                                    shiny::downloadButton('downloadData', 'Download')
                                  )
                                )
                              ))
    )
  )
)
