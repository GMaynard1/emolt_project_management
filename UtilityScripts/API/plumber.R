# plumber.R

#* Get MAC addresses associated with vessels
#* @param vessel The vessel of interest
#* @get /readMAC
function(vessel="ALL"){
  ## Collect login info from file
  user=read.csv("../../eMOLT-db/Login/logins.csv")$Username[1]
  password=read.csv("../../eMOLT-db/Login/logins.csv")$Password[1]
  dbname=read.csv("../../eMOLT-db/Login/logins.csv")$Database[1]
  host=read.csv("../../eMOLT-db/Login/logins.csv")$Host[1]
  port=read.csv("../../eMOLT-db/Login/logins.csv")$Port[1]
  ## Connect to database
  mydb=dbConnect(
    MySQL(), 
    user=user, 
    password=password, 
    dbname=dbname, 
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
  ## Collect login info from file
  user=read.csv("../../eMOLT-db/Login/logins.csv")$Username[1]
  password=read.csv("../../eMOLT-db/Login/logins.csv")$Password[1]
  dbname=read.csv("../../eMOLT-db/Login/logins.csv")$Database[1]
  host=read.csv("../../eMOLT-db/Login/logins.csv")$Host[1]
  port=read.csv("../../eMOLT-db/Login/logins.csv")$Port[1]
  ## Connect to database
  mydb=dbConnect(
    MySQL(), 
    user=user, 
    password=password, 
    dbname=dbname, 
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

#* Add new vessel record to database
#* @param vessel The vessel of interest
#* @param main_contact Who is the best point of contact for the vessel
#* @param owner Who owns the vessel
#* @param captain Who operates the vessel
#* @param tech who provides technical support for the vessel
#* @param funding how was equipment purchase for the vessel funded
#* @param home_port what is the vessel's homeport
#* @param date when was the most recent visit to the vessel
#* @param aquatec_sn  what is the serial number of the Aquatec unit on board
#* @param lowell_sn what is the serial number of the lowell logger on board
#* @param logger_change when was the logger changed most recently
#* @param current_esn what is the satellite ESN of the vessel
#* @param notes any additional notes about the vessel
#* @param gear_type fixed or mobile
#* @post /addVessel
function(
  vessel,
  main_contact,
  owner,
  captain,
  tech,
  funding,
  home_port,
  date,
  aquatec_sn="NULL",
  lowell_sn="NULL",
  logger_change="NULL",
  current_esn="NULL",
  notes="NULL",
  gear_type
  ){
  ## Collect login info from file
  user=read.csv("../../eMOLT-db/Login/logins.csv")$Username[2]
  password=read.csv("../../eMOLT-db/Login/logins.csv")$Password[2]
  dbname=read.csv("../../eMOLT-db/Login/logins.csv")$Database[2]
  host=read.csv("../../eMOLT-db/Login/logins.csv")$Host[2]
  port=read.csv("../../eMOLT-db/Login/logins.csv")$Port[2]
  ## Connect to the database
  mydb=dbConnect(
    MySQL(), 
    user=user, 
    password=password, 
    dbname=dbname, 
    host=host,
    port=port
  )
  ## Start a response message
  response=paste0(
    "Successfully connected to database at ",
    Sys.time(),
    ". "
  )
  ## Check to see if the funding source exists. If not, add a record.
  x=dbGetQuery(
    conn=mydb,
    statement=paste0(
      "SELECT * FROM FUNDING WHERE FUNDING_AGENCY = '",
      funding,
      "'"
    )
  )
  if(nrow(x)==0){
    dbGetQuery(
      conn=mydb,
      statement=paste0(
        "INSERT INTO FUNDING (FUNDING_ID,FUNDING_AGENCY,START_DATE,END_DATE,FUNDING_AMOUNT_USD,PROPOSAL_LINK) VALUES (0,'",
        funding,
        "',NULL,NULL,0,NULL)"
      )
    )
    response=paste0(
      response,
      "Added new record for ",
      funding,
      "to FUNDING. "
    )
  }
  ## Store the appropriate funding ID for the new system
  funding_id=dbGetQuery(
    conn=mydb,
    statement=paste0(
      "SELECT FUNDING_ID FROM FUNDING WHERE FUNDING.FUNDING_AGENCY = '", 
      funding,
      "'"
    )
  )
  
  print(response)
}