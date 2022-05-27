## Load packages used in this application
require(RMySQL)
require(shiny)
require(lubridate)

## Read in configuration values
db_config=config::get()$db

## Create database connection
conn=dbConnect(
  MySQL(), 
  user=db_config$username, 
  password=db_config$password, 
  dbname=db_config$dbname, 
  host=db_config$host,
  port=db_config$port
)

# Stop database connection when application stops
shiny::onStop(function() {
  dbDisconnect(conn)
})

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 8)