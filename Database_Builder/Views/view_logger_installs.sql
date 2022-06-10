/*
* Title: view_vessel_loggers.sql
* Author: George Maynard
* Contact: george.maynard@noaa.gov
* Purpose: To create a view called `logger_installs` that shows every logger
*   assignment that's been recorded in the database with install date
*/
CREATE OR REPLACE VIEW logger_installs AS
SELECT 
  VESSEL_VISIT_LOG.VISIT_DATE AS INSTALL_DATE,
  zz_vessel_loggers.MAKE,
  zz_vessel_loggers.MODEL,
  zz_vessel_loggers.SERIAL_NUMBER,
  zz_vessel_loggers.VESSEL_NAME,
  zz_vessel_loggers.PORT,
  zz_vessel_loggers.FIRST_NAME,
  zz_vessel_loggers.LAST_NAME
FROM 
  EQUIPMENT_CHANGE
  INNER JOIN
    EQUIPMENT_INVENTORY
    ON EQUIPMENT_CHANGE.END_INVENTORY_ID = EQUIPMENT_INVENTORY.INVENTORY_ID
  INNER JOIN
    VESSEL_VISIT_LOG
    INNER JOIN
      zz_vessel_loggers
      ON VESSEL_VISIT_LOG.VESSEL_ID = zz_vessel_loggers.VESSEL_ID
    ON EQUIPMENT_CHANGE.VISIT_ID = VESSEL_VISIT_LOG.VISIT_ID
  WHERE EQUIPMENT_INVENTORY.EQUIPMENT_TYPE = 'LOGGER'
  ORDER BY 
    INSTALL_DATE DESC,
    VESSEL_NAME
;