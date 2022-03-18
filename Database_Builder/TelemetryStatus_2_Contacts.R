## ---------------------------
## Script name: TelemetryStatus_2_Contacts.R
##
## Purpose of script: To convert a modified version of the telemetry_status
##    Google sheet into the format of the new emolt_dev.CONTACTS table.
##
## Date Created: 2022-03-18
##
## Copyright (c) NOAA Fisheries, 2022
##
## Email: george.maynard@noaa.gov
##
## ---------------------------
## Notes: Requires access to a modified version of telemetry_status and will not
##  work from the raw version of the file available on Google drive
##
## ---------------------------
library(stringr)
## Read in the file
ts=read.csv(file.choose())
## Standardize fields and recombine
CONTACTS=data.frame(
  FIRST_NAME=str_trim(toupper(ts$FIRST_NAME)),
  LAST_NAME=str_trim(toupper(ts$LAST_NAME)),
  PHONE=str_trim(gsub(
    "-",
    "",
    ts$PHONE
  )),
  EMAIL=str_trim(toupper(ts$EMAIL)),
  PREFERRED_CONTACT=NA,
  STREET_1=str_trim(toupper(ts$STREET_1)),
  STREET_2=NA,
  CITY=str_trim(toupper(ts$CITY)),
  STATE_POSTAL=str_trim(toupper(ts$STATE_POSTAL)),
  ZIP=str_trim(ifelse(
    nchar(ts$ZIP)==4,
    paste0(0,ts$ZIP),
    ts$ZIP
  )),
  ROLE=str_trim(ts$ROLE)
)
## Write the clean data out to a new file called Contacts_pt2.csv
write.csv(
  CONTACTS,
  "C:/Users/george.maynard/Documents/eMOLT-db/Uploads/Independent_Tables/Contacts_pt2.csv",
  row.names=FALSE
)
