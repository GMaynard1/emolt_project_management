emolt_download=function(
    end_date=lubridate::round_date(
    lubridate::ymd_hms(
      Sys.time()
    ),
    unit="day"
  ),
  days=7){
  ## Download the last week's data from ERDDAP
  ## Seven days before the specified end is the start date for the data
  start_date=end_date-lubridate::days(days)
  ## Use the dates from above to create a URL for grabbing the data
  full_data=read.csv(
    paste0(
      "http://54.208.149.221:8080/erddap/tabledap/eMOLT_RT.csvp?tow_id%2Csegment_type%2Ctime%2Clatitude%2Clongitude%2Cdepth%2Ctemperature%2Csensor_type&segment_type=%22Fishing%22&time%3E=",
      lubridate::year(start_date),
      "-",
      lubridate::month(start_date),
      "-",
      lubridate::day(start_date),
      "T00%3A00%3A00Z&time%3C=",
      lubridate::year(end_date),
      "-",
      lubridate::month(end_date),
      "-",
      lubridate::day(end_date),
      "T12%3A02%3A43Z"
    )
  )
  ## Randomly select one point per tow to create a subsampled dataset
  data=full_data[0,]
  tows=unique(full_data$tow_id)
  for(i in tows){
    x=subset(
      full_data,
      full_data$tow_id == i
    )
    data=rbind(
      data,
      x[sample(
        (1:nrow(x)),
        1
      ),]
    )
  }
  return(data)
}  
  
