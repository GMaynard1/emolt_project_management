source("C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/forecast_check/R/emolt_download.R")
source("C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/forecast_check/R/download_doppio_ncks.R")
source("C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/forecast_check/R/compare_doppio.R")
data=emolt_download(days=7)
data=data[order(lubridate::ymd_hms(data$time..UTC.)),]
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
  download_doppio(
    tow=data$tow_id[i],
    date=lubridate::ymd_hms(data$time..UTC.[i]),
    lat=data$latitude..degrees_north.[i],
    lon=data$longitude..degrees_east.[i]
  )
  setTxtProgressBar(
    pb=pb,
    i/nrow(data)
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
  distance = as.numeric(),
  forecast_temp = as.numeric(),
  obs_temp = as.numeric(),
  lat = as.numeric(),
  lon = as.numeric(),
  date = as.character()
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

output$latitude=output$lat
output$longitude=output$lon
output=RMyDataTrash::OnLandCheck(output)
output=subset(output,output$OnLand==FALSE)
output=subset(output,round(output$lat,5)!=44.01441)
output=subset(output,output$obs_temp<25)
output=subset(output,round(output$lat,5)!=41.48480)

output$diff=output$forecast_temp-output$obs_temp
output$color=ifelse(
  output$diff>0,
  'blue',
  ifelse(
    output$diff==0,
    'white',
    'red'
    )
  )
output$scale=ifelse(
  abs(output$diff)>3,
  -.75,
  ifelse(
    abs(output$diff)<3 & abs(output$diff)>2,
    -0.5,
    ifelse(
      abs(output$diff)<2 & abs(output$diff)>1,
      0,
      0.5
    )
  )
)
output$scalecolor=colorspace::lighten(
  output$color,
  amount=output$scale
)
plotval=seq(-10,10,0.1)
plotcol=cmocean::cmocean("balance",direction=-1)(length(plotval))
for(i in 1:nrow(output)){
  x=output$diff[i]
  output$scalecolor[i]=ifelse(
    x>max(plotval),
    plotcol[length(plotval)],
    ifelse(
      x<min(plotval),
      plotcol[1],
      plotcol[which(abs(plotval-x)==min(abs(plotval-x)))]
    )
  )
}
output=read.csv(file.choose())
plotval=seq(-10,10,0.1)
plotcol=cmocean::cmocean("balance",direction=-1)(length(plotval))
for(i in 1:nrow(output)){
  x=output$diff[i]
  output$scalecolor[i]=ifelse(
    x>max(plotval),
    plotcol[length(plotval)],
    ifelse(
      x<min(plotval),
      plotcol[1],
      plotcol[which(abs(plotval-x)==min(abs(plotval-x)))]
    )
  )
}
## Develop a linear regression
lm1=lm(output$forecast_temp~output$obs_temp)
pred = lm1$coefficients[1]+lm1$coefficients[2]*seq(-1,45,1)
plot(
  output$forecast_temp~output$obs_temp,
  xlim=c(0,35),
  ylim=c(0,35),
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
  (-1:45),(-1:45)
)
lines(
  (-1:45),pred,
  lty=2
)
text(
  x=5,
  y=30,
  label = expression(paste(R^2,"="))
)
text(
  x=7,
  y=30,
  label = round(summary(lm1)$r.squared,3)
)
text(
  x=5,
  y=27,
  label = paste0("RMSE = ",round(mean(lm1$residuals^2),3))
)
text(
  x=5,
  y=24,
  label = paste0("Bias = ",round(Metrics::bias(output$forecast_temp,output$obs_temp),3))
)
# ## Download bathymetric data
bath=marmap::getNOAA.bathy(
  lon1=min(-80.83),
  lon2=max(-56.79),
  lat1=min(34),
  lat2=max(46.89),
  resolution=1
)
## Create color ramp
blues=c(
  "lightsteelblue4",
  "lightsteelblue3",
  "lightsteelblue2",
  "lightsteelblue1"
)
png("doppio_compare.png",height=1000, width=800,units="px")
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
  main="Doppio Predicted - eMOLT Obs (deg F)",
  sub=paste0(
    lubridate::floor_date(min(lubridate::ymd_hms(output$date)),"day"),
    " to ",
    lubridate::ceiling_date(max(lubridate::ymd_hms(output$date)),"day")
  ),
  xlim=c(-75,-66),
  ylim=c(34,45)
)
## Add output points
points(
  output$lat~output$lon,
  pch=16,
  col='black',
  cex=2
)
points(
  output$lat~output$lon,
  pch=16,
  col=output$scalecolor,
  cex=1.4
)
## Add legend
legend(
  'bottomright',
  legend=seq(-8,8,4),
  fill=(plotcol[plotval%in%seq(-8,8,4)]),
  title="Predicted - Observed"
)
dev.off()

mean(output$diff)
range(output$diff)

write.csv(
  output,
  file=paste0(
    "DoppioComparison_",
    lubridate::year(Sys.time()),
    lubridate::month(Sys.time()),
    lubridate::day(Sys.time())
    ),
  row.names=FALSE
)

# shelf=subset(
#   output,
#   output$lat>39.5&output$lat<40.5&output$lon>-72
# )
# non_shelf=subset(output,row.names(output)%in%row.names(shelf)==FALSE)
# ## Develop a linear regression
# lm2=lm(non_shelf$forecast_temp~non_shelf$obs_temp)
# pred = lm2$coefficients[1]+lm2$coefficients[2]*seq(-1,45,1)
# plot(
#   non_shelf$forecast_temp~non_shelf$obs_temp,
#   xlim=c(0,35),
#   ylim=c(0,35),
#   xlab="Observed Temp (C)",
#   ylab="Predicted Temp (C)",
#   col=non_shelf$scalecolor,
#   pch=16,
#   main="Predicted vs. Observed Bottom Temperatures (Doppio)"
# )
# points(
#   non_shelf$forecast_temp~non_shelf$obs_temp,
#   pch=1,
#   col='darkgray'
# )
# points(
#   non_shelf$forecast_temp~non_shelf$obs_temp,
#   pch=16,
#   col=non_shelf$scalecolor
# )
# lines(
#   (-1:45),(-1:45)
# )
# lines(
#   (-1:45),pred,
#   lty=2
# )
# text(
#   x=5,
#   y=30,
#   label = expression(paste(R^2,"="))
# )
# text(
#   x=7,
#   y=30,
#   label = round(summary(lm2)$r.squared,3)
# )
# text(
#   x=5,
#   y=27,
#   label = paste0("RMSE = ",round(mean(lm2$residuals^2),3))
# )
# text(
#   x=5,
#   y=24,
#   label = paste0("Bias = ",round(Metrics::bias(non_shelf$forecast_temp,non_shelf$obs_temp),3))
# )
# 
# x=subset(output,output$diff<=-3)
output$FORE=output$forecast_temp*9/5+32
output$OBS=output$obs_temp*9/5+32
output$DIFF=abs(output$FORE-output$OBS)
nrow(subset(output,output$DIFF<=2))/nrow(output)
