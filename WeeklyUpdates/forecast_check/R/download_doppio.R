## Download a Doppio netCDF file
download_doppio=function(tow,date,lat,lon,most_recent=NA){
  ## Build the URL from the specified time and location
  url=
    paste0("https://tds.marine.rutgers.edu/thredds/ncss/roms/doppio/2017_da/his/runs/History_RUN_",
           lubridate::year(date),
           "-",
           lubridate::month(date),
           "-",
           lubridate::day(date)-1,
           "T00:00:00Z?var=temp&north=",
           ceiling(lat),
           "&west=",
           floor(lon),
           "&east=",
           ceiling(lon),
           "&south=",
           floor(lat),
           "&disableProjSubset=on&horizStride=1&time=",
           lubridate::year(date),
           "-",
           lubridate::month(date),
           "-",
           lubridate::day(date),
           "T",
           lubridate::hour(date),
           "%3A00%3A00Z&vertCoord=-.9875&accept=netcdf"
    )
  ## Attempt to download the file
  filename=paste0(
    tow,
    "_doppio.nc"
  )
  if(file.exists(filename)==FALSE){
    ## If the file doesn't exist in the historic archive because it's too new
    ## download the latest forecast instead
    if(httr::HEAD(url)$status_code==200){
      curl::curl_download(url,filename)
      most_recent=date
      return(most_recent)
    } else {
      url=paste0("https://tds.marine.rutgers.edu/thredds/ncss/roms/doppio/2017_da/his/runs/History_RUN_",
                 lubridate::year(most_recent),
                 "-",
                 lubridate::month(most_recent),
                 "-",
                 lubridate::day(most_recent)-1,
                 "T00:00:00Z?var=temp&north=",
                 ceiling(lat),
                 "&west=",
                 floor(lon),
                 "&east=",
                 ceiling(lon),
                 "&south=",
                 floor(lat),
                 "&disableProjSubset=on&horizStride=1&time=",
                 lubridate::year(date),
                 "-",
                 lubridate::month(date),
                 "-",
                 lubridate::day(date),
                 "T",
                 lubridate::hour(date),
                 "%3A00%3A00Z&vertCoord=-.9875&accept=netcdf"
      )
      if(httr::HEAD(url)$status_code==200){
        curl::curl_download(url,filename)
        return(most_recent)
      } else {
        print(
          paste0("No forecast available for ",date)
        )
        return(most_recent)
      }
    }
  } else {
    most_recent=date
    return(most_recent)
  }
}
