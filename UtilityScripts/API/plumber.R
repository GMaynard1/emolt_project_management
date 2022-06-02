# plumber.R
require(plumber)
require(RMySQL)
require(wkb)
source('login.R')


#* Get MAC addresses associated with vessels
#* @param vessel The vessel of interest
#* @get /readMAC
function(vessel="ALL"){
  ## Collect login info from file
  ## Connect to database
  mydb=dbConnect(
    MySQL(), 
    user=username, 
    password=password, 
    dbname=db, 
    host=host,
    port=port
    )
  data=dbGetQuery(
    conn=mydb,
    statement="SELECT * FROM VESSEL_MAC"
  )
  if(vessel=="ALL"){
    print(data)
  } else {
    print(subset(data,data$VESSEL_NAME==toupper(vessel)))
  }
}

#* Get SIM ICCIDs associated with vessels
#* @param vessel The vessel of interest
#* @get /readSIM
function(vessel="ALL"){
  ## Connect to database
  mydb=dbConnect(
    MySQL(), 
    user=username, 
    password=password, 
    dbname=db, 
    host=host,
    port=port
  )
  data=dbGetQuery(
    conn=mydb,
    statement="SELECT * FROM VESSEL_SIM"
  )
  if(vessel=="ALL"){
    print(data)
  } else {
    print(subset(data,data$VESSEL_NAME==toupper(vessel)))
  }
}

#* Insert a reboot record into the database
#* @param timestamp The time that the device rebooted
#* @param MAC The MAC address of the device
#* @param IP The IP address of the device
#* @post /insert_reboot
function(timestamp, MAC, IP){
  ## Read in the login credentials from a file
  user=username
  password=password
  dbname=db
  host=host
  port=port
  ## Connect to database
  mydb=dbConnect(
    MySQL(), 
    user=user, 
    password=password, 
    dbname=dbname, 
    host=host,
    port=port
  )
  ## Look up the MAC address
  temp=dbGetQuery(
    conn=mydb,
    statement=paste0(
      "SELECT * FROM VESSEL_MAC WHERE HARDWARE_ADDRESS = '",
      MAC,
      "'"
    )
  )
  ## If the MAC address doesn't exist in the database, return an error
  if(nrow(temp)==0){
    stop("MAC address not found")
  } else {
    ## Otherwise, form an insert statement using the correct hardware ID
    hid=dbGetQuery(
      conn=mydb,
      statement=paste0(
        "SELECT HARDWARE_ID FROM HARDWARE_ADDRESSES WHERE ADDRESS_TYPE = 'MAC' AND HARDWARE_ADDRESS = '",
        MAC,
        "'"
      )
    )[1,1]
    statement=paste0(
      "INSERT INTO TELEMETRY_STATUS (`TS_REPORT_ID`,`TS_LATITUDE`,`TS_LONGITUDE`,`TS_REPORT_DATE`,`TR_AMT_MB`,`HARDWARE_ID`,`IP_ADDRESS`) VALUES (0,NULL,NULL,'",
      timestamp,
      "',NULL,",
      hid,
      ",'",
      IP,
      "')"
    )
    ## Execute the statement
    dbGetQuery(
      conn=mydb,
      statement=statement
    )
  }
}

#* Record status updates and haul average data transmissions via satellite
#* @param imei The IMEI number of the device
#* @param device_type The type of device
#* @param serial Serial number of the device
#* @param momsn Number of messages sent from the device
#* @param transmit_time Timestamp of message transmission
#* @param data Information sent in the report whether a status update or data upload
#* @post /getRock_API
function(imei, device_type, serial, momsn, transmit_time, data, res){
  ## Convert the data from hex to character
  datastring=rawToChar(
    as.raw(
      strtoi(
        wkb::hex2raw(data),
        16L
      )
    )
  )
  ## Parse the datastring into distinct elements
  ## Latitude
  raw=strsplit(datastring,",")[[1]][1]
  lat=as.numeric(substr(raw,1,2))+as.numeric(substr(raw,3,nchar(raw)))/60
  ## Longitude
  raw=strsplit(datastring,",")[[1]][2]
  lon=as.numeric(substr(raw,1,2))*-1-as.numeric(substr(raw,3,nchar(raw)))/60
  ## Depth (m) 
  ## CHECK WITH HUANXIN TO MAKE SURE THIS IS RIGHT
  raw=substr(strsplit(datastring,",")[[1]][3],1,3)
  depth=as.numeric(
    paste0(
      substr(raw,1,2),
      ".",
      substr(raw,3,3)
    )
  )
  ## Total range of depths observed (m)
  ## CHECK WITH HUANXIN TO MAKE SURE THIS IS RIGHT
  raw=substr(strsplit(datastring,",")[[1]][3],4,6)
  rangedepth=as.numeric(
    paste0(
      substr(raw,1,2),
      ".",
      substr(raw,3,3)
    )
  )
  ## Soak time (minutes for mobile gear, hours for fixed gear)
  raw=as.numeric(substr(strsplit(datastring,",")[[1]][3],7,9))
  ## LOOK UP GEAR CODE ASSOCIATED WITH VESSEL HERE
  if(mobile==TRUE){
    soak=raw
  } else {
    soak=raw*60
  }
  ## Average temperature (C)
  raw=as.numeric(substr(strsplit(datastring,",")[[1]][3],10,14))/100
  ## Standard deviation of temperature (C)
  ## Last four characters of MAC Address and daily average temperatures 
  ## (up to five, fixed gear only)
  if(mobile!=TRUE){
    raw=strsplit(datastring,"eee")[[1]][2]
    MAC4=substring(
      raw,
      seq(1,nchar(raw),4),
      seq(4,nchar(raw),4)
    )[1]
    temps=substring(
      raw,
      seq(1,nchar(raw),4),
      seq(4,nchar(raw),4)
    )[2:(length(
      substring(
        raw,
        seq(1,nchar(raw),4),
        seq(4,nchar(raw),4)
      )
    )-1)]
    for(i in 1:length(temps)){
      temps[i]=paste0(
        substr(temps[i],1,2),
        ".",
        substr(temps[i],3,4)
      )
    }
    temps=as.numeric(temps)
  } else {
    raw=strsplit(datastring,"eee")[[1]][2]
    MAC4=substring(
      raw,
      1,
      4
    )
  }
  res$body=datastring
  res
}