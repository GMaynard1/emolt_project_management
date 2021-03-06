CREATE USER 'jim'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON emolt_dev.* TO 'jim'@'localhost';

CREATE USER 'lowell'@'%' IDENTIFIED BY 'password';
CREATE USER 'lowell'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON emolt_dev.VESSEL_SIM TO 'lowell'@'%';
GRANT SELECT ON emolt_dev.VESSEL_MAC TO 'lowell'@'%';
GRANT SELECT, INSERT ON emolt_dev.TELEMETRY_STATUS TO 'lowell'@'%'; 
GRANT SELECT ON emolt_dev.VESSEL_SIM TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.VESSEL_MAC TO 'lowell'@'localhost';
GRANT SELECT, INSERT ON emolt_dev.TELEMETRY_STATUS TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.EQUIPMENT_CHANGE TO 'lowell'@'%';
GRANT SELECT ON emolt_dev.EQUIPMENT_INVENTORY TO 'lowell'@'%';
GRANT SELECT ON emolt_dev.HARDWARE_ADDRESSES TO 'lowell'@'%';
GRANT SELECT ON emolt_dev.VESSELS TO 'lowell'@'%';
GRANT SELECT ON emolt_dev.VESSEL_VISIT_LOG TO 'lowell'@'%';
GRANT SELECT ON emolt_dev.EQUIPMENT_CHANGE TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.EQUIPMENT_INVENTORY TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.HARDWARE_ADDRESSES TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.VESSELS TO 'lowell'@'localhost';
GRANT SELECT ON emolt_dev.VESSEL_VISIT_LOG TO 'lowell'@'localhost';

CREATE USER 'vessel_status'@'*' IDENTIFIED BY 'password';
GRANT SELECT, INSERT ON emolt_dev.TELEMETRY_STATUS TO 'vessel_status'@'*';
GRANT SELECT ON emolt_dev.HARDWARE_ADDRESSES TO 'vessel_status'@'*';
GRANT SELECT ON emolt_dev.EQUIPMENT_INVENTORY TO 'vessel_status'@'*';
CREATE USER 'vessel_status'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT, INSERT ON emolt_dev.TELEMETRY_STATUS TO 'vessel_status'@'localhost';
GRANT SELECT ON emolt_dev.HARDWARE_ADDRESSES TO 'vessel_status'@'localhost';
GRANT SELECT ON emolt_dev.EQUIPMENT_INVENTORY TO 'vessel_status'@'localhost';
CREATE USER 'vessel_status'@'%' IDENTIFIED BY 'password';
GRANT SELECT, INSERT ON emolt_dev.TELEMETRY_STATUS TO 'vessel_status'@'%';
GRANT SELECT ON emolt_dev.HARDWARE_ADDRESSES TO 'vessel_status'@'%';
GRANT SELECT ON emolt_dev.EQUIPMENT_INVENTORY TO 'vessel_status'@'%';

CREATE USER 'carles'@'%' IDENTIFIED BY 'password';
CREATE USER 'carles'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON emolt_dev.VESSEL_MAC TO 'carles'@'%';
GRANT SELECT ON emolt_dev.VESSEL_SIM TO 'carles'@'%';
GRANT SELECT ON emolt_dev.VESSEL_MAC TO 'carles'@'localhost';
GRANT SELECT ON emolt_dev.VESSEL_SIM TO 'carles'@'localhost';

CREATE USER 'huanxin'@'%' IDENTIFIED BY 'password';
CREATE USER 'huanxin'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON emolt_test.* TO 'huanxin'@'%';
GRANT SELECT ON emolt_test.* TO 'huanxin'@'localhost';
GRANT SELECT ON emolt_dev.* TO 'huanxin'@'%';
GRANT SELECT ON emolt_dev.* TO 'huanxin'@'localhost';
