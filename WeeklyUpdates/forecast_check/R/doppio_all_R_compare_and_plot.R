start_time=Sys.time()
source("C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/forecast_check/R/emolt_download.R")
## Download eMOLT data
data=emolt_download()
## Average temperature and location within tow by day
tows=unique(data$tow_id)
emolt_avg=data.frame(
  tow=as.numeric(),
  date=as.character(),
  avg_temp=as.numeric(),
  latitude=as.numeric(),
  longitude=as.numeric()
)
pb=txtProgressBar(style=3,char="*")
for(tow in tows){
  x=subset(data,data$tow_id==tow)
  dates=unique(lubridate::floor_date(lubridate::ymd_hms(x$time..UTC.),unit = "day"))
  for(d in as.character(dates)){
    y=subset(x,as.character(lubridate::floor_date(lubridate::ymd_hms(x$time..UTC.),unit = "day"))==d)
    avg=data.frame(
      tow=tow,
      date=as.character(d),
      avg_temp=mean(y$temperature..degree_C.),
      latitude=mean(y$latitude..degrees_north.),
      longitude=mean(y$longitude..degrees_east.)
    )
    emolt_avg=rbind(emolt_avg,avg)
  }
  setTxtProgressBar(pb,which(tows==tow)/length(tows))
}
## Add columns for the forecast data
emolt_avg$f_temp=NA
emolt_avg$f_lat=NA
emolt_avg$f_lon=NA
pb=txtProgressBar(style=3,char=".")
for(r in 1:nrow(emolt_avg)){
  url=paste0(
    "https://tds.marine.rutgers.edu/thredds/ncss/grid/roms/doppio/2017_da/avg/runs/Averages_RUN_",
    lubridate::ymd(emolt_avg$date[r])-lubridate::days(1),
    "T00:00:00Z?var=temp&latitude=",
    emolt_avg$latitude[r],
    "&longitude=",
    emolt_avg$longitude[r],
    "&time=",
    emolt_avg$date[r],
    "T12:00:00Z&vertCoord=-1&accept=csv"
  )
  if(httr::GET(url)$status_code==200){
    dl=read.csv(url)
    emolt_avg$f_temp[r]=dl$temp.unit.Celsius.
    emolt_avg$f_lat[r]=dl$latitude.unit.degrees_north.
    emolt_avg$f_lon[r]=dl$longitude.unit.degrees_east.
  }
  setTxtProgressBar(pb,r/nrow(emolt_avg))
}
finish=Sys.time()
cat("Total runtime: ", finish-start_time)

emolt_avg=subset(emolt_avg,is.na(emolt_avg$f_temp)==FALSE)
emolt_avg$diff_temp_F=(emolt_avg$f_temp*9/5+32)-(emolt_avg$avg_temp*9/5+32)
plotval=seq(-10,10,0.1)
plotcol=cmocean::cmocean("balance",direction=-1)(length(plotval))
for(i in 1:nrow(emolt_avg)){
  x=emolt_avg$diff_temp_F[i]
  emolt_avg$scalecolor[i]=ifelse(
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
lm1=lm(emolt_avg$f_temp~emolt_avg$avg_temp)
pred = lm1$coefficients[1]+lm1$coefficients[2]*seq(-1,45,1)
plot(
  emolt_avg$f_temp~emolt_avg$avg_temp,
  xlim=c(0,35),
  ylim=c(0,35),
  xlab="Observed Temp (C)",
  ylab="Predicted Temp (C)",
  col=emolt_avg$scalecolor,
  pch=16,
  main="Predicted vs. Observed Bottom Temperatures (Doppio)"
)
points(
  emolt_avg$f_temp~emolt_avg$avg_temp,
  pch=1,
  col='darkgray'
)
points(
  emolt_avg$f_temp~emolt_avg$avg_temp,
  pch=16,
  col=emolt_avg$scalecolor
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
  label = paste0("Bias = ",round(Metrics::bias(emolt_avg$f_temp,emolt_avg$avg_temp),3))
)
## Download bathymetric data
bath=marmap::getNOAA.bathy(
  lon1=min(-80.83),
  lon2=max(-56.79),
  lat1=min(33),
  lat2=max(47),
  resolution=1
)
## Create color ramp
blues=c(
  "lightsteelblue4", 
  "lightsteelblue3",
  "lightsteelblue2", 
  "lightsteelblue1"
)
png(
  paste0(
    "C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/",
    lubridate::year(Sys.Date()),
    "/",
    Sys.Date(),
    "/Doppio_compare.png"
  ),
  height=700, width=800,units="px")
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
    lubridate::floor_date(min(lubridate::ymd(emolt_avg$date)),"day"),
    " to ",
    lubridate::ceiling_date(max(lubridate::ymd(emolt_avg$date)),"day")
  ),
  xlim=c(-78,-66),
  ylim=c(34,45)
)
## Add output points
points(
  emolt_avg$latitude~emolt_avg$longitude,
  pch=1,
  col='black',
  cex=1.6
)
points(
  emolt_avg$latitude~emolt_avg$longitude,
  pch=16,
  col=emolt_avg$scalecolor,
  cex=1.5
)
## Add legend
legend(
  'bottomright',
  legend=seq(-8,8,4),
  fill=(plotcol[plotval%in%seq(-8,8,4)]),
  title="Predicted - Observed"
)
dev.off()

write.csv(emolt_avg,file=paste0("C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/",lubridate::year(Sys.time()),"/",Sys.Date(),"/","Doppio_comparison_",gsub("-","",Sys.Date()),".csv"),row.names=FALSE)
