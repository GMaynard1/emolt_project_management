download_doppio=function(tow,date,lat,lon){
  ## Check the server for the most recent forecast (should be today or yesterday)
  url=paste0(
    "https://tds.marine.rutgers.edu/thredds/catalog/roms/doppio/2017_da/his/runs/catalog.html?dataset=roms/doppio/2017_da/his/runs/History_RUN_",
    Sys.Date(),
    "T00:00:00Z"
  )
  if(httr::HEAD(url)$status_code==404){
    for(d in seq(1,7,1)){
      url=paste0(
        "https://tds.marine.rutgers.edu/thredds/catalog/roms/doppio/2017_da/his/runs/catalog.html?dataset=roms/doppio/2017_da/his/runs/History_RUN_",
        Sys.Date()-lubridate::days(d),
        "T00:00:00Z"
      )
      if(httr::HEAD(url)$status_code==200){
        most_recent=Sys.Date()-lubridate::days(d)
        break()
      } 
    }
  } else {
    most_recent=Sys.Date()
  }
  ## Build the filename based on the tow_id
  filename=paste0(tow,"_doppio.nc")
  ## Use the forecast closest to the observation
  if(date>most_recent){
    date=most_recent
  }
  ## Build the download command based on the date and coordinates
  command=paste0(
    "ncks --overwrite -M -d time,",
    lubridate::floor_date(date,unit="day"),
    " -d s_rho,0 -v lat_rho,",
    floor(lat),
    ",",
    ceiling(lat),
    " -v lon_rho,",
    floor(lon),
    ",",
    ceiling(lon),
    " -v temp https://tds.marine.rutgers.edu/thredds/dodsC/roms/doppio/2017_da/his/History_Best ",
    filename
  )
  system(command)
}
