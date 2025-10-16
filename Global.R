library(shiny)
library(shinythemes)
library(dplyr)
library(readr)

h_mer <- read_csv(file.path(getwd(), "Maree.csv"))
h_mer$NGF <- as.numeric(h_mer$NGF)
