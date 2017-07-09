code =
  '## Sample Code
Here is some sample markdown to help illustrate the editor.

### Get some sample data and show the first few values
### Use `dat()` to get the active data set
```{r}
dat <- learning.test
head(dat)
```

### Learn the structure of the network
```{r}
dag <- bnlearn::cextend(bnlearn::gs(dat))
```

### Plot the force directed network
```{r}
networkData <- data.frame(bnlearn::arcs(dag))

networkD3::simpleNetwork(
  networkData,
  Source = "from",
  Target = "to"
)
```

### Print the network score
```{r}
bnlearn::score(dag, dat)
```

### Fit the model parameters and show the CPT for node A
```{r}
fit <- bnlearn::bn.fit(dag, dat)
fit$A
```

### Plot the model parameters for node A
```{r}
bnlearn::bn.fit.barchart(fit[["A"]])
```

### Get the Markov blanket for node A
```{r}
bnlearn::mb(dag, "A")
```

### Plot a d3 heatmap of the adjacency matrix
```{r}
d3heatmap(
  bnlearn::amat(dag),
  symm = TRUE,
  colors = "Blues",
  opacity = 0.75
)
````

### Generate some random data from the network and show the first few values
```{r}
simData <- bnlearn::rbn(fit, n = 100, dat)
head(simData)
```

```{r}
# Put your own code here...
'

