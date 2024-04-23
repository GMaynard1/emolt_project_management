#source("API/API_header.R")
library(marmap)
## Connect to the database
conn=dbConnector(db_config2)
## Download the last week's status updates for all vessels
lastweek=Sys.Date()-days(7)
data=dbGetQuery(
  conn=conn,
  statement=paste0(
    "SELECT * FROM VESSEL_STATUS WHERE TIMESTAMP > '",
    lastweek,
    "'"
  )
)
data=select(data,REPORT_TYPE,LATITUDE,LONGITUDE,TIMESTAMP,VESSEL_ID)
# bath=getNOAA.bathy(
#   lon1=min(-80.83),
#   lon2=max(-56.79),
#   lat1=min(35.11),
#   lat2=max(46.89),
#   resolution=10
# )
# bath=getNOAA.bathy(
#   lon1=min(data$LONGITUDE-0.5),
#   lon2=max(data$LONGITUDE+0.5),
#   lat1=min(data$LATITUDE-0.5),
#   lat2=max(data$LATITUDE+0.5),
#   resolution=1
# )
bath=readGEBCO.bathy(
  file=file.choose(),
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
  main=paste0("ALL eMOLT VESSELS with Satellite Transmitters \nREPORTS FROM: ",lastweek," to ",Sys.Date())
)


## Plot the status report locations
x=subset(data,data$REPORT_TYPE=="SHORT_STATUS")
points(
  x$LATITUDE~x$LONGITUDE,
  pch=1,
  col='red'
)
## Plot data uploads
x=subset(data,data$REPORT_TYPE=="SUMMARY_DATA")
points(
  x$LATITUDE~x$LONGITUDE,
  pch=1,
  col='blue'
)
## Add labels to points
text(
  x$LATITUDE~x$LONGITUDE,
  labels=x$VESSEL_ID
)
legend(
  'topleft',
  col=c('blue','red'),
  legend=c('Summary Data Upload','Status Report'),
  pch=c(1,1),
  bty='n',
  bg=NULL,
  border='black'
)
