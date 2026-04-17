#' @import bnlearn
#' @import heatmaply
#' @import plotly
#' @import rintrojs
#' @import shiny
#' @import shinyAce
#' @import shinydashboard
#' @import shinyWidgets

options(shiny.testmode=TRUE)

# Define required server logic
shinyServer(function(input, output, session) {

  # Get the data selection from user
  dat <- shiny::reactive({
    if (input$dataInput == 1) {

      if (input$net == 1) {
        dat <- learning.test
      } else if (input$net == 2) {
        dat <- gaussian.test
      } else if (input$net == 3) {
        dat <- alarm
      } else if (input$net == 4) {
        dat <- insurance
      } else if (input$net == 5) {
        dat <- hailfinder
      }
    } else if (input$dataInput == 2) {

      # Get the uploaded file from user
      inFile <- input$file
      if (is.null(inFile))
        return(NULL)
      dat <- tryCatch(
        read.csv(inFile$datapath, stringsAsFactors = TRUE),
        error = function(e) {
          shiny::showNotification(
            paste("Could not read file:", conditionMessage(e)),
            type = "error", duration = 8
          )
          NULL
        }
      )
      if (is.null(dat)) return(NULL)
      if (anyNA(dat)) {
        shiny::showNotification(
          "Data contains missing values (NA). Please clean your data before uploading.",
          type = "warning", duration = 8
        )
      }
      dat
    }
  })

  # Learn the structure of the network
  dag <- shiny::reactive({
    if (is.null(dat()))
      return(NULL)

    # Create a Progress object
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    progress$set(message = "Learning network structure", value = 0)

    # Dispatch to the selected learning algorithm via lookup table
    alg_fns <- list(
      gs          = bnlearn::gs,
      iamb        = bnlearn::iamb,
      fast.iamb   = bnlearn::fast.iamb,
      inter.iamb  = bnlearn::inter.iamb,
      hc          = bnlearn::hc,
      tabu        = bnlearn::tabu,
      mmhc        = bnlearn::mmhc,
      rsmax2      = bnlearn::rsmax2,
      mmpc        = bnlearn::mmpc,
      si.hiton.pc = bnlearn::si.hiton.pc,
      aracne      = bnlearn::aracne,
      chow.liu    = bnlearn::chow.liu
    )
    tryCatch(
      bnlearn::cextend(alg_fns[[input$alg]](dat()), strict = FALSE),
      error = function(e) {
        shiny::showNotification(
          paste("Structure learning failed:", conditionMessage(e)),
          type = "error", duration = 10
        )
        NULL
      }
    )
  })

  # Create the nodes value box
  output$nodesBox <- shiny::renderUI({
    if (is.null(dat()))
      return(NULL)

    # Get the number of nodes in the network
    nodes <- bnlearn::nnodes(dag())

    shinydashboard::valueBox(nodes,
                             "Nodes",
                             icon = shiny::icon("circle"),
                             color = "blue")
  })

  # Create the arcs value box
  output$arcsBox <- renderUI({
    if (is.null(dat()))
      return(NULL)

    # Get the number of arcs in the network
    arcs <- bnlearn::narcs(dag())

    shinydashboard::valueBox(arcs,
                             "Arcs",
                             icon = shiny::icon("arrow-right"),
                             color = "green")
  })

  # Observe intro btn and start the intro
  shiny::observeEvent(input$homeIntro,
                      rintrojs::introjs(session, options = list(steps = homeHelp))
  )

  # Plot the d3 force directed network
  output$netPlot <- networkD3::renderSimpleNetwork({
    if (is.null(dat()))
      return(NULL)

    # Get the arc directions
    networkData <- data.frame(bnlearn::arcs(dag()))

    networkD3::simpleNetwork(
      networkData,
      Source = "from",
      Target = "to",
      opacity = 0.75,
      zoom = TRUE
    )

  })

  # Download network arcs as CSV
  output$downloadArcs <- shiny::downloadHandler(
    filename = function() paste0("network_arcs_", Sys.Date(), ".csv"),
    content  = function(file) write.csv(data.frame(bnlearn::arcs(dag())), file, row.names = FALSE)
  )

  # Print the network score
  output$score <- shiny::renderText({
    if (bnlearn::directed(dag())) {

      # If all of the data is numeric,...
      if (all(sapply(dat(), is.numeric))) {

        # Get the selected score function from the user and calculate the score
        if (input$type == "loglik") {
          bnlearn::score(dag(), dat(), type = "loglik-g")
        } else if (input$type == "aic") {
          bnlearn::score(dag(), dat(), type = "aic-g")
        } else if (input$type == "bic") {
          bnlearn::score(dag(), dat(), type = "bic-g")
        } else {
          bnlearn::score(dag(), dat(), type = "bge")
        }
      }

      # If the data is discrete,...
      else {
        if (input$type == "loglik") {
          bnlearn::score(dag(), dat(), type = "loglik")
        } else if (input$type == "aic") {
          bnlearn::score(dag(), dat(), type = "aic")
        } else if (input$type == "bic") {
          bnlearn::score(dag(), dat(), type = "bic")
        } else {
          bnlearn::score(dag(), dat(), type = "bde")
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

  # Observe intro btn and start the intro
  shiny::observeEvent(input$structureIntro,
                      rintrojs::introjs(session, options = list(steps = structureHelp))
  )

  # Fit the model parameters
  fit <- shiny::reactive({
    if (is.null(dat()))
      return(NULL)
    if (bnlearn::directed(dag())) {

      if (all(sapply(dat(), is.numeric))) met = "mle-g"
      else met = input$met

      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "Fitting model parameters", value = 0)

      # Get the selected parameter learning method from the user and learn the paramaters
      fit <- bnlearn::bn.fit(dag(), dat(), method = met)
    }
  })

  # Set the parameter graphic options
  graphic <- shiny::reactive({

    # If data is continuous, ...
    if (all(sapply(dat(), is.numeric))) {
      graphic <- c("Histogram" = "histogram",
                   "XY Plot" = "xyplot",
                   "QQ Plot" = "qqplot")

      # If data is discrete,...
    } else {
      graphic <- c("Bar Chart" = "barchart",
                   "Dot Plot" = "dotplot")
    }
  })

  # Send the parameter choices to the user
  shiny::observe({
    shiny::updateSelectInput(session, "param", choices = graphic())
  })

  # Send the node choices to the user
  shiny::observe({
    shiny::updateSelectInput(session, "Node", choices = colnames(dat()))
  })

  # Plot the model parameters
  output$condPlot <- shiny::renderPlot({
    if (is.null(dat()))
      return(NULL)
    if (bnlearn::directed(dag())) {

      # Get the selected graphic from the user and plot the parameters
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
          "Make sure your network is completely directed in order to view the parameter infographics..."
        )
      )
  })

  # Observe intro btn and start the intro
  shiny::observeEvent(input$parametersIntro,
                      rintrojs::introjs(session, options = list(steps = parametersHelp))
  )

  # Send the evidence node choices to the user
  shiny::observe({
    shiny::updateSelectInput(session, "evidenceNode", choices = names(dat()))
  })

  # Send the evidence choices to the user
  shiny::observe({
    shiny::req(input$evidenceNode, nchar(input$evidenceNode) > 0)
    whichNode <- which(colnames(dat()) == input$evidenceNode)
    if (length(whichNode) == 0) return()
    evidenceLevels <- as.vector(unique(dat()[, whichNode]))
    shiny::updateSelectInput(session, "evidence", choices = evidenceLevels)
  })

  # Send the event node choices to the user
  shiny::observe({
    shiny::updateSelectInput(session, "event", choices = names(dat()))
  })

  # Perform Bayesian inference based on evidence and plot results
  output$distPlot <- shiny::renderPlot({
    if (is.null(dat()))
      return(NULL)
    if (all(sapply(dat(), is.numeric)))
      shiny::validate(
        shiny::need(
          try(distPlot != ""),
          "Inference is currently not supported for continuous variables..."
        )
      )

    # Build evidence as a named list — avoids eval(parse()) injection risk
    evidence_list <- list(input$evidence)
    names(evidence_list) <- input$evidenceNode

    # Estimate the conditional PD and tabularize the results
    nodeProbs <- prop.table(table(bnlearn::cpdist(fit(), input$event, evidence = evidence_list, method = "lw")))

    # Create a bar plot of the conditional PD
    barplot(
      nodeProbs,
      col = "lightblue",
      main = "Conditional Probabilities",
      border = NA,
      xlab = "Levels",
      ylab = "Probabilities",
      ylim = c(0, 1)
    )
  })

  # Download inference results as CSV
  output$downloadInference <- shiny::downloadHandler(
    filename = function() paste0("inference_", Sys.Date(), ".csv"),
    content  = function(file) {
      evidence_list <- list(input$evidence)
      names(evidence_list) <- input$evidenceNode
      nodeProbs <- prop.table(
        table(bnlearn::cpdist(fit(), input$event, evidence = evidence_list, method = "lw"))
      )
      write.csv(as.data.frame(nodeProbs), file, row.names = FALSE)
    }
  )

  # Observe intro btn and start the intro
  shiny::observeEvent(input$inferenceIntro,
                      rintrojs::introjs(session, options = list(steps = inferenceHelp))
  )

  # Send the node names to the user
  shiny::observe({
    shiny::updateSelectInput(session, "nodeNames", choices = colnames(dat()))
  })

  # Get the selected node measure from the user and print the results
  output$nodeText <- shiny::renderText({
    if (is.null(dat()))
      return(NULL)
    measure_fns <- list(
      mb            = bnlearn::mb,
      nbr           = bnlearn::nbr,
      parents       = bnlearn::parents,
      children      = bnlearn::children,
      in.degree     = bnlearn::in.degree,
      out.degree    = bnlearn::out.degree,
      incident.arcs = bnlearn::incident.arcs,
      incoming.arcs = bnlearn::incoming.arcs,
      outgoing.arcs = bnlearn::outgoing.arcs
    )
    fn <- measure_fns[[input$nodeMeasure]]
    if (!is.null(fn)) fn(dag(), input$nodeNames)
  })

  # Get the selected network measure from the user and plot the results
  output$netTable <- plotly::renderPlotly({
    if (is.null(dat()))
      return(NULL)

    # Plot a d3 heatmap of the adjacency matrix
    heatmaply::heatmaply(
      bnlearn::amat(dag()),
      grid_gap = 1,
      colors = blues9,
      dendrogram = input$dendrogram,
      symm = TRUE,
      margins = c(100, 100, NA, 0),
      hide_colorbar = TRUE
    )
  })

  # Observe intro btn and start the intro
  shiny::observeEvent(input$measuresIntro,
                      rintrojs::introjs(session, options = list(steps = measuresHelp))
  )

  # Trigger bookmarking
  observeEvent(input$bookmark, {
    session$doBookmark()
  })

  # Need to exclude the buttons from themselves being bookmarked
  setBookmarkExclude("bookmark")

})
