# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 10 * 1024 ^ 2)

# Load data
data(learning.test, package = "bnlearn")
data(gaussian.test, package = "bnlearn")
data(insurance, package = "bnlearn")
data(hailfinder, package = "bnlearn")

#' @import bnlearn
#' @import shiny
#' @import shinydashboard
# Define required server logic
shinyServer(function(input, output, session) {
  # Get data
  data <- shiny::reactive({
    if (input$net == 1) {
      data <- learning.test
    } else if (input$net == 2) {
      data <- gaussian.test
    } else if (input$net == 3) {
      data <- insurance
    } else if (input$net == 4) {
      data <- hailfinder
    } else  {
      # Get uploaded file
      inFile <- input$file
      if (is.null(inFile))
        return(NULL)
      data <- read.csv(inFile$datapath,
                       header = input$header,
                       sep = input$sep)
    }
  })

  # Learn the structure of the network
  dag <- shiny::reactive({
    if (is.null(data()))
      return(NULL)
    if (input$alg == "gs") {
      dag <- bnlearn::cextend(bnlearn::gs(data()), strict = FALSE)
    } else if (input$alg == "iamb") {
      dag <- bnlearn::cextend(bnlearn::iamb(data()), strict = FALSE)
    } else if (input$alg == "fast.iamb") {
      dag <- bnlearn::cextend(bnlearn::fast.iamb(data()), strict = FALSE)
    } else if (input$alg == "inter.iamb") {
      dag <- bnlearn::cextend(bnlearn::inter.iamb(data()), strict = FALSE)
    } else if (input$alg == "hc") {
      dag <- bnlearn::cextend(bnlearn::hc(data()), strict = FALSE)
    } else if (input$alg == "tabu") {
      dag <- bnlearn::cextend(bnlearn::tabu(data()), strict = FALSE)
    } else if (input$alg == "mmhc") {
      dag <- bnlearn::cextend(bnlearn::mmhc(data()), strict = FALSE)
    } else if (input$alg == "rsmax2") {
      dag <- bnlearn::cextend(bnlearn::rsmax2(data()), strict = FALSE)
    } else if (input$alg == "mmpc") {
      dag <- bnlearn::cextend(bnlearn::mmpc(data()), strict = FALSE)
    } else if (input$alg == "si.hiton.pc") {
      dag <- bnlearn::cextend(bnlearn::si.hiton.pc(data()), strict = FALSE)
    } else if (input$alg == "aracne") {
      dag <- bnlearn::cextend(bnlearn::aracne(data()), strict = FALSE)
    } else if (input$alg == "chow.liu") {
      dag <- bnlearn::cextend(bnlearn::chow.liu(data()), strict = FALSE)
    }
  })

  # Create the nodes box
  output$nodesBox <- shiny::renderUI({
    if (is.null(data()))
      return(NULL)
    nodes <- bnlearn::nnodes(dag())
    shinydashboard::valueBox(nodes,
                             "Nodes",
                             icon = shiny::icon("circle"),
                             color = "blue")
  })

  # Create the arcs box
  output$arcsBox <- renderUI({
    if (is.null(data()))
      return(NULL)
    arcs <- bnlearn::narcs(dag())
    shinydashboard::valueBox(arcs,
                             "Arcs",
                             icon = shiny::icon("arrow-right"),
                             color = "green")
  })

  # Plot the network
  output$netPlot <- networkD3::renderSimpleNetwork({
    if (is.null(data()))
      return(NULL)
    networkData <- data.frame(bnlearn::arcs(dag()))
    networkD3::simpleNetwork(
      networkData,
      Source = "from",
      Target = "to",
      zoom = TRUE
    )
  })

  # Print the network score
  output$score <- shiny::renderText({
    if (bnlearn::directed(dag())) {
      if (is.numeric(data()[, 1])) {
        if (input$type == "loglik") {
          bnlearn::score(dag(), data(), type = "loglik-g")
        } else if (input$type == "aic") {
          bnlearn::score(dag(), data(), type = "aic-g")
        } else if (input$type == "bic") {
          bnlearn::score(dag(), data(), type = "bic-g")
        } else {
          bnlearn::score(dag(), data(), type = "bge")
        }
      }
      else {
        if (input$type == "loglik") {
          bnlearn::score(dag(), data(), type = "loglik")
        } else if (input$type == "aic") {
          bnlearn::score(dag(), data(), type = "aic")
        } else if (input$type == "bic") {
          bnlearn::score(dag(), data(), type = "bic")
        } else {
          bnlearn::score(dag(), data(), type = "bde")
        }
      }
    } else
      shiny::validate(
        shiny::need(
          try(score != "")
          ,
          "Make sure your network is completely directed in order to view your network's score..."
        )
      )
  })

  # Fit the model parameters
  fit <- shiny::reactive({
    if (is.null(data()))
      return(NULL)
    if (bnlearn::directed(dag())) {
      fit <- bnlearn::bn.fit(dag(), data(), method = input$met)
    }
  })

  # # Create data frame for selected paramater
  # param <- shiny::reactive({
  #   param <- data.frame(coef(fit()[[input$Node]]))
  #   if (is.numeric(data()[,1])) {
  #     colnames(param) <- "Param"
  #     param <- cbind(param = rownames(param), param)
  #     param[,"Param"] <- round(param[,"Param"], digits = 3)
  #     param <- transform(param, Param = as.numeric(Param))
  #   } else {
  #     param[,"Freq"] <- round(param[,"Freq"], digits = 3)
  #     param <- transform(param, Freq = as.numeric(Freq))
  #   }
  # })

  # # Plot Handsontable for selected parameter
  # values = shiny::reactiveValues()
  # setHot = function(x) values[["hot"]] <<- x
  # output$hot = rhandsontable::renderRHandsontable({
  #   if (!is.null(input$hot)) {
  #     DF = rhandsontable::hot_to_r(input$hot)
  #   } else {
  #     DF = param()
  #   }
  #   if (is.numeric(data()[,1])) {
  #     col <- "Param"
  #   } else {
  #     col <- "Freq"
  #   }
  #   setHot(DF)
  #   rhandsontable::rhandsontable(DF, readOnly = TRUE, rowHeaders = NULL) %>%
  #     rhandsontable::hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
  #     rhandsontabl::hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE) %>%
  #     rhandsontable::hot_col(col, readOnly = FALSE)
  # })
  #
  # # Add expert knowledge to the model
  # expertFit <- shiny::reactive({
  #   if (!is.null(values[["hot"]])) {
  #     expertFit <- fit()
  #     temp <- data.frame(values[["hot"]])
  #     if (is.numeric(data()[,1])) {
  #       stdev <- as.numeric(fit()[[input$Node]]["sd"])
  #       expertFit[[input$Node]] <- list(coef = as.numeric(temp[,"Param"]), sd = stdev)
  #     } else {
  #       cpt <- coef(expertFit()[[input$Node]])
  #       cpt[1:length(param()[,"Freq"])] <- as.numeric(temp[,"Freq"])
  #       expertFit[[input$Node]] <- cpt
  #     }
  #   } else {
  #     expertFit <- fit()
  #   }
  # })

  # Set the paramater graphic options
  graphic <- shiny::reactive({
    if (is.numeric(data()[, 1])) {
      graphic <- c("Histogram" = "histogram",
                   "XY Plot" = "xyplot",
                   "QQ Plot" = "qqplot")
    } else {
      graphic <- c("Bar Chart" = "barchart",
                   "Dot Plot" = "dotplot")
    }
  })

  shiny::observe({
    shiny::updateSelectInput(session, "param", choices = graphic())
  })
  shiny::observe({
    shiny::updateSelectInput(session, "Node", choices = colnames(data()))
  })

  # Plot the model parameters
  output$condPlot <- shiny::renderPlot({
    if (is.null(data()))
      return(NULL)
    if (bnlearn::directed(dag())) {
      if (input$param == "histogram") {
        bnlearn::bn.fit.histogram(fit())
      } else if (input$param == "xyplot") {
        bnlearn::bn.fit.xyplot(fit())
      } else if (input$param == "qqplot") {
        bnlearn::bn.fit.qqplot(fit())
      } else if (input$param == "barchart") {
        bnlearn::bn.fit.barchart(fit()[[input$Node]])
      } else if (input$param == "dotplot") {
        bnlearn::bn.fit.dotplot(fit()[[input$Node]])
      }
    } else
      shiny::validate(
        shiny::need(
          try(condPlot != "")
          ,
          "Make sure your network is completely directed in order to view the paramater infographics..."
        )
      )
  })

  shiny::observe({
    shiny::updateSelectInput(session, "evidence", choices = names(data()))
  })

  shiny::observe({
    shiny::updateSelectInput(session, "event", choices = names(data()))
  })

  #   # Perform Bayesian Inference based on evidence and print results
  #   output$distPrint <- shiny::renderPrint({
  #     if (is.null(data()))
  #       return(NULL)
  #     if (bnlearn::directed(dag())) {
  #       fitted = fit()
  #       evidence = as.vector(input$evidence)
  #       value = as.vector(input$val)
  #       node.dist <- bnlearn::cpdist(fitted, input$event, eval(parse(text = paste("(", evidence, "=='",
  #                                                                        sapply(value, as.numeric), "')",
  #                                                                        sep = "", collapse = " & "))), method = input$inf)
  #     } else
  #       shiny::validate(
  #         shiny::need(try(distPlot != ""), "Make sure your network is completely directed in order to perform Bayesian inference...")
  #       )
  #   })

  shiny::observe({
    shiny::updateSelectInput(session, "nodeNames", choices = colnames(data()))
  })

  # Show node measures
  output$nodeText <- shiny::renderText({
    if (is.null(data()))
      return(NULL)
    if (input$nodeMeasure == "mb") {
      bnlearn::mb(dag(), input$nodeNames)
    } else if (input$nodeMeasure == "nbr") {
      bnlearn::nbr(dag(), input$nodeNames)
    } else if (input$nodeMeasure == "parents") {
      bnlearn::parents(dag(), input$nodeNames)
    } else if (input$nodeMeasure == "children") {
      bnlearn::children(dag(), input$nodeNames)
    } else if (input$nodeMeasure == "in.degree") {
      bnlearn::in.degree(dag(), input$nodeNames)
    } else if (input$nodeMeasure == "out.degree") {
      bnlearn::out.degree(dag(), input$nodeNames)
    } else if (input$nodeMeasure == "incident.arcs") {
      bnlearn::incident.arcs(dag(), input$nodeNames)
    } else if (input$nodeMeasure == "incoming.arcs") {
      bnlearn::incoming.arcs(dag(), input$nodeNames)
    } else if (input$nodeMeasure == "outgoing.arcs") {
      bnlearn::outgoing.arcs(dag(), input$nodeNames)
    } else
      bnlearn::incident.arcs(dag(), input$nodeNames)
  })

  # Show network measures
  output$netTable <- d3heatmap::renderD3heatmap({
    if (is.null(data()))
      return(NULL)
    d3heatmap::d3heatmap(
      bnlearn::amat(dag()),
      dendrogram = input$dendrogram,
      symm = TRUE,
      cexRow = 0.7,
      cexCol = 0.7,
      colors = "Blues"
    )
  })

  simData <- shiny::reactive({
    simData <- bnlearn::rbn(fit(), input$n)
  })

  output$downloadData <- shiny::downloadHandler(
    filename = function() {
      paste('bn', '.csv', sep = '')
    },
    content = function(file) {
      write.csv(simData(), file)
    }
  )
})
