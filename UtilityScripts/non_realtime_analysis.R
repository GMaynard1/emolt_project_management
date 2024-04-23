library(lubridate)
## Download data from all time
data_all=read.csv("https://comet.nefsc.noaa.gov/erddap/tabledap/eMOLT.csv?time%2Clatitude%2Clongitude%2Cdepth%2Csea_water_temperature&time%3E=2000-01-01T00%3A00%3A00Z")
data_all=data_all[-1,]
## Download data from this year
data=read.csv(
  paste0(
    "https://comet.nefsc.noaa.gov/erddap/tabledap/eMOLT.csv?time%2Clatitude%2Clongitude%2Cdepth%2Csea_water_temperature&time%3E=",
    year(Sys.Date())-1,
    "-01-01T00%3A00%3A00Z"
    )
)
data=data[-1,]

## Pull out this year's sites
data$site=paste0(
  data$latitude,
  "_",
  data$longitude
)

# sites=unique(data$site)

data_all$site=paste0(
  data_all$latitude,
  "_",
  data_all$longitude
)

sites=unique(data_all$site)

data_all=subset(data_all,data_all$site%in%sites)
data_all$time=ymd_hms(data_all$time)
data_all=subset(data_all,data_all$sea_water_temperature!="NaN")
data_all$sea_water_temperature=as.numeric(data_all$sea_water_temperature)
data_all=subset(data_all,is.na(data_all$time)==FALSE)
## Calculate annual average temperatuers for each site
avg=data.frame(
  site=as.character(),
  year=as.numeric(),
  month=as.numeric(),
  mean_temperature=as.numeric(),
  sd_temperature=as.numeric()
)
pb1=txtProgressBar(style=3)
pb2=txtProgressBar(style=3)
for(s in 1:length(sites)){
  nd_site=sites[s]
  for(y in seq(min(year(data_all$time)),max(year(data_all$time)),1)){
    z=subset(data_all,year(data_all$time)==y&data_all$site==nd_site)
    for(m in seq(1,12,1)){
      nd=subset(z,month(z$time)==m)
      if(nrow(nd)>0){
        nd_avg=data.frame(
          site=nd_site,
          year=y,
          month=m,
          mean_temperature=mean(nd$sea_water_temperature),
          sd_temperature=sd(nd$sea_water_temperature)
        )
        avg=rbind(avg,nd_avg)
        rm(nd_avg,nd)
        setTxtProgressBar(
          pb1,
          which(seq(min(year(data_all$time)),max(year(data_all$time)))==y)/length(seq(min(year(data_all$time)),max(year(data_all$time))))
        )
      }
    }
    setTxtProgressBar(pb2,s/length(sites))
  }
}
increases=data.frame(
  month=numeric(),
  change=numeric(),
  site=character()
)
for(m in seq(1,12,1)){
  cat("\n##### Month:",m,"#####\n")
  plot(
    avg$mean_temperature~avg$year,
    type='n',
    xlab="Year",
    ylab="Average Temperature (C)",
    main=paste("Month:",m)
    )
  for(s in sites){
    x=subset(avg,avg$site==s&avg$month==m)
    if(nrow(x)>3){
      points(x$mean_temperature~x$year,pch=16,col='lightgray')
      z=lm(x$mean_temperature~x$year)
      p=summary(z)$coefficients[,4][[2]]
      d=min(subset(data,data$site==s)$depth)
      if(p<=0.05){
        lines(z$fitted.values~x$year)
        cat("Sig increase of",z$coefficients[[2]], "degrees / year at",d,"\n")
        nd_inc=data.frame(
          month=m,
          change=z$coefficients[[2]],
          site=s
        )
        increases=rbind(increases,nd_inc)
      } else {
        cat("No sig diff at",d,"\n")
      }
    }
  }
}

plot(
  avg$sd_temperature~avg$year,
  type='n',
  xlab="Year",
  ylab="StDev Temperature (C)"
)
for(s in sites){
  x=subset(avg,avg$site==s)
  points(x$sd_temperature~x$year,pch=16,col='lightgray')
  z=lm(x$mean_temperature~x$year)
  p=summary(z)$coefficients[,4][[2]]
  if(p<=0.05){
    lines(z$fitted.values~x$year)
    #cat("Sig increase of",z$coefficients[[2]], "degrees / year \n")
  }
}
