## Northern Profiles
end=Sys.Date()
start=end-lubridate::days(7)
data=read.csv(
  paste0(
    "http://erddap.emolt.net/erddap/tabledap/eMOLT_RT_QAQC.csvp?tow_id%2Csegment_type%2Ctime%2Clatitude%2Clongitude%2Cdepth%2Ctemperature%2Csensor_type&segment_type=2&time%3E=",
    start,
    "T00%3A00%3A00Z&time%3C=",
    end,
    "T11%3A59%3A59Z&latitude%3E=39.5&longitude%3E=-72"
  )
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
## Set up plot
par(mfrow=c(1,2))
units="standard"
data$DEPTH=data$depth..m.*0.54680665
data$TEMP=data$temperature..degree_C.*9/5+32
data$TIME=lubridate::ymd_hms(data$time..UTC.)
## Set up a progress bar
pb=txtProgressBar(style=3,char="*")
for(i in unique(data$tow_id)){
  x=subset(data,data$tow_id==i)
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
    main=paste0("Tow: ",i),
    xlim=c(-72,-65),
    ylim=c(41.5,45)
  )
  points(x$latitude..degrees_north.~x$longitude..degrees_east.,col='red',pch=16,cex=1.5)
  if(units=="metric"){
    plot(
      x$depth..m.~x$temperature..degree_C.,
      main=x$time..UTC.[nrow(x)],
      ylim=c(max(x$depth..m.),min(x$depth..m.)),
      type='l',
      ylab="Depth (m)",
      xlab="Temperature (C)"
    )
  } else {
    if(units=="standard"){
      plot(
        x$DEPTH~x$TEMP,
        main=lubridate::round_date(max(lubridate::ymd_hms(x$time..UTC.)),"day"),
        ylim=c(max(x$DEPTH),min(x$DEPTH)),
        xlim=c(min(data$TEMP),max(data$TEMP)),
        type='l',
        ylab="Depth (fathoms)",
        xlab="Temperature (F)",
        lwd=2
      )
    }
  }
  setTxtProgressBar(pb,which(unique(data$tow_id)==i)/length(unique(data$tow_id)))
}
## Use the dates from above to create a URL for grabbing the data
full_data=read.csv(
  paste0(
    "https://erddap.emolt.net/erddap/tabledap/eMOLT_RT.csvp?tow_id%2Csegment_type%2Ctime%2Clatitude%2Clongitude%2Cdepth%2Ctemperature%2Csensor_type&segment_type=3&time%3E=",
    lubridate::year(start),
    "-",
    lubridate::month(start),
    "-",
    lubridate::day(start),
    "T00%3A00%3A00Z&time%3C=",
    lubridate::year(Sys.Date()),
    "-",
    lubridate::month(Sys.Date()),
    "-",
    lubridate::day(Sys.Date()),
    "T23%3A59%3A59Z"
  )
)
max=full_data[which(full_data$temperature..degree_C.==max(full_data$temperature..degree_C.)),]$tow_id[1]
min=full_data[which(full_data$temperature..degree_C.==min(full_data$temperature..degree_C.)),]$tow_id[1]
tows=c(41366,41376,41323,41454,41445,41444,41391,41394,41433,41427,41508)
tow_col=c('brown','black','orange','purple','aquamarine3','hotpink','firebrick2','blue','green','darkgreen','gold3')
## Set up plot
par(mfrow=c(1,2))
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
  main="",
  xlim=c(-72,-65),
  ylim=c(41.5,45)
)
for(i in 1:length(tows)){
  x=subset(data,data$tow_id==tows[i])
  points(
    x$latitude..degrees_north.[1]~x$longitude..degrees_east.[1],
    pch=1,
    cex=1.75
  )
  points(
    x$latitude..degrees_north.[1]~x$longitude..degrees_east.[1],
    pch=16,
    col=tow_col[i],
    cex=1.5
  )
}
plot(
  data$DEPTH~data$TEMP,
  main="",
  ylim=c(max(data$DEPTH),min(data$DEPTH)),
  xlim=c(min(data$TEMP),max(data$TEMP)),
  type='n',
  ylab="Depth (fathoms)",
  xlab="Temperature (F)"
)
for(i in 1:length(tows)){
  x=subset(data,data$tow_id==tows[i])
  lines(
    x$DEPTH~x$TEMP,
    col=tow_col[i],
    lwd=3
  )
}
## Download higher res bathymetric data
bath=marmap::getNOAA.bathy(
  lon1=min(-80.83),
  lon2=max(-56.79),
  lat1=min(35.11),
  lat2=max(46.89),
  resolution=1
)
par(mfrow=c(1,2))
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
  main="",
  xlim=c(-72,-65),
  ylim=c(41.5,45)
)
for(i in 1:length(tows)){
  x=subset(data,data$tow_id==tows[i])
  points(
    x$latitude..degrees_north.[1]~x$longitude..degrees_east.[1],
    pch=1,
    cex=1.75
  )
  points(
    x$latitude..degrees_north.[1]~x$longitude..degrees_east.[1],
    pch=16,
    col=tow_col[i],
    cex=1.5
  )
}
plot(
  data$DEPTH~data$TEMP,
  main="",
  ylim=c(max(data$DEPTH),min(data$DEPTH)),
  xlim=c(min(data$TEMP),max(data$TEMP)),
  type='n',
  ylab="Depth (fathoms)",
  xlab="Temperature (F)"
)
for(i in 1:length(tows)){
  x=subset(data,data$tow_id==tows[i])
  lines(
    x$DEPTH~x$TEMP,
    col=tow_col[i],
    lwd=3
  )
}
