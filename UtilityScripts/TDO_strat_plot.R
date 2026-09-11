data=read.csv(file.choose())
cols=viridis::inferno(11)
pal=colorRampPalette(cols)
CR=pal(31)
data$TIME=format(lubridate::ymd_hms(data$ISO.8601.Time),tz="America/New_York")
data$TEMPERATURE=data$Temperature..C.*9/5+32
## Download atmospheric pressure
dataset_id = 'cwwcNDBCMet'
url = "https://coastwatch.pfeg.noaa.gov/erddap/"
pressure_data <- rerddap::tabledap(
  url = url,
  datasetid = dataset_id,
  fields = query_vars,
  'station="44020"',
  paste0('time>="',substr(Sys.time()-lubridate::days(14),1,10),'T00:00:00Z"') 
)
atm=read.csv(
  paste0(
    "https://coastwatch.pfeg.noaa.gov/erddap/tabledap/cwwcNDBCMet.csvp?station%2Ctime%2Cbar&station=%2244020%22&time%3E=",
    substr(Sys.time()-lubridate::days(14),1,10),
    'T00:00:00Z'
  )
)
avg_pressure=mean(atm$bar..hPa.,na.rm = TRUE)/100
data$DEPTH=(data$Pressure..dbar.-avg_pressure)*0.54687
plot(
  data$DEPTH~lubridate::ymd_hms(data$TIME),
  xlab="Time",
  ylab="Depth (fathoms)",
  main="",
  type='n',
  ylim=c(60,0)
)
data$col=NA
for(j in seq(0,30)){
  data$col[which(round(data$Temperature..C.,0)==j)]=CR[j]
}
points(data$DEPTH~lubridate::ymd_hms(data$TIME),pch=16,col=data$col,cex=2)

# Adjust these coordinates to move it to the "bottom"
ltime=data$TIME[round(nrow(data)*0.25,0)]
rtime=data$TIME[round(nrow(data)*0.75,0)]
xl <- ltime; yb <- max(data$DEPTH); xr <- rtime; yt <- (0.85*max(data$DEPTH))

# Draw the 100 small rectangles that make the gradient
rect(
  head(seq(xl, xr, len = 101), -1), yb, 
  tail(seq(xl, xr, len = 101), -1), yt, 
  col = CR, border = NA
)

# 4. Add the border and labels
rect(xl, yb, xr, yt) # Outline
text(x = seq(xl, xr, length.out = 7), 
     y = yb - 0.3, 
     labels = round(c(0, 5, 10, 15, 20, 25, 30) * (9/5) + 32, 0), 
     cex = 0.8)
text(x = (xl + xr) / 2, y = yt + 0.3, "Water Temperature (F)", font = 2)
