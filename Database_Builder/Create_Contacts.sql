CREATE TABLE `CONTACTS` (
  `CONTACT_ID` integer NOT NULL AUTO_INCREMENT COMMENT 'A unique identifier used in this database only',
  `FIRST_NAME` varchar(100) NOT NULL COMMENT 'Given name of contact',
  `LAST_NAME` varchar(100) NOT NULL COMMENT 'Surname of contact',
  `PHONE` varchar(10) COMMENT 'Phone number in format xxxxxxxxxx',
  `MOBILE` varchar(10) COMMENT 'Mobile phone number in format xxxxxxxxxx',
  `EMAIL` varchar(50) COMMENT 'Email address',
  `PREFERRED_CONTACT` SET('CALL_PHONE','CALL_MOBILE','TXT_MOBILE','EMAIL') COMMENT 'Preferred method of contact',
  `STREET_1` varchar(50) COMMENT 'Street address line 1',
  `STREET_2` varchar(50) COMMENT 'Street address line 2 (if applicable)',
  `CITY` varchar(50) COMMENT 'City of addressee',
  `STATE_POSTAL` varchar(2) COMMENT 'Two character abbreviation of state or province used by postal service',
  `ZIP` varchar(5) COMMENT 'Postal code',
  `ROLE` set('ACTIVE_SUPPORT','ACTIVE_INDUSTRY','ACTIVE_ADMIN','ACTIVE_INACTIVE') NOT NULL COMMENT 'A way of categorizing contacts',
  
  PRIMARY KEY (`CONTACT_ID`)
  
) COMMENT='This table stores contact information for eMOLT participants and support staff';