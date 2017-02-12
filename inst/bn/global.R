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

helpData <-
  data.frame(
    step = c(1, 2),
    intro = c(
      "Here is the sidebar menu. Each link opens a new tab. You will probably start with the <b>Structure</b> tab and work your way down.",
      "The body of the app is where you will find different features for modeling and analyzing your network."
    ),
    element = c(
      "#sidebarMenu",
      "#dashboardBody"
    ),
    position = c("auto", "auto")
  )
