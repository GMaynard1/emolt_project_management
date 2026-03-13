## Download FISHBOT data from ERDDAP
year=2025
end=lubridate::ymd(paste0(year,"-12-31"))
start=lubridate::ymd(paste0(year,"-01-01"))
url=paste0(
  "https://erddap.ondeckdata.com/erddap/tabledap/fishbot_realtime.csvp?time%2Ctemperature%2Ctemperature_count%2Cdata_provider%2Cgrid_id%2Clatitude%2Clongitude&time%3E=",
  lubridate::year(start),
  "-",
  lubridate::month(start),
  "-",
  lubridate::day(start),
  "T00%3A00%3A00Z&time%3C=",
  lubridate::year(end),
  "-",
  lubridate::month(end),
  "-",
  lubridate::day(end),
  "T00%3A00%3A00Z"
)
# url=paste0(
#   'https://erddap.ondeckdata.com/erddap/tabledap/fishbot_realtime.csvp?time%2Ctemperature%2Ctemperature_count%2Cdata_provider%2Cgrid_id%2Clatitude%2Clongitude&time%3E=2025-08-21T00%3A00%3A00Z&time%3C=2025-08-28T00%3A00%3A00Z'
# )
data=read.csv(url)
## Download bathymetric data
bath=marmap::getNOAA.bathy(
  lon1=min(-80.83),
  lon2=max(-56.79),
  lat1=min(34),
  lat2=max(46.89),
  resolution=1
)
# ## Create color ramp
# blues=c(
#   "lightsteelblue4", 
#   "lightsteelblue3",
#   "lightsteelblue2", 
#   "lightsteelblue1"
# )
## Set up plot
# png("C:/Users/george.maynard/Documents/GitHubRepos/emolt_project_management/WeeklyUpdates/FISHBOT.png",height=1000, width=800,units="px")
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
#   main=paste0(
#     "Days Observed Between ",
#     start,
#     " and ",
#     end
#   ),
#   xlim=c(-76,-66),
#   ylim=c(34,45)
# )
## Load the shapefile
grid=sf::read_sf("C:/Users/george.maynard/Documents/GIS/7km_trimmed_fixedgeometries/7km_grid_clipped_fixed_geometry.shp")
grid=subset(grid,grid$id%in%data$grid_id)
grid$nobs=NA
grid$color=NA
data$date=lubridate::floor_date(lubridate::ymd_hms(data$time..UTC.),unit="day")
for(i in 1:nrow(grid)){
  x=subset(data,data$grid_id==grid$id[i])
  
  grid$nobs[i]=length(unique(x$date))
}
grid=subset(grid,grid$nobs>0)
tempcol=viridis::rocket(n=length(seq(1,365,1)),direction = -1)
# alpha=seq(1,365,1)/365+0.1
# alpha=ifelse(alpha>1,1,alpha)
# tempcol=colorspace::adjust_transparency(tempcol,alpha=alpha)
for(i in 1:nrow(grid)){
  grid$color[i]=tempcol[which(seq(1,365,1)==grid$nobs[i])]
}
colorgrid=subset(grid,grid$nobs>0)
layout(matrix(1:2, nrow = 1), widths = c(8, 2))
plot(
  sf::st_geometry(colorgrid),
  col=colorgrid$color,
  border=colorgrid$color,
  lwd=0.1,
  reset=FALSE,
  xlim=c(-74,-67),
  ylim=c(35,45),
  expandBB=c(0,0,0,0)
)
plot(sf::st_geometry(us.coast),add=TRUE,border='gray',color='lightgray')
par(mar = c(5, 1, 5, 4))
image(
  x = 1, 
  y = seq(1, 365, 1), 
  z = matrix(1:365, nrow = 1), 
  col = tempcol,
  xaxt = "n",      # Hide X axis
  yaxt = "n",      # Custom Y axis below
  xlab = "", 
  ylab = ""
)
axis(4, at = seq(0, 365, by = 50), las = 2)
mtext("Days observed", side = 4, line = 2.5, cex = 0.8)
# dev.off()