# Green dashboard page
shinydashboard::dashboardPage(
  skin = "green",

  # Dashboard header and title
  shinydashboard::dashboardHeader(
    title = "BayesianNetwork"
  ),

  # Dashboard sidebar
  shinydashboard::dashboardSidebar(

    # Sidebar menu
    shinydashboard::sidebarMenu(
      id = "sidebarMenu",

      # Home menu item
      shinydashboard::menuItem(
        "Home",
        tabName = "home",
        icon = shiny::icon("home")
      ),

      # Structure menu item
      shinydashboard::menuItem(
        "Structure",
        icon = shiny::icon("globe"),
        tabName = "structure"
      ),

      # Parameters menu item
      shinydashboard::menuItem(
        "Parameters",
        tabName = "paramaters",
        icon = shiny::icon("bar-chart")
      ),

      # Inference menu item
      shinydashboard::menuItem(
        "Inference",
        icon = shiny::icon("arrow-right"),
        tabName = "inference"
      ),

      # Measures menu item
      shinydashboard::menuItem(
        "Measures",
        tabName = "measures",
        icon = shiny::icon("table")
      ),

      # Editor menu item
      shinydashboard::menuItem(
        "Editor",
        tabName = "editor",
        icon = shiny::icon("code"),
        badgeLabel = "New",
        badgeColor = "green"
      ),
      br(),

      # Help page link
      shinydashboard::menuItem("Help",
                               icon = icon("info-circle"),
                               href = "http://paulgovan.github.io/BayesianNetwork/"),

      # Source code link
      shinydashboard::menuItem("Source Code",
                               icon = icon("github"),
                               href = "https://github.com/paulgovan/BayesianNetwork"),

      # Bookmark button
      shiny::br(),
      shiny::bookmarkButton(id = "bookmark"),
      tags$style(type='text/css', "#bookmark { display: block; margin: 0 auto; }")

    )
  ),

  # Dashboard body
  shinydashboard::dashboardBody(
    id = "dashboardBody",

    # Add favicon and title to header
    tags$head(
      tags$link(rel = "icon", type = "image/png", href = "favicon.png"),
      tags$title("BayesianNetwork")
    ),

    # Include introjs UI
    rintrojs::introjsUI(),

    # Dashboard tab items
    shinydashboard::tabItems(

      # Home tab item
      shinydashboard::tabItem(
        tabName = "home",
        shiny::fluidRow(

          # Welcome box
          shinydashboard::box(
            title = "",
            status = "success",
            width = 8,
            shiny::img(src = "favicon.png",
                       height = 50,
                       width = 50
            ),
            shiny::h2("BayesianNetwork"),
            shiny::h4("Bayesian Network Modeling and Analysis"),
            br(),
            shiny::h4("BayesianNetwork is a ",
                      shiny::a(href = 'http://shiny.rstudio.com', 'Shiny'),
                      "web application for Bayesian network modeling and analysis, powered by",
                      shiny::a(href = 'http://www.bnlearn.com', 'bnlearn'),
                      'and',
                      shiny::a(href = 'http://christophergandrud.github.io/networkD3/', 'networkD3'),
                      '.'
            ),
            shiny::h4("Click",
                      shiny::a("Structure", href="#shiny-tab-structure", "data-toggle" = "tab"),
                      " in the sidepanel to get started."
            ),
            br(),
            shiny::h4(shiny::HTML('&copy'),
                      '2016 By Paul Govan. ',
                      shiny::a(href = 'http://www.apache.org/licenses/LICENSE-2.0', 'Terms of Use.')
            ),
            br(),
            # Add introjs btn
            shiny::actionButton("homeIntro", "Show me how it works"),
            tags$style(type='text/css', "#homeIntro { display: block; margin: 0 auto; }")
          ),

          # Nodes and arcs value boxes
          shiny::uiOutput("nodesBox"),
          shiny::uiOutput("arcsBox")
        )
      ),

      # Structure tab item
      shinydashboard::tabItem(tabName = "structure",
                              shiny::fluidRow(
                                shiny::column(
                                  width = 4,

                                  # Network input box
                                  shinydashboard::box(
                                    title = "Data Input",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::helpText("Select a sample network or upload your Bayesian network data:"),

                                    # Demo network input select
                                    shiny::selectInput(
                                      inputId = "net",
                                      h5("Bayesian Network:"),
                                      c("Sample Discrete Network" = 1,
                                        "Sample Gaussian Network" = 2,
                                        "Alarm Network" = 3,
                                        "Insurance Network" = 4,
                                        "Hailfinder Network" = 5,
                                        "Upload your Bayesian network data" = 6
                                      )
                                    ),

                                    # Conditional panel for file input selection
                                    shiny::conditionalPanel(
                                      condition = "input.net == 6",
                                      shiny::p('Note: your data should be structured as a ',
                                               shiny::a(href = 'http://en.wikipedia.org/wiki/Comma-separated_values', 'csv file')
                                      ),

                                      # File input
                                      shiny::fileInput(
                                        'file',
                                        strong('File Input:'),
                                        accept = c('text/csv',
                                                   'text/comma-separated-values',
                                                   'text/tab-separated-values',
                                                   'text/plain',
                                                   '.csv',
                                                   '.tsv'
                                        )
                                      ),

                                      # Header T/F checkbox
                                      shiny::checkboxInput('header', 'Header', TRUE),

                                      # Separator input select
                                      shiny::selectInput(
                                        'sep',
                                        shiny::strong('Separator:'),
                                        c(Comma = ',',
                                          Semicolon = ';',
                                          Tab = '\t'
                                        ), ','
                                      )
                                    )
                                  ),

                                  # Structural learning box
                                  shinydashboard::box(
                                    title = "Structural Learning",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::helpText("Select a structural learning algorithm:"),

                                    # Structural learning algorithm input select
                                    shiny::selectizeInput(
                                      inputId = "alg",
                                      shiny::h5("Learning Algorithm:"),
                                      choices = list(
                                        "Constraint-based Learning" =
                                          c("Grow-Shrink" = "gs",
                                            "Incremental Association" = "iamb",
                                            "Fast IAMB" = "fast.iamb",
                                            "Inter IAMB" = "inter.iamb"
                                          ),
                                        "Score-based Learning" =
                                          c("Hill Climbing" = "hc",
                                            "Tabu" = "tabu"),
                                        "Hybrid Learning" =
                                          c("Max-Min Hill Climbing" = "mmhc",
                                            "2-phase Restricted Maximization" = 'rsmax2'
                                          ),
                                        "Local Discovery Learning" =
                                          c("Max-Min Parents and Children" = 'mmpc',
                                            "Semi-Interleaved HITON-PC" = "si.hiton.pc",
                                            "ARACNE" = "aracne",
                                            "Chow-Liu" = "chow.liu"
                                          )
                                      )
                                    )
                                  ),

                                  # Network score box
                                  shinydashboard::box(
                                    title = "Network Score",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,

                                    # Network score function input select
                                    shiny::selectInput(
                                      "type",
                                      h5("Network Score:"),
                                      c("Log-Likelihood" = "loglik",
                                        "Akaike Information Criterion" = "aic",
                                        "Bayesian Information Criterion" = "bic",
                                        "Bayesian Equivalent" = "be"
                                      ), 'loglik-g'
                                    ),

                                    # Network score output
                                    shiny::verbatimTextOutput("score")
                                  )
                                ),
                                shiny::column(
                                  width = 8,

                                  # Bayesian network box
                                  shinydashboard::box(
                                    title = "Bayesian Network",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,

                                    # d3 force directed network
                                    networkD3::simpleNetworkOutput("netPlot")
                                  )
                                )
                              ),

                              # Add introjs btn
                              shiny::actionButton("structureIntro", "Show me how")
      ),

      # Paramaters tab item
      shinydashboard::tabItem(tabName = "paramaters",
                              shiny::fluidRow(
                                shiny::column(
                                  width = 4,

                                  # Paramater learning box
                                  shinydashboard::box(
                                    title = "Paramater Learning",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    shiny::helpText("Select a parameter learning method:"),

                                    # Paramater learning method input select
                                    shiny::selectInput(
                                      "met",
                                      shiny::h5("Learning Method:"),
                                      c("Maximum Likelihood Estimation" = "mle",
                                        "Bayesian Estimation" = "bayes"
                                      )
                                    ),

                                    shiny::helpText("Select an imaginary sample size:"),

                                    # Imaginary Sample Size for illustrative purposes
                                    shiny::numericInput(
                                      "iss",
                                      shiny::h5("Sample Size:"),
                                      value = 10,
                                      min = 1
                                    )
                                  ),

                                  # Paramater infographic box
                                  shinydashboard::box(
                                    title = "Paramater Graphic",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    helpText("Select a paramater infographic:"),

                                    # Paramater infographic input select
                                    selectInput("param", label = h5("Paramater Infographic:"),
                                                ""),

                                    # Conditional panel for discrete data
                                    shiny::conditionalPanel(
                                      "input.param == 'barchart' || input.param == 'dotplot'",

                                      # Node input select
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

                                  # Network paramaters box
                                  shinydashboard::box(
                                    title = "Network Paramaters",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,

                                    # Conditional PD plot
                                    shiny::plotOutput("condPlot")
                                  )
                                )
                              ),

                              # Add introjs btn
                              shiny::actionButton("parametersIntro", "Show me how")
      ),

      # Inference tab item
      shinydashboard::tabItem(tabName = "inference",
                              shiny::fluidRow(
                                shiny::column(
                                  width = 4,

                                  # Evidence box
                                  shinydashboard::box(
                                    title = "Evidence",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    helpText("Select evidence to add to the model:"),
                                    shiny::fluidRow(
                                      shiny::column(6,

                                                    # Evidence node input select
                                                    shiny::selectInput(
                                                      "evidenceNode", label = shiny::h5("Evidence Node:"),
                                                      ""
                                                    )),
                                      shiny::column(6,

                                                    # Conditional panel for discrete data
                                                    shiny::conditionalPanel(
                                                      "input.param == 'barchart' || input.param == 'dotplot'",

                                                      # Evidence input select
                                                      shiny::selectInput(
                                                        "evidence", label = shiny::h5("Evidence:"),
                                                        ""
                                                      )
                                                    )
                                      )
                                    )
                                  ),

                                  # Event box
                                  shinydashboard::box(
                                    title = "Event",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,
                                    helpText("Select an event of interest:"),

                                    # Event node input select
                                    shiny::selectInput("event", label = shiny::h5("Event Node:"),
                                                       "")
                                  )
                                ),
                                shiny::column(
                                  width = 8,

                                  # Event paramater box
                                  shinydashboard::box(
                                    title = "Event Paramater",
                                    status = "success",
                                    collapsible = TRUE,
                                    width = NULL,

                                    # Event conditional PD plot
                                    shiny::plotOutput("distPlot")
                                  )
                                )
                              ),

                              # Add introjs btn
                              shiny::actionButton("inferenceIntro", "Show me how")
      ),

      # Measures tab item
      shinydashboard::tabItem(tabName = "measures",
                              shiny::fluidRow(

                                # Measure controls box
                                shinydashboard::box(
                                  title = "Controls",
                                  status = "success",
                                  collapsible = TRUE,
                                  width = 4,
                                  shiny::helpText("Select a node measure:"),

                                  # Node measure input select
                                  shiny::selectInput(
                                    "nodeMeasure",
                                    h5("Node Measure:"),
                                    c("Markov Blanket" = "mb",
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

                                  # Node input select
                                  shiny::selectInput("nodeNames", label = shiny::h5("Node:"),
                                                     ""),
                                  shiny::helpText("Select a network measure:"),

                                  # Network measure input select
                                  shiny::selectInput(
                                    "dendrogram",
                                    h5("Dendrogram:"),
                                    c("Both" = "both",
                                      "Row" = "row",
                                      "Column" = "column",
                                      "None" = "none"
                                    )
                                  )
                                ),

                                # Node measure box
                                shinydashboard::box(
                                  title = "Node Measure",
                                  status = "success",
                                  collapsible = TRUE,
                                  width = 8,

                                  # Node measure output
                                  shiny::verbatimTextOutput("nodeText")
                                ),

                                # Network measure box
                                shinydashboard::box(
                                  title = "Adjacency Matrix",
                                  status = "success",
                                  collapsible = TRUE,
                                  width = 8,

                                  # d3 heatmap
                                  d3heatmap::d3heatmapOutput("netTable")
                                )
                              ),

                              # Add introjs btn
                              shiny::actionButton("measuresIntro", "Show me how")
      ),

      # Editor tab item
      shinydashboard::tabItem(tabName = "editor",
                              shiny::fluidRow(
                                column(6,

                                       # shinyAce editor box
                                       shinydashboard::box(
                                         title = "Editor",
                                         status = "success",
                                         collapsible = TRUE,
                                         width = 12,

                                         # shinyAce Editor
                                         shinyAce::aceEditor("rmd", mode = "markdown", value = code),
                                         shiny::actionButton("eval", "Run")
                                       ),

                                       # Add introjs btn
                                       shiny::actionButton("editorIntro", "Show me how")
                                ),
                                column(6,

                                       # knitr output
                                       shiny::htmlOutput("knitr")
                                )
                              )
      )
    )
  )
)
