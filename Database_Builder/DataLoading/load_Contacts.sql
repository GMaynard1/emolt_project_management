LOAD DATA INFILE '/var/lib/mysql-files/Independent_Tables/Contacts.csv'
INTO TABLE CONTACTS
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;