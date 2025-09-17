## HURRICANE ERIN IMPACTS
## All eMOLT Data
data=read.csv(
  paste0(
    "http://erddap.emolt.net/erddap/tabledap/eMOLT_RT_QAQC.csvp?tow_id%2Csegment_type%2Ctime%2Clatitude%2Clongitude%2Cdepth%2Ctemperature%2Csensor_type&time%3E=",
    '2025-08-14',
    "T00%3A00%3A00Z&time%3C=",
    '2025-08-29'
  )
)
## Shapefile from Kim
regions=sf::st_read("C:/Users/george.maynard/Documents/GIS/EPUs/EPU_wESTUARIES.shp")
## Create a spatial reference for eMOLT data
data=subset(data,is.na(data$latitude..degrees_north.)==FALSE)
data=subset(data,is.na(data$longitude..degrees_east.)==FALSE)
data=sf::st_as_sf(data,coords=c("longitude..degrees_east.","latitude..degrees_north."),crs=sf::st_crs(regions))
## Assign eMOLT data to EPUs
data=sf::st_join(data,regions)
## Reformat to standard units
data$TIME=lubridate::ymd_hms(data$time..UTC.,tz="UTC")
data$TIME=lubridate::with_tz(data$TIME,tz="America/New_York")
data$DEPTH=data$depth..m.*0.546807
data$TEMP=data$temperature..degree_C.*9/5+32
## Add Storm Designation
data$storm=ifelse(
  data$TIME<=lubridate::ymd("2025-08-21"),
  "pre",
  ifelse(
    data$TIME>=lubridate::ymd("2025-08-23"),
    "post",
    "during"
    )
  )
data$stormcolor=ifelse(
  data$storm=='pre',
  'blue',
  ifelse(
    data$storm=='post',
    'red',
    'black'
  )
)
## Plot data by EPU
x=subset(data,data$EPU=="GOM")
## Create a color gradient for temperatures
mintemp=floor(min(x$TEMP))
maxtemp=ceiling(max(x$TEMP))
x$color=NA
tempcol=viridis::magma(n=length(seq(mintemp,maxtemp,1)))
for(i in 1:nrow(x)){
  x$color[i]=tempcol[which(seq(mintemp,maxtemp,1)==round(x$TEMP[i],0))]
}
plot(
  x$DEPTH~x$TIME,
  xlab='',
  ylab='Depth (fathoms)',
  ylim=c(50,0),
  pch=16,
  col=x$color,
  main=x$EPU_Name[1]
)
## Download bathymetric data
bath=marmap::getNOAA.bathy(
  lon1=min(-80.83),
  lon2=max(-56.79),
  lat1=min(34),
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
  xlim=c(-75,-65),
  ylim=c(36,45)
)
points(x$geometry,col=x$stormcolor,pch=1)

box=matrix(c(
  -74,39.5,
  -72,39.5,
  -72,40,
  -74,40,
  -74,39.5),
  ncol=2,
  byrow=TRUE) 
box=sf::st_polygon(list(box))
box=sf::st_sfc(box,crs=sf::st_crs(regions))
z=x[box,]
points(z$geometry,col='hotpink',pch=16)
z$color=NA
tempcol=viridis::magma(n=length(seq(mintemp,maxtemp,1)))
for(i in 1:nrow(z)){
  z$color[i]=tempcol[which(seq(mintemp,maxtemp,1)==round(z$TEMP[i],0))]
}
plot(
  z$DEPTH~z$TIME,
  xlab='',
  ylab='Depth (fathoms)',
  ylim=c(50,0),
  pch=16,
  col=z$color,
  cex=2.5,
  main=z$EPU_Name[1]
)
datacolors=data.frame(
  TEMP=seq(mintemp,maxtemp,1),
  COL=tempcol
)
datacolors=subset(datacolors,datacolors$TEMP%in%round(quantile(datacolors$TEMP),0))
datacolors=datacolors[order(datacolors$TEMP,decreasing=TRUE),]
legend(
  'bottom',
  fill=datacolors$COL,
  border=datacolors$COL,
  legend=datacolors$TEMP,
  title="Bottom Temperature (F)"
)
z=subset(z,z$storm!="during")
z$DC=round(z$DEPTH,-1)
pre=subset(z,z$storm=="pre")
post=subset(z,z$storm=="post")
pre$DC=round(pre$DEPTH,-1)
post$DC=round(post$DEPTH,-1)
boxplot(pre$TEMP~pre$DC,border='blue',cex=1.5,col=NULL,dens=10)
boxplot(post$TEMP~post$DC,border='red',add=TRUE,col=NULL)
boxplot(pre$TEMP~pre$DC,border='blue',cex=1.5,add=TRUE,col=NULL)

for(i in seq(0,60,10)){
  cat("##########\n")
  cat(paste0(i,"\n"))
  cat("--\n")
  y=subset(z,z$DC==i)
  results=wilcox.test(y$TEMP~y$storm)
  print(results)
  cat("\n")
  print(sd(subset(y,y$storm=="pre")$TEMP))
  print(sd(subset(y,y$storm=="post")$TEMP))
  cat("\n")
}
