/*
* Title: view_visit_change.sql
* Author: George Maynard
* Contact: george.maynard@noaa.gov
* Purpose: To create a view called `visit_changes` that contains a VESSEL_ID,
*   VISIT_DATE, and END_INVENTORY_ID for each equipment change that has been
*   recorded in the database
*/
CREATE OR REPLACE VIEW zz_visit_changes AS
SELECT 
  VESSEL_VISIT_LOG.VESSEL_ID, 
  VESSEL_VISIT_LOG.VISIT_DATE,
  EQUIPMENT_CHANGE.END_INVENTORY_ID,
  HARDWARE_ADDRESSES.ADDRESS_TYPE,
  HARDWARE_ADDRESSES.HARDWARE_ADDRESS
FROM 
  VESSEL_VISIT_LOG
  INNER JOIN
    EQUIPMENT_CHANGE
      INNER JOIN
        HARDWARE_ADDRESSES
      ON EQUIPMENT_CHANGE.END_INVENTORY_ID = HARDWARE_ADDRESSES.INVENTORY_ID
  ON VESSEL_VISIT_LOG.VISIT_ID = EQUIPMENT_CHANGE.VISIT_ID