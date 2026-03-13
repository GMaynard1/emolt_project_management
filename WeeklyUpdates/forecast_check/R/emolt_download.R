emolt_download=function(
    end_date=lubridate::ceiling_date(
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
      "https://erddap.emolt.net/erddap/tabledap/eMOLT_RT.csvp?tow_id%2Csegment_type%2Ctime%2Clatitude%2Clongitude%2Cdepth%2Ctemperature%2Csensor_type%2Cmodel%2Cdata_provider&segment_type=3&time%3E=",
      lubridate::year(start_date),
      "-",
      ifelse(
        nchar(lubridate::month(start_date))==1,
        paste0("0",lubridate::month(start_date)),
        lubridate::month(start_date)
        ),
      "-",
      ifelse(
        nchar(lubridate::day(start_date))==1,
        paste0("0",lubridate::day(start_date)),
        lubridate::day(start_date)
      ),
      "T00%3A00%3A00Z&time%3C=",
      lubridate::year(end_date),
      "-",
      ifelse(
        nchar(lubridate::month(end_date))==1,
        paste0("0",lubridate::month(end_date)),
        lubridate::month(end_date)
      ),
      "-",
      ifelse(
        nchar(lubridate::day(end_date))==1,
        paste0("0",lubridate::day(end_date)),
        lubridate::day(end_date)
      ),
      "T00%3A00%3A00Z&data_provider!=%22Maine%20Coast%20Fishermen's%20Association%22"
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
  
