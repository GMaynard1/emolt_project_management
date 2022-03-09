CREATE TABLE `VESSEL_PROGRAM` (
  `VP_RECORD_ID` integer NOT NULL AUTO_INCREMENT COMMENT 'A unique identifier used in this database only',
  `VESSEL_ID` integer NOT NULL COMMENT 'References VESSELS.VESSEL_ID',
  `PROGRAM_ID` integer NOT NULL COMMENT 'References PROGRAMS.PROGRAM_ID',
  `VP_START_DATE` datetime NOT NULL COMMENT 'The approximate date when the vessel joined a particular program',
  `VP_END_DATE` datetime COMMENT 'The approximaate date when the vessel left a particular program (NULL for still active)'
)