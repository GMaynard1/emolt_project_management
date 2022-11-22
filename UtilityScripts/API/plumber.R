# plumber.R
require(jsonlite)
require(plumber)
require(RMySQL)
require(wkb)
source('login.R')

#* @apiTitle eMOLT dev API
#* @apiDescription This is the development API for the eMOLT project.
#* @apiContact list(name="API Support",email="george.maynard@noaa.gov") 


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
    statement="SELECT * FROM vessel_mac"
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
  ## Use the IMEI number and the transmitter serial number to look up the vessel
  ## in the database
  mydb=dbConnect(
    MySQL(), 
    user=username, 
    password=password, 
    dbname=db, 
    host=host,
    port=port
  )
  ## Parse the datastring into distinct elements
  ## Latitude
  raw=strsplit(datastring,",")[[1]][1]
  lat=as.numeric(substr(raw,1,2))+as.numeric(substr(raw,3,nchar(raw)))/60
  ## Longitude
  raw=strsplit(datastring,",")[[1]][2]
  lon=as.numeric(substr(raw,1,2))*-1-as.numeric(substr(raw,3,nchar(raw)))/60
  ## Depth (m) 
  raw=substr(strsplit(datastring,",")[[1]][3],1,3)
  depth=as.numeric(
    substr(raw,1,3)
  )
  ## Total range of depths observed (m)
  raw=substr(strsplit(datastring,",")[[1]][3],4,6)
  rangedepth=as.numeric(
    substr(raw,1,3)
  )
  ## Soak time (minutes for mobile gear, hours for fixed gear)
  ## The old way of recording soak time used different units depending on gear 
  ## type. The new way will be a 5 character string of minutes
  ##### NEW #####
  #raw=as.numeric(substr(strsplit(datastring,",")[[1]][3],7,11))
  #####
  ##### OLD #####
  raw=as.numeric(substr(strsplit(datastring,",")[[1]][3],7,9))
  ## LOOK UP GEAR CODE ASSOCIATED WITH VESSEL HERE
  if(mobile==TRUE){
    soak=raw
  } else {
    soak=raw*60
  }
  #####
  ## Average temperature (C)
  avgTemp=as.numeric(substr(strsplit(datastring,",")[[1]][3],10,13))/100
  ## Standard deviation of temperature (C)
  stdTemp=as.numeric(substr(strsplit(datastring,",")[[1]][3],14,17))/100
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
    temps=NA
  }
  res$body=datastring
  res
}

#* Create the setup_rtd.py file that contains metadata for an emolt installation
#* @param vessel The name of the vessel you are creating a setup file for
#* @post /setup_rtd
function(vessel){
  vessel=toupper(gsub("_"," ",vessel))
  time_range=1
  Fathom=0.1
  transmitter='yes'
  mac_addr=dbGetQuery(
    conn=conn,
    statement=paste0(
      "SELECT HARDWARE_ADDRESS FROM vessel_mac WHERE VESSEL_NAME = '",
      toupper(gsub("_"," ",vessel)),
      "'"
    )
  )$HARDWARE_ADDRESS
  moana_SN=dbGetQuery(
    conn=conn,
    statement=paste0(
      "SELECT SERIAL_NUMBER FROM vessel_mac WHERE VESSEL_NAME = '",
      toupper(gsub("_"," ",vessel)),
      "'"
    )
  )$SERIAL_NUMBER
  gear_type=dbGetQuery(
    conn=conn,
    statement=paste0(
      "SELECT GEAR_CODES.FMCODE FROM GEAR_CODES INNER JOIN VESSELS ON GEAR_CODES.GEAR_CODE = VESSELS.PRIMARY_GEAR WHERE VESSELS.VESSEL_NAME = '",
      vessel,
      "'"
    )
  )$FMCODE
  if(gear_type=="F"){
    gear_type="fixed"
  } else {
    if(gear_type=="M"){
      gear_type="mobile"
    } else {
      if(gear_type=="O"){
        gear_type="other"
      } else {
        gear_type="UNKNOWN: DATABASE UPDATE REQUIRED"
      }
    }
  }
  vessel_num=dbGetQuery(
    conn=conn,
    statement=paste0(
      "SELECT EMOLT_NUM FROM VESSELS WHERE VESSEL_NAME = '",
      vessel,
      "'"
    )
  )$EMOLT_NUM
  vessel_name=vessel
  tilt="no"
  path="/home/pi/rtd_global/"
  sensor_type=dbGetQuery(
    conn=conn,
    statement=paste0(
      "SELECT MAKE FROM vessel_mac WHERE VESSEL_NAME = '",
      vessel,
      "'"
    )
  )
  time_diff_nke=0
  tem_unit="Fahrenheit"
  depth_unit="Fathoms"
  local_time=-4
}