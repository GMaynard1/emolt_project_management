CREATE OR REPLACE VIEW VESSEL_SIM AS
  SELECT
    HARDWARE_ADDRESSES.HARDWARE_ID,
    HARDWARE_ADDRESSES.HARDWARE_ADDRESS,
    HARDWARE_ADDRESSES.ADDRESS_TYPE,
    EQUIPMENT_INVENTORY.EQUIPMENT_TYPE,
    EQUIPMENT_INVENTORY.MAKE,
    EQUIPMENT_INVENTORY.MODEL, 
    LATEST_EQUIPMENT_CHANGE, 
    VESSELS.VESSEL_NAME,
    GEAR_CODES.ACCSP_GEAR_NAME,
    GEAR_CODES.FMCODE
  FROM 
    HARDWARE_ADDRESSES
    INNER JOIN EQUIPMENT_CHANGE
      ON HARDWARE_ADDRESSES.INVENTORY_ID = EQUIPMENT_CHANGE.END_INVENTORY_ID
    INNER JOIN EQUIPMENT_INVENTORY
      ON EQUIPMENT_CHANGE.END_INVENTORY_ID = EQUIPMENT_INVENTORY.INVENTORY_ID
    INNER JOIN (
      SELECT 
        VESSEL_ID,
        VISIT_ID,
        max(VISIT_DATE) 
        AS LATEST_EQUIPMENT_CHANGE
        FROM
          VESSEL_VISIT_LOG GROUP BY VESSEL_ID, VISIT_ID
        ) LV
      ON EQUIPMENT_CHANGE.VISIT_ID = LV.VISIT_ID
    INNER JOIN VESSELS
      ON LV.VESSEL_ID = VESSELS.VESSEL_ID
    INNER JOIN GEAR_CODES
      ON VESSELS.PRIMARY_GEAR = GEAR_CODES.GEAR_CODE
  WHERE 
    ADDRESS_TYPE LIKE '%SIM%'
;
  