Steps to run, 

0, Open MySQL Workbench, connect to eMOLT site

1, equipment_inventory.sql , make sure no limit on the number of result rows
2, equipment_maintenance_intervals.sql

3, messages_this_month.sql  , make sure no limit on the number of result rows


4, go to "GOMLF" folder or the other folders to run gomlf_vessel_query.sql to get output csv file 'vessels.csv 'and save it under /VesselCheckIns

5, go back to open status_report.Rmd, fill the "tech", change the 'timeframe' and 'filepath', then run it on Rstudio.
