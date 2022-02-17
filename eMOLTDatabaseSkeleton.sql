-- CREATE THE VESSELS TABLE

CREATE TABLE 'VESSELS' (
  'VESSEL_ID' integer NOT NULL AUTO_INCREMENT COMMENT 'A unique identifier used in this database only',
  'VESSEL_NAME' varchar(50) NOT NULL COMMENT 'This field is not unique and should not be used exclusively to identify vessels',
  'PORT' varchar(6) NOT NULL COMMENT 'This field is the standard PORT code used by NEFSC / ACCSP available at FVTR.FVTR_PORTS@sole',
  'OWNER' integer NOT NULL COMMENT 'This field references CONTACTS.CONTACT_ID and identifies the owner of a vessel',
  'OPERATOR' integer NOT NULL COMMENT 'This field references CONTACTS.CONTACT_ID and identifies the operator of a vessel',
  'PRIMARY_CONTACT' integer NOT NULL COMMENT 'This field references CONTACTS.CONTACT_ID and identifies the best contact person for a vessel which could be the owner, the operator, or a fleet manager, Study Fleet tech, etc.',
  'PRIMARY_GEAR' varchar(6) NOT NULL COMMENT 'This field is the type of gear fished by the vessel most often and is the concatenation of ACCSP and VTR gear codes used to map gears between the two data sets available at FVTR.FVTR_GEAR_CODES@sole',
  'PRIMARY_FISHERY' varchar(50) NOT NULL COMMENT 'The primary fishery prosecuted by the vessel',
  'HULL_NUMBER' varchar(30) NOT NULL COMMENT 'The vessel number issued by the federal or state government',
  
  PRIMARY KEY ('VESSEL_ID'),
  KEY `fkIdx_100` (`PORT`),
  CONSTRAINT `FK_100` FOREIGN KEY `fkIdx_100` (`PORT`) REFERENCES `PORTS` (`PORT`),
  KEY `fkIdx_101` (`OWNER`),
  CONSTRAINT `FK_101` FOREIGN KEY `fkIdx_101` (`OWNER`) REFERENCES `CONTACTS` (`CONTACT_ID`),
  KEY `fkIdx_102` (`OPERATOR`),
  CONSTRAINT `FK_102` FOREIGN KEY `fkIdx_102` (`OPERATOR`) REFERENCES `CONTACTS` (`CONTACT_ID`),
  KEY `fkIdx_103` (`PRIMARY_CONTACT`),
  CONSTRAINT `FK_103` FOREIGN KEY `fkIdx_103` (`PRIMARY_CONTACT`) REFERENCES `CONTACTS` (`CONTACT_ID`),
  KEY `fkIdx_104` (`PRIMARY_GEAR`),
  CONSTRAINT `FK_104` FOREIGN KEY `fkIdx_104` (`PRIMARY_GEAR`) REFERENCES `GEAR_CODES` (`GEAR_CODE`),
) COMMENT='This table stores information about vessels involved in the program, who owns and operates them, where they are based, and what fisheries they participate in.';