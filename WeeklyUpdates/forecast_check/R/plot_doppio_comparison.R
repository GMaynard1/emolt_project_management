# ## Old
# data=read.csv(file.choose())
# data$diff_temp=data$forecast_temp-data$obs_temp
# data$date=lubridate::ymd_hms(data$date)
# data=subset(data,data$date>=lubridate::ymd("2025-09-15"))
# data$diff_temp_F=(data$forecast_temp*9/5+32)-(data$obs_temp*9/5+32)
# plotval=seq(-10,10,0.1)
# plotcol=cmocean::cmocean("balance",direction=-1)(length(plotval))
# for(i in 1:nrow(data)){
#   x=data$diff_temp_F[i]
#   data$scalecolor[i]=ifelse(
#     x>max(plotval),
#     plotcol[length(plotval)],
#     ifelse(
#       x<min(plotval),
#       plotcol[1],
#       plotcol[which(abs(plotval-x)==min(abs(plotval-x)))]
#     )
#   )
# }
# ## Develop a linear regression
# lm1=lm(data$forecast_temp~data$obs_temp)
# pred = lm1$coefficients[1]+lm1$coefficients[2]*seq(-1,45,1)
# plot(
#   data$forecast_temp~data$obs_temp,
#   xlim=c(0,35),
#   ylim=c(0,35),
#   xlab="Observed Temp (C)",
#   ylab="Predicted Temp (C)",
#   col=data$scalecolor,
#   pch=16,
#   main="Predicted vs. Observed Bottom Temperatures (Doppio)"
# )
# points(
#   data$forecast_temp~data$obs_temp,
#   pch=1,
#   col='darkgray'
# )
# points(
#   data$forecast_temp~data$obs_temp,
#   pch=16,
#   col=data$scalecolor
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
#   label = round(summary(lm1)$r.squared,3)
# )
# text(
#   x=5,
#   y=27,
#   label = paste0("RMSE = ",round(mean(lm1$residuals^2),3))
# )
# text(
#   x=5,
#   y=24,
#   label = paste0("Bias = ",round(Metrics::bias(data$forecast_temp,data$obs_temp),3))
# )
# ## Download bathymetric data
# bath=marmap::getNOAA.bathy(
#   lon1=min(-80.83),
#   lon2=max(-56.79),
#   lat1=min(33),
#   lat2=max(47),
#   resolution=1
# )
# ## Create color ramp
# blues=c(
#   "lightsteelblue4", 
#   "lightsteelblue3",
#   "lightsteelblue2", 
#   "lightsteelblue1"
# )
# ## Plotting the bathymetry with different colors for land and sea
# plot(
#   bath,
#   step=100,
#   deepest.isobath=-1000,
#   shallowest.isobath=0,
#   col="darkgray",
#   image = TRUE, 
#   land = TRUE, 
#   lwd = 0.1,
#   bpal = list(
#     c(0, max(bath), "gray"),
#     c(min(bath),0,blues)
#   ),
#   main="Doppio Predicted - eMOLT Obs (deg F)",
#   sub=paste0(
#     lubridate::floor_date(min(lubridate::ymd_hms(data$date)),"day"),
#     " to ",
#     lubridate::ceiling_date(max(lubridate::ymd_hms(data$date)),"day")
#   ),
#   xlim=c(-78,-66),
#   ylim=c(34,45)
# )
# ## Add output points
# points(
#   data$latitude~data$longitude,
#   pch=1,
#   col='black',
#   cex=1.6
# )
# points(
#   data$latitude~data$longitude,
#   pch=16,
#   col=data$scalecolor,
#   cex=1.5
# )
# ## Add legend
# legend(
#   'bottomright',
#   legend=seq(-8,8,4),
#   fill=(plotcol[plotval%in%seq(-8,8,4)]),
#   title="Predicted - Observed"
# )
# mean(data$diff_temp_F)
# range(data$diff_temp_F)
# nrow(subset(data,data$diff_temp_F<=2))/nrow(data)


## New
data=read.csv(
  file = paste0(
    "C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/",
    lubridate::year(Sys.Date()),
    "/",
    Sys.Date(),
    "/Doppio_comparison_",
    strftime(Sys.Date(),format="%Y%m%d"),
    ".csv"
    )
)
data=subset(data,is.na(data$forecast_temp)==FALSE)
data$diff_temp=data$forecast_temp-data$avg_temp
data$diff_temp_F=(data$forecast_temp*9/5+32)-(data$avg_temp*9/5+32)

plotval=seq(-10,10,0.1)
plotcol=cmocean::cmocean("balance",direction=-1)(length(plotval))
for(i in 1:nrow(data)){
  x=data$diff_temp_F[i]
  data$scalecolor[i]=ifelse(
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
lm1=lm(data$forecast_temp~data$avg_temp)
pred = lm1$coefficients[1]+lm1$coefficients[2]*seq(-1,45,1)
plot(
  data$forecast_temp~data$avg_temp,
  xlim=c(0,35),
  ylim=c(0,35),
  xlab="Observed Temp (C)",
  ylab="Predicted Temp (C)",
  col=data$scalecolor,
  pch=16,
  main="Predicted vs. Observed Bottom Temperatures (Doppio)"
)
points(
  data$forecast_temp~data$avg_temp,
  pch=1,
  col='darkgray'
)
points(
  data$forecast_temp~data$avg_temp,
  pch=16,
  col=data$scalecolor
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
  label = paste0("Bias = ",round(Metrics::bias(data$forecast_temp,data$avg_temp),3))
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
    lubridate::floor_date(min(lubridate::ymd(data$date)),"day"),
    " to ",
    lubridate::ceiling_date(max(lubridate::ymd(data$date)),"day")
  ),
  xlim=c(-78,-66),
  ylim=c(34,45)
)
## Add output points
points(
  data$latitude~data$longitude,
  pch=1,
  col='black',
  cex=1.6
)
points(
  data$latitude~data$longitude,
  pch=16,
  col=data$scalecolor,
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

mean(data$diff_temp_F)
range(data$diff_temp_F)
nrow(subset(data,data$diff_temp_F<=2))/nrow(data)
