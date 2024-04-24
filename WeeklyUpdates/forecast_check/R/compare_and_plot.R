data=one_week_download()
## Create a progress bar for forecast downloads
pb=txtProgressBar(
  min=0,
  max=1,
  initial=0,
  char="*",
  width=NA,
  style=3
)
for(i in 1:nrow(data)){
  most_recent=download_doppio(
    tow=data$tow_id[i],
    date=lubridate::ymd_hms(data$time..UTC.[i]),
    lat=data$latitude..degrees_north.[i],
    lon=data$longitude..degrees_east.[i],
    most_recent=most_recent
  )
  setTxtProgressBar(
    pb=pb,
    i/nrow(data),
  )
}

## Create a progress bar for comparisons
pb=txtProgressBar(
  min=0,
  max=1,
  initial=0,
  char="*",
  width=NA,
  style=3
)
## Create a new dataframe to store comparisons
output=data.frame(
  distance = min(distances),
  forecast_temp = sp.forecast[which(distances==min(distances)),]$temp,
  obs_temp = sp.data$temperature..degree_C.[1],
  lat = sp.forecast[which(distances==min(distances)),]$lat,
  lon = sp.forecast[which(distances==min(distances)),]$lon,
  date = data$time..UTC.[1]
)
## Create comparisons
for(i in 1:nrow(data)){
  ## Check if the forecast exists for that file and pull it in if it does
  filename=paste0(
    data$tow_id[i],
    "_doppio.nc"
  )
  if(file.exists(filename)){
    new_output=compare_doppio(filename,data[i,])
    output=rbind(output,new_output)
    rm(new_output)
  }
  setTxtProgressBar(
    pb=pb,
    i/nrow(data),
  )
}

output$diff=output$forecast_temp-output$obs_temp
output$color=ifelse(
  output$diff>0,
  'red',
  'blue'
  )
output$scalecolor=colorspace::lighten(
  output$color,
  amount=1.5-abs(output$diff)
)

plot(
  output$forecast_temp~output$obs_temp,
  xlim=c(0,10),
  ylim=c(0,10),
  xlab="Observed Temp (C)",
  ylab="Predicted Temp (C)",
  col=output$scalecolor,
  pch=16,
  main="Predicted vs. Observed Bottom Temperatures (Doppio)"
  )
points(
  output$forecast_temp~output$obs_temp,
  pch=1,
  col='darkgray'
  )
points(
  output$forecast_temp~output$obs_temp,
  pch=16,
  col=output$scalecolor
)
lines(
  (-1:15),(-1:15)
)

## Download bathymetric data
bath=marmap::getNOAA.bathy(
  lon1=min(-80.83),
  lon2=max(-56.79),
  lat1=min(35.11),
  lat2=max(46.89),
  resolution=10
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
  main="eMOLT Obs - Doppio Predicted"
)
## Add output points
points(
  output$lat~output$lon,
  pch=1,
  col='darkgray'
)
points(
  output$lat~output$lon,
  pch=16,
  col=output$scalecolor
)
## Add legend
legend(
  'bottomright',
  legend=seq(2,-2,-1),
  fill=c(
    colorspace::lighten(
      c('blue','blue','white','red','red'),
    amount=1.5-abs(c(2,1,0,-1,-2))
    )
  ),
  title="Observed - Predicted"
)

mean(output$diff)
range(output$diff)