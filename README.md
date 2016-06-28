# Features
* Create interactive Bayesian Network models in the cloud
* Learn the structure of your network with powerful structural learning algorithms
* Learn the paramaters of your network with effective paramater learning methods
* Measure the importance of connections in your network with node and network measures
* Generate data from your network and export to your favorite app

# Overview
BayesianNetwork is a [Shiny](http://shiny.rstudio.com) web application for Bayesian Network modeling and analysis, powered by the excellent [bnlearn](http://www.bnlearn.com) and [networkD3](http://christophergandrud.github.io/networkD3/) packages. This app is a more general version of the [RiskNetwork](https://github.com/paulgovan/RiskNetwork) web app. To learn more about our project, check out this [publication](http://ascelibrary.org/doi/abs/10.1061/(ASCE)CO.1943-7862.0001136). For even more background, see this [publication](http://dx.doi.org/10.1061/(ASCE)CO.1943-7862.0001136).

# Getting Started
To run BayesianNetwork in [R](https://www.r-project.org):

```S
shiny::runGitHub('paulgovan/bayesiannetwork')
```

Or to access the app through a browser, visit [paulgovan.shinyapps.io/BayesianNetwork](https://paulgovan.shinyapps.io/Bayesiannetwork). 

# Example
## Dashboard
Launching the app brings up the *Dashboard*. The *Dashboard* is basically a landing page that includes a brief introduction to the app as well as value boxes that show both the number of *nodes* and *arcs* in the network. BayesianNetwork comes with a number of  pre-loaded artificial and "real world" data sets. This example will use the "Sample Discrete Network", which is the first network loaded when launching the app.

![Dashboard](https://github.com/paulgovan/BayesianNetwork/blob/master/images/Dashboard.PNG?raw=true)

## Structure
Click *Structure* in the sidepanel in order to begin learning the network from the data.

The *Network Input* box contains a number of pre-loaded Bayesian networks as well as the ability to upload a data set in csv format. Note that the "Sample Discrete Network" should already be loaded. 

The *Structural Learning* box contains multiple algorithms for learning the structure of the network that are organized based on the type of algorithm: 
* Constraint-based algorithms
* Score-based algorithms
* Hybrid-structure algorithms
* Local discovery algorithms

The *Network Score* box includes a number of score functions and the result of the selected score function for the current network.  

![Structure](https://github.com/paulgovan/BayesianNetwork/blob/master/images/Structure.PNG?raw=true)

The "Sample Discrete Network" contains six discrete variables, stored as factors with either 2 or 3 levels. The structure of this simple Bayesian network can be learned using the grow-shrink algorithm, which is already the default algorithm selected.

Try different combinations of structural learning algorithms and score functions to see the effect (if any) on the resulting Bayesian network.

## Parameters
Select the grow-shrink algorithm again and then click *Parameters* in the sidepanel in order to learn the parameters of the network.

In the *Parameter Learning* box contains options for both maximum-likelihood estimation and Bayesian estimation of the parameters. Note that Bayesian paramter learning is currently only implemented for *discrete* data sets. 

The *Paramter Infographic* box contains options for different chart types and, for the discrete case, the selected node. 

![Parameters](https://github.com/paulgovan/BayesianNetwork/blob/master/images/Parameters.PNG?raw=true)

For example, the selected node *A* is a discrete node with three levels *a*, *b*, and *c*.

## Measures
Click *Measures* in the sidepanel to bring up a number of tools for classical network analysis. 

The *Node Control* box contains several different node measures that can be displayed in the *Node Measure* box. These node measures include:
* Markov blanket
* Neighborhood
* Parents
* Children
* In degree
* Out degree
* Incident arcs
* Incoming arcs
* Outgoing arcs

The *Network Control* box gives options for the type of dendogram to plot on the adjacency matrix, which is shown in the *Network Measure* box. The dendogram can be shown for:
* Row
* Column
* Both, or
* Neither the row or column

![Measures](https://github.com/paulgovan/BayesianNetwork/blob/master/images/Measures.PNG?raw=true)

## Simulation

Finally, click *Simulation* in the sidepanel in order to simulate a random sample of data from the Bayesian network and download to a local drive for future use. 

Simply enter the sample size N and click *Download* in order to download a sample data set into the current working directory. 

# Source Code
BayesianNetwork is an [open source](http://opensource.org) project, and the source code is available at [https://github.com/paulgovan/BayesianNetwork](https://github.com/paulgovan/BayesianNetwork)

# Issues
For issues or requests, please use the GitHub issue tracker at [https://github.com/paulgovan/BayesianNetwork/issues](https://github.com/paulgovan/BayesianNetwork/issues)

# Contributions
Contributions are welcome by sending a [pull request](https://github.com/paulgovan/BayesianNetwork/pulls)

# License
BayesianNetwork is licensed under the [Apache](http://www.apache.org/licenses/LICENSE-2.0) licence. &copy; Paul Govan (2015)
