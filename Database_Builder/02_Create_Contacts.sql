CREATE TABLE `PARTNER_GROUPS` (
  `PARTNER_ID` integer NOT NULL AUTO_INCREMENT COMMENT 'A unique identifier used in this database only',
  `PARTNER_NAME` varchar(100) NOT NULL COMMENT 'Organization name',
  `PARTNER_STREET` varchar(50) COMMENT 'Partner street address',
  `PARTNER_CITY` varchar(50) COMMENT 'City where mailing address is located',
  `PARTNER_STATE` varchar(2) COMMENT 'Two character abbreviation of state or province used by postal service',
  `PARTNER_ZIP` varchar(6) COMMENT 'Postal code, 5 characters for USA and 6 for Canada',
  `PARTNER_PHONE` varchar(10) COMMENT 'Phone number in format xxxxxxxxxx',
  `PARTNER_EMAIL` varchar(100) COMMENT 'Email address of partner organization',
  
  PRIMARY KEY(`PARTNER_ID`)
) COMMENT='This table stores contact information for industry associations, fishing companies, research institutions, etc. that eMOLT participants are affiliated with.';

CREATE TABLE `CONTACTS` (
  `CONTACT_ID` integer NOT NULL AUTO_INCREMENT COMMENT 'A unique identifier used in this database only',
  `FIRST_NAME` varchar(100) NOT NULL COMMENT 'Given name of contact',
  `LAST_NAME` varchar(100) NOT NULL COMMENT 'Surname of contact',
  `PHONE` varchar(10) COMMENT 'Phone number in format xxxxxxxxxx',
  `EMAIL` varchar(50) COMMENT 'Email address',
  `PREFERRED_CONTACT` SET('CALL_PHONE','TXT_PHONE','EMAIL','MAIL','NO CONTACT') COMMENT 'Preferred method of contact',
  `STREET_1` varchar(50) COMMENT 'Street address line 1',
  `STREET_2` varchar(50) COMMENT 'Street address line 2 (if applicable)',
  `CITY` varchar(50) COMMENT 'City of addressee',
  `STATE_POSTAL` varchar(2) COMMENT 'Two character abbreviation of state or province used by postal service',
  `ZIP` varchar(6) COMMENT 'Postal code, 5 characters for USA and 6 for Canada',
  `ROLE` set('ACTIVE_SUPPORT','ACTIVE_INDUSTRY','ACTIVE_ADMIN','INACTIVE','DATA_USER') NOT NULL COMMENT 'A way of categorizing contacts',
  
  PRIMARY KEY (`CONTACT_ID`)
  
) COMMENT='This table stores contact information for eMOLT participants and support staff';

CREATE TABLE `CONTACT_AFFILIATIONS`(
  `AFFILIATION_ID`integer NOT NULL AUTO_INCREMENT COMMENT 'A unique identifier used in this database only',
  `PARTNER_ID` integer NOT NULL COMMENT 'References PARTNER_GROUPS.PARTNER_ID',
  `CONTACT_ID` integer NOT NULL COMMENT 'References CONTACTS.CONTACT_ID',
  
  PRIMARY KEY (`AFFILIATION_ID`),
  
  CONSTRAINT fk_pa_pid
  FOREIGN KEY (`PARTNER_ID`) 
    REFERENCES PARTNER_GROUPS(PARTNER_ID),
  CONSTRAINT fk_pa_cid
  FOREIGN KEY (`CONTACT_ID`) 
    REFERENCES CONTACTS(CONTACT_ID)  
) COMMENT='This table links eMOLT participants to industry associations, fishing companies, research institutions, etc.';