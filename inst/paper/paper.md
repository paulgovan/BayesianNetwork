---
title: 'BayesianNetwork: Interactive Bayesian Network Modeling and Analysis'
authors:
- affiliation: 1
  name: Paul B. Govan
  orcid: 0000-0002-1821-8492
date: "14 July 2017"
output:
  pdf_document: default
  html_document: default
bibliography: paper.bib
tags:
- bayesian-networks
- network-measures
- learning-algorithms
- r
- shiny
affiliations:
- index: 1
  name: GE Renewable Energy
---

# Summary

`BayesianNetwork` is a `shiny` web application for Bayesian Network modeling and analysis, powered by the `bnlearn` package for Bayesian Network learning. The application includes structural learning algorithms for learning the structure of the network with support for both discrete and continuous variables, parameter learning methods for estimating the network parameters, procedures for adding evidence to the network and performing Bayesian inference, and node and network utilities for measuring the importance of connections in the network. `BayesianNetwork` originated as a research project for risk analysis applications, where the primary motivation was to develop an app for modeling and analyzing Bayesian Networks in an interactive environment. The goal is that the package be both powerful and intuitive, serving as a tool for educators and students alike. The package documentation includes examples and additional resources for running the software.

-![Structure tab](Structure.png)

# References
