/*
* Title: VESSEL_MAC.sql
* Author: George Maynard
* Contact: george.maynard@noaa.gov
* Purpose: Displays the MAC address(es) of the devices assigned to each vessel
*/
CREATE OR REPLACE VIEW VESSEL_MAC AS
SELECT
  vessel_visits.VESSEL_NAME,
  vessel_visits.EMOLT_NUM,
  vessel_visits.VISIT_DATE,
  installed_gear_and_addresses.EQUIPMENT_TYPE,
  installed_gear_and_addresses.MAKE,
  installed_gear_and_addresses.MODEL,
  installed_gear_and_addresses.HARDWARE_ADDRESS
FROM
  vessel_visits
  INNER JOIN
  installed_gear_and_addresses
  ON vessel_visits.VISIT_DATE = installed_gear_and_addresses.max_date AND vessel_visits.END_INVENTORY_ID = installed_gear_and_addresses.END_INVENTORY_ID
WHERE installed_gear_and_addresses.ADDRESS_TYPE LIKE '%MAC%'