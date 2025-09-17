## We aren't alone
## Plots of publicly available ocean observing in the Northeast USA
## Background Plotting
bath=marmap::getNOAA.bathy(
  lon1=min(-80.83),
  lon2=max(-56.79),
  lat1=min(35.11),
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
end_date=Sys.Date()
start_date=Sys.Date()-lubridate::days(30)
# ## NERACOOS
# url=paste0(
#   "http://www.neracoos.org/erddap/tabledap/B01_sbe37_all.csvp?time%2Clongitude%2Clatitude&time%3E=",
#   start_date,
#   "T00%3A00%3A00Z&time%3C=",
#   end_date,
#   "T10%3A30%3A00Z"
# )
# nera=read.csv(url)
# url=paste0(
#   "http://www.neracoos.org/erddap/tabledap/I01_sbe37_all.csvp?time%2Clongitude%2Clatitude&time%3E=",
#   start_date,
#   "T00%3A00%3A00Z&time%3C=",
#   end_date,
#   "T10%3A30%3A00Z"
# )
# nera=rbind(nera,read.csv(url))
## eMOLT
emolt=read.csv(
  paste0(
    "https://erddap.emolt.net/erddap/tabledap/eMOLT_RT.csvp?tow_id%2Csegment_type%2Ctime%2Clatitude%2Clongitude%2Cdepth%2Ctemperature%2Csensor_type&segment_type=3&time%3E=",
    lubridate::year(start_date),
    "-",
    lubridate::month(start_date),
    "-",
    lubridate::day(start_date),
    "T00%3A00%3A00Z&time%3C=",
    lubridate::year(Sys.Date()),
    "-",
    lubridate::month(Sys.Date()),
    "-",
    lubridate::day(Sys.Date()),
    "T23%3A59%3A59Z"
  )
)
## ODN
url=paste0(
  "https://erddap.oceandata.net/erddap/tabledap/ODN_Profile_FV_NRT.csvp?time%2Clatitude%2Clongitude&time%3E=",
  start_date,
  "T00%3A00%3A00Z&time%3C=",
  end_date,
  "T00%3A00%3A00Z"
)
odn=read.csv(url)
## CFRF
url=paste0(
  "https://erddap.ondeckdata.com/erddap/tabledap/fixed_gear_oceanography.csvp?time%2Clatitude%2Clongitude&time%3E=",
  start_date,
  "T00%3A00%3A00Z&time%3C=",
  end_date,
  "T00%3A00%3A00Z"
)
if(httr::GET(url)$status_code!=404){
  CFRF=read.csv(url)
}
url=paste0(
  "https://erddap.ondeckdata.com/erddap/tabledap/fixed_gear_oceanography.csvp?time%2Clatitude%2Clongitude&time%3E=",
  start_date,
  "T00%3A00%3A00Z&time%3C=",
  end_date,
  "T00%3A00%3A00Z"
)
if(httr::GET(url)$status_code!=404){
  CFRF=rbind(CFRF,read.csv(url))
}
url=paste0(
  "https://erddap.ondeckdata.com/erddap/tabledap/shelf_fleet_profiles_1m_binned.csvp?latitude%2Clongitude%2Ctime&time%3E=",
  start_date,
  "T00%3A00%3A00Z&time%3C=",
  end_date,
  "T00%3A00%3A00Z"
)
if(httr::GET(url)$status_code!=404){
  CFRF=rbind(CFRF,read.csv(url))
}
url=paste0(
  "https://erddap.ondeckdata.com/erddap/tabledap/wind_farm_profiles_1m_binned.csvp?latitude%2Clongitude%2Ctime&time%3E=",
  start_date,
  "T00%3A00%3A00Z&time%3C=",
  end_date,
  "T18%3A39%3A35Z"
)
if(httr::GET(url)$status_code!=404){
  CFRF=rbind(CFRF,read.csv(url))
}
## Argo
url=paste0(
  "https://erddap.ifremer.fr/erddap/tabledap/ArgoFloats.csvp?time%2Clatitude%2Clongitude&time%3E=",
  start_date,
  "T00%3A00%3A00Z&time%3C=",
  end_date,
  "T00%3A00%3A00Z"
)
argo_dat=read.csv(url)
## Oleander
url=paste0(
  "http://erddap.oleander.bios.edu:8080/erddap/tabledap/oleanderXbt.csvp?time%2Clatitude%2Clongitude&time%3E=",
  start_date,
  "T00%3A00%3A00Z&time%3C=",
  end_date,
  "T00%3A00%3A00Z"
)
oleander_dat=read.csv(url)
## Rutgers Gliders

pb=txtProgressBar(char=" --|- ",style=3)
rucool_gliders=c(
  "ru29-20250715T1838",
  "ru32-20250716T1541",
  "ru38-20250722T1538",
  "ru39-20250716T1542",
  "ru43-20250716T1522",
  "ru44-20250717T2326",
  "sbu02-20250716T1543"
  )
glider_dat=data.frame(
  time..UTC.=as.character(),
  latitude..degrees_north.=as.numeric(),
  longitude..degrees_east.=as.numeric(),
  TIME=as.character(),
  LAT=as.numeric(),
  LON=as.numeric()
)
for(g in rucool_gliders){
  url=paste0(
    "https://slocum-data.marine.rutgers.edu/erddap/tabledap/",
    g,
    "-trajectory-raw-rt.csvp?time%2Clatitude%2Clongitude&time%3E=",
    start_date,
    "T00%3A00%3A00Z&time%3C=",
    end_date,
    "T09%3A36%3A49Z&latitude%3E=35&latitude%3C=45&longitude%3E=-75&longitude%3C=-66"
  )
  if(httr::GET(url)$status_code!=404){
    data=read.csv(url)
    ## hourly averages for gliders
    data$TIME=lubridate::ymd_hms(data$time..UTC.)
    data$TIME=lubridate::floor_date(data$TIME,unit='hours')
    data$dup=duplicated(data$TIME)
    new_dat=subset(data,data$dup==FALSE)
    new_dat$LAT=NA
    new_dat$LON=NA
    for(n in 1:nrow(new_dat)){
      new_dat$LAT[n]=mean(subset(data,data$TIME==new_dat$TIME[n])$latitude..degrees_north.)
      new_dat$LON[n]=mean(subset(data,data$TIME==new_dat$TIME[n])$longitude..degrees_east.)
    }
    glider_dat=rbind(glider_dat,new_dat)
    rm(data,new_dat)
  }
  setTxtProgressBar(
    pb,
    which(rucool_gliders==g)/length(rucool_gliders)
  )
}

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
  xlim=c(-75,-66),
  ylim=c(35,45),
  main=paste0(
    "Subsurface Observations from ",
    start_date,
    " to ",
    end_date
  )
)
points(glider_dat$LAT~glider_dat$LON,pch=16,col='red')
points(oleander_dat$latitude..degrees_north.~oleander_dat$longitude..degrees_east.,pch=16,col='purple')
points(argo_dat$latitude..degrees_north.~argo_dat$longitude..degrees_east.,pch=16,col='brown')
points(CFRF$latitude..degrees_north.~CFRF$longitude..degrees_east.,pch=16,col='blue')
points(odn$latitude..degrees_north.~odn$longitude..degrees_east.,pch=16,col='blue')
# points(nera$latitude..degrees_north.~nera$longitude..degrees_east.,pch=16,col='magenta2')
points(emolt$latitude..degrees_north.~emolt$longitude..degrees_east.,pch=16,col='blue')
legend(
  "topleft",
  col=c("magenta2","blue","red","brown","purple"),
  legend=c("NERACOOS Buoys","Fishing Vessels","Gliders","Argo","M/V Oleander"),
  pch=16
)
