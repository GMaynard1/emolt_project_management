compare_doppio=function(filename,data){
  ## Open the netCDF file and read in temperature values
  ncpath = getwd()
  ncname = filename
  ncfname = paste0(
    ncpath,
    "/",
    ncname
  )
  
  ncin = ncdf4::nc_open(ncfname)
  
  ## Get lat and lon
  lat = ncdf4::ncvar_get(
    ncin,
    "lat_rho"
  )
  lon = ncdf4::ncvar_get(
    ncin,
    "lon_rho"
  )
  
  ## Get temperature and depth
  temp = ncdf4::ncvar_get(ncin, "temp")
  depth = ncdf4::ncvar_get(ncin,"h")
  
  ## Create a data table from lat/lon/temp
  forecast=data.frame(
    lat=as.numeric(),
    lon=as.numeric(),
    temp=as.numeric(),
    depth=as.numeric()
  )
  for(i in 1:length(lat)){
    x=data.frame(
      lat=lat[i],
      lon=lon[i],
      temp=temp[i],
      depth=depth[i]
    )
    forecast=rbind(forecast,x)
  }
  
  ## Remove NA temp values (on land)
  forecast=subset(forecast,forecast$temp!="NaN")
  
  ## Make both forecast and observations spatial objects
  sp.forecast=forecast
  sp::coordinates(sp.forecast) <- ~lon+lat
  sp.data=data[1,]
  sp::coordinates(sp.data) <- ~longitude..degrees_east.+latitude..degrees_north.
  
  ## Calculate pairwise distances between the observation and predictions
  distances=geosphere::distm(
    sp.data,
    sp.forecast,
    fun=geosphere::distGeo
  )
  
  sp.forecast[which(distances==min(distances)),]
  
  ## Structure the output data
  new_output = data.frame(
    distance = min(distances),
    forecast_temp = sp.forecast[which(distances==min(distances)),]$temp,
    obs_temp = sp.data$temperature..degree_C.[1],
    lat = sp.forecast[which(distances==min(distances)),]$lat,
    lon = sp.forecast[which(distances==min(distances)),]$lon,
    date = data$time..UTC.[1]
  )
  
  return(new_output)
}

