CREATE TABLE `GEAR_CODES`(
  `GEAR_CODE` varchar(6) NOT NULL COMMENT 'Concatenation of ACCSP and VTR gear codes used to map gears between the two data sets',
  `ACCSP_GEAR_CODE` varchar(3) NOT NULL COMMENT 'ACCSP gear code',
  `VTR_GEAR_CODE` varchar(3) COMMENT 'VTR gear code',
  `VTR_GEAR_NAME` varchar(80) COMMENT 'VTR gear code description',
  `ACCSP_GEAR_NAME` varchar(40) NOT NULL COMMENT 'ACCSP gear code description',
  `NEGEAR` varchar(3) COMMENT 'Gear coding equivalent for CFDBS an OBDBS',
  `FMCODE` varchar(1) NOT NULL 'Gear category type indicator; F=fixed, M=mobile, O=other',
  
  PRIMARY KEY (`GEAR_CODE`),
) COMMENT='This table is columns 1-4, 6, 27, and 30 from FVTR.FVTR_GEAR_CODES@sole. It contains both human readable and standard codes for all gear types categorized by ACCSP and NEFSC.'; 