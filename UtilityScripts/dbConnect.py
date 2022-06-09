## Import necessary packages
import mysql.connector
import yaml

## Open the database connection config file
with open ("C:/Users/george.maynard/Documents/GitHubRepos/emolt_project_management/GUI/GUI-modularized/config.yml","r") as yamlfile:
  dbConfig=yaml.load(yamlfile, Loader=yaml.FullLoader)

## Connect to the development database  
devconn = mysql.connector.connect(
  user = dbConfig['default']['db_remote']['username'],
  password = dbConfig['default']['db_remote']['password'],
  host = dbConfig['default']['db_remote']['host'],
  port = dbConfig['default']['db_remote']['port'],
  database = dbConfig['default']['db_remote']['dbname']
)

## Query all MAC addresses associated with loggers
cursor = devconn.cursor()

query = "SELECT * FROM VESSEL_MAC WHERE EQUIPMENT_TYPE = 'LOGGER'"

cursor.execute(query)

rows = cursor.fetchall()

## For each record returned by the query, print the sensor type, MAC address,
##  vessel name, and emolt vessel number from the telemetry_status Google doc
for row in rows:
  vessel = row[0]
  mac = row[6]
  vn = row[1]
  sensor = row[4]+" "+row[5]
  print("A ", sensor, " with MAC address ", mac, " is on board the F/V ", vessel, " which has been assigned eMOLT Vessel Number: ", vn)
  
