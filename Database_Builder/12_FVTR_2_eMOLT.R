## ---------------------------
## Script name: FVTR_2_eMOLT.R
##
## Purpose of script: To reformat the raw exports from FVTR@sole to 
##    be uploaded into the eMOLT database
##
## Date Created: 2022-03-10
##
## Copyright (c) NOAA Fisheries, 2022
##
## Email: george.maynard@noaa.gov
##
## ---------------------------
## Notes: Requires the following exports from FVTR@sole
##   - FVTR.FVTR_PORTS
##   - FVTR.FVTR_GEAR_CODES
##
## ---------------------------

## Import the ports file
ports=read.csv(file.choose())

## Add three columns for Latitude, Longitude, and eMOLT region
ports$LATITUDE=NA
ports$LONGITUDE=NA
ports$EMOLT_REGION=NA

## Assign as many regions as possible based on STATE_POSTAL values
ports$EMOLT_REGION=ifelse(
  ports$STATE_POSTAL=="CN",
  "Canada",
  ifelse(
    ports$STATE_POSTAL=="RI",
    "Rhode Island",
    ifelse(
      ports$STATE_POSTAL=="NJ",
      "New Jersey",
      ifelse(
        ports$STATE_POSTAL=="ME",
        "Maine",
        ifelse(
          ports$STATE_POSTAL=="NH",
          "North Shore",
          ifelse(
            ports$STATE_POSTAL=="NY",
            "New York",
            ifelse(
              ports$STATE_POSTAL=="CT",
              "Connecticut",
              ports$EMOLT_REGION
            )
          )
        )
      )
    )
  )
)
## Massachusetts ports can be broken out by county
ports$EMOLT_REGION=ifelse(
  is.na(ports$EMOLT_REGION)==FALSE,
  ports$EMOLT_REGION,
  ifelse(
    ports$COUNTY_NAME%in%c("Plymouth","Barnstable","Dukes","Nantucket"),
    "Cape Cod",
    ifelse(
      ports$COUNTY_NAME=="Bristol",
      "New Bedford",
      ifelse(
        ports$COUNTY_NAME%in%c("Essex","Middlesex"),
        "North Shore",
        ports$EMOLT_REGION
      )
    )
  )
)
## Essex and Middlesex are fairly common county names on the eastern seaboard
## so non-MA and NH instances should be excluded
ports$EMOLT_REGION=ifelse(
  ports$EMOLT_REGION=="North Shore"&(ports$STATE_POSTAL%in%c("MA","NH")==FALSE),
  NA,
  ports$EMOLT_REGION
)
