CREATE TABLE `TELEMETRY_STATUS`(
  `TS_REPORT_ID` integer NOT NULL AUTO_INCREMENT COMMENT 'A unique identifier used in this database only',
  `TS_LATITUDE` decimal(10,5) COMMENT 'Latitude of last telemetry status report',
  `TS_LONGITUDE` decimal(10,5) COMMENT 'Longitude of last telemetry status report',
  `TS_REPORT_DATE` datetime NOT NULL COMMENT 'Timestamp of last telemetry status report',
  `TR_AMT_MB` decimal(10,2) COMMENT 'Amount of data transmitted since the last telemetry status report or in the last 24 hours, double check with Lowell',
  `HARDWARE_ID` integer NOT NULL COMMENT 'References eMOLT_dev.HARDWARE_ADDRESSES',
  `IP_ADDRESS` varchar(16) COMMENT 'IP address of device',
  
  PRIMARY KEY (`TS_REPORT_ID`),
  
  CONSTRAINT fk_HwAddress
  FOREIGN KEY (`HARDWARE_ID`) 
    REFERENCES HARDWARE_ADDRESSES(HARDWARE_ID)
)COMMENT='This table allows collection, storage, and display of automated records generated by hardware on vessels that indicate whether the hardware is functional at a particular moment in time.';