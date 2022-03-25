CREATE USER 'jim'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON emolt_dev.* TO 'jim'@'localhost';

CREATE USER 'lowell'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON emolt_dev.VESSELS TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.VESSEL_VISIT_LOG TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.EQUIPMENT_CHANGE TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.EQUIPMENT_INVENTORY TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.HARDWARE_ADDRESSES TO 'lowell'@'localhost';
GRANT SELECT, INSERT ON emolt_dev.TELEMETRY_STATUS TO 'lowell'@'localhost'; 

CREATE USER 'vessel_status'@'*' IDENTIFIED BY 'password';
GRANT SELECT, INSERT ON emolt_dev.TELEMETRY_STATUS TO 'vessel_status'@'*';
GRANT SELECT ON emolt_dev.HARDWARE_ADDRESSES TO 'vessel_status'@'*';
GRANT SELECT ON emolt_dev.EQUIPMENT_INVENTORY TO 'vessel_status'@'*';