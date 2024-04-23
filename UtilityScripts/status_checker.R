## Load necessary libraries
require(config)
require(geosphere)
require(jsonlite)
require(lubridate)
require(marmap)
require(plumber)
require(readr)
require(reticulate)
require(RMySQL)
require(wkb)

## Ensure enough database connections are available for multiple vessels
## reporting simultaneously
MySQL(max.con=50)

## Vector of functions to read in
functions=c(
  'commsdat.R',
  'create_py_dict.R',
  'dbConnector.R',
  'dbDisconnectAll.R',
  'distTrav.R',
  'loggerdat.R',
  'standard_mac.R',
  'vessel_name.R',
  'vesseldat.R',
  'vesselSatLookup.R'
)

## Read in functions and database configuration values
if(Sys.info()[["nodename"]]=="emoltdev"){
  db_config=config::get(file="/etc/plumber/config.yml")$dev_local
  db_config2=config::get(file="/etc/plumber/config.yml")$add_local_dev
  for(i in 1:length(functions)){
    source(
      paste0(
        "/etc/plumber/Functions/",
        functions[i]
      )
    )
  }
} else {
  db_config=config::get(file="C:/Users/george.maynard/Documents/GitHubRepos/emolt_serverside/API/config.yml")$dev_remote
  db_config2=config::get(file="C:/Users/george.maynard/Documents/GitHubRepos/emolt_serverside/API/config.yml")$add_remote_dev
  for(i in 1:length(functions)){
    source(
      paste0(
        "C:/Users/george.maynard/Documents/GitHubRepos/emolt_serverside/API/Functions/",
        functions[i]
      )
    )
  }
}
## Choose a vessel of interest
vessel="christi caroline"
## Connect to the database
conn=dbConnector(db_config2)
## Download the last week's status updates for the vessel
lastweek=Sys.Date()-days(7)
vessel_info=dbGetQuery(
  conn=conn,
  statement=paste0(
    "SELECT * FROM VESSELS WHERE VESSEL_NAME = '",
    vessel_name(vessel),
    "'"
  )
)
data=dbGetQuery(
  conn=conn,
  statement=paste0(
    "SELECT * FROM VESSEL_STATUS WHERE VESSEL_ID = ",
    vessel_info$VESSEL_ID,
    " AND TIMESTAMP > '",
    lastweek,
    "'"
  )
)
data=select(data,REPORT_TYPE,LATITUDE,LONGITUDE,TIMESTAMP)
## Append the vessel's homeport to the dataset
homeport=dbGetQuery(
  conn=conn,
  statement=paste0(
    "SELECT * FROM PORTS WHERE PORT = '",
    vessel_info$PORT,
    "'"
  )
)
homeport=select(homeport,LATITUDE,LONGITUDE)
homeport$TIMESTAMP=NA
homeport$REPORT_TYPE="HOMEPORT"
data=rbind(data,homeport)
data=data[order(ymd_hms(data$TIMESTAMP)),]
# bath=getNOAA.bathy(
#   lon1=min(-80.83),
#   lon2=max(-56.79),
#   lat1=min(35.11),
#   lat2=max(46.89),
#   resolution=10
# )
bath=getNOAA.bathy(
  lon1=min(data$LONGITUDE-0.5),
  lon2=max(data$LONGITUDE+0.5),
  lat1=min(data$LATITUDE-0.5),
  lat2=max(data$LATITUDE+0.5),
  resolution=1
)
## Create color ramp
blues=c(
  "lightsteelblue4", 
  "lightsteelblue3",
  "lightsteelblue2", 
  "lightsteelblue1"
  )
## Plotting the bathymetry with different colors for land and sea
plot(
  bath,
  step=100,
  deepest.isobath=-1000,
  shallowest.isobath=0,
  col="darkgray",
  image = TRUE, 
  land = TRUE, 
  lwd = 0.1,
  bpal = list(
    c(0, max(bath), "gray"),
    c(min(bath),0,blues)
    ),
  main=paste0("F/V ",vessel_name(vessel)," \nREPORTS FROM: ",lastweek," to ",Sys.Date())
  )


## Plot the status report locations
x=subset(data,data$REPORT_TYPE=="SHORT_STATUS")
points(
  x$LATITUDE~x$LONGITUDE,
  pch=1,
  col='red'
)
## Plot the homeport
x=subset(data,data$REPORT_TYPE=="HOMEPORT")
points(
  x$LATITUDE~x$LONGITUDE,
  pch='*',
  col='black'
)
## Plot data uploads
x=subset(data,data$REPORT_TYPE=="SUMMARY_DATA")
points(
  x$LATITUDE~x$LONGITUDE,
  pch=1,
  col='blue'
)

## Plot arrows between the points
s=seq(1,nrow(data)-1)
arrows(
  data$LONGITUDE[s], 
  data$LATITUDE[s], 
  data$LONGITUDE[s + 1], 
  data$LATITUDE[s + 1],
  length=0.1,
  lty=2,
  lwd=0.5,
  col='darkgreen'
  )
