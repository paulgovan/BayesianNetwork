# Features
* Create interactive Bayesian Network models in the cloud
* Learn the structure of your network with powerful structural learning algorithms
* Learn the paramaters of your network with effective paramater learning methods
* Measure the importance of connections in your network with node and network measures
* Generate data from your network and export to your favorite app

# Overview
BayesianNetwork is a [Shiny](http://shiny.rstudio.com) web application for Bayesian Network modeling and analysis, powered by the excellent [bnlearn](http://www.bnlearn.com) and [networkD3](http://christophergandrud.github.io/networkD3/) packages. This app is a more general version of the [RiskNetwork](https://github.com/paulgovan/RiskNetwork) web app. To learn more about our project, see this [publication](http://ascelibrary.org/doi/abs/10.1061/(ASCE)CO.1943-7862.0001136). For even more background, check out this [publication](http://dx.doi.org/10.1061/(ASCE)CO.1943-7862.0001136).

# Getting Started
To run BayesianNetwork in [R](https://www.r-project.org):

```S
shiny::runGitHub('paulgovan/bayesiannetwork')
```

Or to access the app through a browser, visit [paulgovan.shinyapps.io/BayesianNetwork](https://paulgovan.shinyapps.io/Bayesiannetwork). 

# Example
## Dashboard
Launching the app brings up the *Dashboard*. The *Dashboard* is basically a landing page that includes a brief introduction to the app and as well as value boxes for both the number of *nodes* and *arcs* in the network. 

![Dashboard](https://github.com/paulgovan/BayesianNetwork/blob/master/images/Dashboard.PNG?raw=true)

# Source Code
BayesianNetwork is an [open source](http://opensource.org) project, and the source code is available at [https://github.com/paulgovan/BayesianNetwork](https://github.com/paulgovan/BayesianNetwork)

# Issues
For issues or requests, please use the GitHub issue tracker at [https://github.com/paulgovan/BayesianNetwork/issues](https://github.com/paulgovan/BayesianNetwork/issues)

# Contributions
Contributions are welcome by sending a [pull request](https://github.com/paulgovan/BayesianNetwork/pulls)

# License
BayesianNetwork is licensed under the [Apache](http://www.apache.org/licenses/LICENSE-2.0) licence. &copy; Paul Govan (2015)
