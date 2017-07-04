#' @import bnlearn
#' @import deal
#' @import rintrojs
#' @import shiny
#' @import shinyAce
#' @import shinydashboard
# Define required server logic
shinyServer(function(input, output, session) {

  # Get the data selection from user
  dat <- shiny::reactive({
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
    } else  {

      # Get the uploaded file from user
      inFile <- input$file
      if (is.null(inFile))
        return(NULL)
      dat <- read.csv(inFile$datapath,
                      header = input$header,
                      sep = input$sep)
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

    # Get the selected learning algorithm from the user and learn the network
    if (input$alg == "gs") {
      dag <- bnlearn::cextend(bnlearn::gs(dat()), strict = FALSE)
    } else if (input$alg == "iamb") {
      dag <- bnlearn::cextend(bnlearn::iamb(dat()), strict = FALSE)
    } else if (input$alg == "fast.iamb") {
      dag <- bnlearn::cextend(bnlearn::fast.iamb(dat()), strict = FALSE)
    } else if (input$alg == "inter.iamb") {
      dag <- bnlearn::cextend(bnlearn::inter.iamb(dat()), strict = FALSE)
    } else if (input$alg == "hc") {
      dag <- bnlearn::cextend(bnlearn::hc(dat()), strict = FALSE)
    } else if (input$alg == "tabu") {
      dag <- bnlearn::cextend(bnlearn::tabu(dat()), strict = FALSE)
    } else if (input$alg == "mmhc") {
      dag <- bnlearn::cextend(bnlearn::mmhc(dat()), strict = FALSE)
    } else if (input$alg == "rsmax2") {
      dag <- bnlearn::cextend(bnlearn::rsmax2(dat()), strict = FALSE)
    } else if (input$alg == "mmpc") {
      dag <- bnlearn::cextend(bnlearn::mmpc(dat()), strict = FALSE)
    } else if (input$alg == "si.hiton.pc") {
      dag <- bnlearn::cextend(bnlearn::si.hiton.pc(dat()), strict = FALSE)
    } else if (input$alg == "aracne") {
      dag <- bnlearn::cextend(bnlearn::aracne(dat()), strict = FALSE)
    } else if (input$alg == "chow.liu") {
      dag <- bnlearn::cextend(bnlearn::chow.liu(dat()), strict = FALSE)
    }
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
      zoom = TRUE
    )

  })

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

      # Get the selected paramater learning method from the user and learn the paramaters
      fit <- bnlearn::bn.fit(dag(), dat(), method = input$met, iss = input$iss)
    }
  })

  # # Create data frame for selected paramater
  # param <- shiny::reactive({
  #   param <- data.frame(coef(fit()[[input$Node]]))
  #   if (is.numeric(dat()[,1])) {
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
  #   if (is.numeric(dat()[,1])) {
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
  #     if (is.numeric(dat()[,1])) {
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

  # Send the paramater choices to the user
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

      # Get the selected graphic from the user and plot the paramaters
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
    whichNode <- which(colnames(dat()) == input$evidenceNode)
    evidenceLevels <- as.vector(unique(dat()[,whichNode]))
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

    # Create a string of the selected evidence
    str1 <<- paste0("(", input$evidenceNode, "=='", input$evidence, "')")

    # Estimate the conditional PD and tabularize the results
    nodeProbs <- prop.table(table(bnlearn::cpdist(fit(), input$event, eval(parse(text = str1)))))

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

  # Get the selected network measure from the user and plot the results
  output$netTable <- d3heatmap::renderD3heatmap({
    if (is.null(dat()))
      return(NULL)

    # Plot a d3 heatmap of the adjacency matrix
    d3heatmap::d3heatmap(
      bnlearn::amat(dag()),
      dendrogram = input$dendrogram,
      symm = TRUE,
      cexRow = 0.7,
      cexCol = 0.7,
      colors = "Blues"
    )
  })

  # Observe intro btn and start the intro
  shiny::observeEvent(input$measuresIntro,
                      rintrojs::introjs(session, options = list(steps = measuresHelp))
  )

  # Knit shinyAce editor code
  output$knitr <- shiny::renderUI({

    # Create a Progress object
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    progress$set(message = "Building report...", value = 0)

    input$eval
    return(
      shiny::isolate(
        shiny::HTML(
          knitr::knit2html(text = input$rmd, fragment.only = TRUE, quiet = TRUE)
        )
      )
    )
  })

  # Observe intro btn and start the intro
  shiny::observeEvent(input$editorIntro,
                      rintrojs::introjs(session, options = list(steps = editorHelp))
  )

  # Trigger bookmarking
  observeEvent(input$bookmark, {
    session$doBookmark()
  })

  # Need to exclude the buttons from themselves being bookmarked
  setBookmarkExclude("bookmark")

})
