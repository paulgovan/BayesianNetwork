# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 30MB.
options(shiny.maxRequestSize = 30 * 1024 ^ 2)

# Load demo data from 'bnlearn'
data(alarm, package = "bnlearn")
data(gaussian.test, package = "bnlearn")
data(hailfinder, package = "bnlearn")
data(insurance, package = "bnlearn")
data(learning.test, package = "bnlearn")

# Enable bookmarking for the app
shiny::enableBookmarking(store = "url")

homeHelp <-
  data.frame(
    step = c(1, 2),
    intro = c(
      "Here is the sidebar menu. Each link opens a new tab. You will probably start with the <b>Structure</b> tab and work your way down.",
      "The body of the app is where you will find different features for modeling and analyzing your network. Each tab has its own help button."
    ),
    element = c(
      "#sidebarMenu",
      "#dashboardBody"
    ),
    position = c("auto", "auto")
  )

structureHelp <-
  data.frame(
    step = c(1),
    intro = c("Here is where you can view your Bayesian network. Using the 3 boxes to the left, you can (1) upload your data in csv format, (2) select a structural learning algorithm, and (3) estimate the network score. Data should be numeric or factored and should not contain any NULL/NaN/NA values."),
    element = c("#netPlot"),
    position = c("auto")
  )

parametersHelp <-
  data.frame(
    step = c(1),
    intro = c("Here is where you can view the parameters of your network. Using the 2 boxes to the left, you can (1) select a parameter learning method and (2) select the type of graphic to view."),
    element = c("#condPlot"),
    position = c("auto")
  )

inferenceHelp <-
  data.frame(
    step = c(1),
    intro = c("Here is where you can view the conditional probability distribution of an event. Using the 2 boxes to the left, you can (1) add evidence to the model and (2) select a conditional event to view."),
    element = c("#distPlot"),
    position = c("auto")
  )

measuresHelp <-
  data.frame(
    step = c(1, 2),
    intro = c(
      "Select a node measure in the box to the left and the result is displayed here.",
      "Here is where you can view the adjacency matrix. Configure the matrix using the control to the left."
    ),
    element = c(
      "#nodeText",
      "#netTable"
    ),
    position = c("auto", "auto")
  )

editorHelp <-
  data.frame(
    step = c(1, 2),
    intro = c(
      "Here is the editor. Click <b>Run</b> to knit the rmarkdown report.",
      "The resulting rmarkdown report is displayed here."
    ),
    element = c(
      "#rmd",
      "#knitr"
    ),
    position = c("auto", "auto")
  )
