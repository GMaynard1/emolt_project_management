## Load packages used in this application
library(shiny)
library(RMySQL)
library(shinyTime)
library(shinyalert)
require(lubridate)
require(dplyr)
require(magrittr)
require(tidyr)

## Read in configuration values
db_config=config::get()$db_remote

## Create database connection
conn=dbConnect(
  MySQL(), 
  user=db_config$username, 
  password=db_config$password, 
  dbname=db_config$dbname, 
  host=db_config$host,
  port=db_config$port
)

## Load modules
source("R/vessel_id_module.R")

# # Stop database connection when application stops
# shiny::onStop(function() {
#   dbDisconnect(conn)
# })

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 8)