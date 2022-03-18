## ---------------------------
## Script name: 13_OldOracle_2_MySQL.R
##
## Purpose of script: To convert tables from Jim's original Oracle db of
##  traditional (non-realtime) eMOLT participants to the new MySQL format
##
## Date Created: 2022-03-15
##
## Copyright (c) NOAA Fisheries, 2022
##
## Email: george.maynard@noaa.gov
##
## ---------------------------
## Notes: This script requires access to downloads from eMOLT.*@nova
##   
## ---------------------------
## Necessary libraries
library(dplyr)
library(stringr)
## ---------------------------
## Read in the EMOLT_PEOPLE table to convert to CONTACTS format
people=read.csv(file.choose())
## Some fields are deprecated and can be removed. Keep only what's needed
people=select(people,LAST_NAME,FIRST_NAME,PHONE_HOME,EMAIL_HOME,EMAIL_BOAT,TITLE,PHONE_CELL,STREET_ADDRESS,INSTITUTE,VESSEL,TOWN,STATE,ZIP,HOME_PORT,HOME_STATE)
## Create a vector of First Names -- all uppercase
FIRST_NAME=toupper(people$FIRST_NAME)
## Create a vector of Last Names -- all uppercase
LAST_NAME=toupper(people$LAST_NAME)
## Create a standardized phone column
PHONE=people$PHONE_HOME
PHONE=gsub(
  "-",
  "",
  PHONE
)
## Create a standardized mobile column
MOBILE=people$PHONE_CELL
MOBILE=gsub(
  "-",
  "",
  MOBILE
)
## Merge mobile and phone into one column, preferring mobile
PHONE=ifelse(
  MOBILE!="",
  MOBILE,
  PHONE
)
## Create a standardized email column, prioritizing home emails over vessel emails
EMAIL=toupper(
  ifelse(
    people$EMAIL_HOME!="",
    people$EMAIL_HOME,
    people$EMAIL_BOAT
    )
  )
## Read in street addresses and convert to all upper case
STREET_1=toupper(people$STREET_ADDRESS)
## Read in city names and convert to all upper case
CITY=toupper(people$TOWN)
## Standardize states
STATE_POSTAL=toupper(people$STATE)
STATE_POSTAL=ifelse(
  STATE_POSTAL=="MAINE",
  "ME",
  ifelse(
    STATE_POSTAL=="MASS",
    "MA",
    ifelse(
      STATE_POSTAL=="NEW BRUNSWICK",
      "NB",
      ifelse(
        STATE_POSTAL=="NOVA SCOTIA",
        "NS",
        STATE_POSTAL
      )
    )
  )
)
## Insert leading zeros into zip codes where appropriate
ZIP=people$ZIP
ZIP=ifelse(
  nchar(ZIP)==4,
  paste0(0,ZIP),
  ZIP
)
## Standardize Roles as able <-- Check these with Jim
ROLE=toupper(people$INSTITUTE)
ROLE=ifelse(
  ROLE%in%c(
    "ATLANTIC OFFSHORE LOBSTER ASSOCIATION",
    "ATLANTIC OFFSHORE LOBSTERASSOCIATION",
    "ATLANTIC OFFSHORE LOBSTERMEN",
    "COMMERCIAL FISHERMEN",
    "DOWNEAST LOBSTER ASSOCIATION",
    "MAINE LOBSTER ASSOCIATION",
    "MAINE LOBSTERMEN",
    "MASS LOBSTER ASSOCIATION",
    "MASS LOBSTERMEN",
    "RHODE ISLAND LOBSTERMEN",
    "SOUTH SHORE LOBSTERMEN"),
  "ACTIVE_INDUSTRY",
  ROLE
)
## Add in vessel and home port columns to facilitate matching to other tables
VESSEL=toupper(
  people$VESSEL
)
HOME_PORT=toupper(
  people$HOME_PORT
)
HOME_STATE=toupper(
  people$HOME_STATE
)
## Combine all columns into the new table format, removing leading and trailing
##    whitespaces
CONTACTS=data.frame(
  str_trim(FIRST_NAME),
  str_trim(LAST_NAME),
  str_trim(PHONE),
  str_trim(EMAIL),
  PREFERRED_CONTACT=NA,
  str_trim(STREET_1),
  STREET_2=NA,
  str_trim(CITY),
  str_trim(STATE_POSTAL),
  str_trim(ZIP),
  ROLE=NA
)
write.csv(
  CONTACTS,
  "C:/Users/george.maynard/Documents/eMOLT-db/Uploads/Independent_Tables/Contacts_pt1.csv",
  row.names=FALSE
)
