LOAD DATA INFILE '/var/lib/mysql-files/Independent_Tables/Gear_All.csv'
INTO TABLE GEAR_CODES
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;