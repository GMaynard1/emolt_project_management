CREATE OR REPLACE VIEW VESSEL_MAC AS
  SELECT 
    vessels.VESSEL_NAME,
    vessels.VISIT_DATE,
    HARDWARE_ADDRESSES.HARDWARE_ADDRESS
  FROM
    HARDWARE_ADDRESSES
  INNER JOIN (
    SELECT 
      VESSELS.VESSEL_NAME,
      core.VISIT_DATE,
      core.END_INVENTORY_ID
    FROM (
      SELECT
        all_changes.VESSEL_ID,
        all_changes.END_INVENTORY_ID,
        all_changes.VISIT_DATE
      FROM (
        SELECT 
          END_INVENTORY_ID,
          VESSEL_ID,
          VISIT_DATE 
        FROM 
          EQUIPMENT_CHANGE
        INNER JOIN
          VESSEL_VISIT_LOG
        ON EQUIPMENT_CHANGE.VISIT_ID = VESSEL_VISIT_LOG.VISIT_ID
        WHERE EQUIPMENT_CHANGE.END_INVENTORY_ID IS NOT NULL
      ) all_changes
    INNER JOIN (
      SELECT 
        visits.END_INVENTORY_ID,
        max(visits.VISIT_DATE) AS max_date 
      FROM (
        SELECT 
          VESSEL_VISIT_LOG.VESSEL_ID, 
          VESSEL_VISIT_LOG.VISIT_DATE, 
          equipment_change.END_INVENTORY_ID 
        FROM 
          VESSEL_VISIT_LOG
        INNER JOIN (
          SELECT 
            EQUIPMENT_CHANGE.END_INVENTORY_ID, 
            EQUIPMENT_CHANGE.VISIT_ID 
          FROM 
            EQUIPMENT_CHANGE
        ) equipment_change
        ON VESSEL_VISIT_LOG.VISIT_ID = equipment_change.VISIT_ID
      ) visits
      WHERE visits.END_INVENTORY_ID IS NOT NULL 
      GROUP BY visits.END_INVENTORY_ID
    ) current
    ON all_changes.END_INVENTORY_ID = current.END_INVENTORY_ID AND all_changes.VISIT_DATE = current.max_date
  ) core
  INNER JOIN
    VESSELS
    WHERE core.VESSEL_ID = VESSELS.VESSEL_ID
  ) vessels
  WHERE HARDWARE_ADDRESSES.INVENTORY_ID = vessels.END_INVENTORY_ID 
  AND HARDWARE_ADDRESSES.ADDRESS_TYPE LIKE '%MAC%'
;
