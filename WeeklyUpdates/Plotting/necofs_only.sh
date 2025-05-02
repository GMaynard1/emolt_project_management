#!/bin/bash
## master_plotter.sh
## -----
## Clear last week's plots
#echo -n "Clear old plots..."
#rm /home/george/Documents/Plotting/DOPPIO/forecast/plots/F/*.png
#rm /home/george/Documents/Plotting/DOPPIO/forecast/plots/C/*.png
#rm /home/george/Documents/Plotting/MABAY/forecast/plots/*.png
#rm /home/george/Documents/Plotting/NECOFS/forecast/plots/*.png

## Clear last week's Doppio data
#rm /home/george/Documents/Plotting/DOPPIO/forecast/data/*.nc

## Move last week's Doppio data
#mv /home/george/Documents/Plotting/DOPPIO/forecast/data/* /home/george/Documents/Plotting/DOPPIO/forecast/old_data/

## Download this week's Doppio data
## Based on code from J. Wilkin

## Set the base URL
#doppio_url="https://tds.marine.rutgers.edu/thredds/dodsC/roms/doppio/2017_da/his/History_Best"
#necofs_url="http://www.smast.umassd.edu:8080/thredds/dodsC/FVCOM/NECOFS/Forecasts/NECOFS_GOM7_FORECAST.nc"

## Set a start date and end date (John recommends just date, not time)
time_start=$(date -u +%F)
time_end=$(date -d "+7 days" -u +%F)

## Create output filenames
#doppio_filename="/home/george/Documents/Plotting/DOPPIO/forecast/data/doppio_bottom_temps_${time_start}_${time_end}.nc"
#necofs_filename="/home/george/Documents/Plotting/NECOFS/forecast/data/necofs_bottom_temps_${time_start}_${time_end}.nc"

## Download the data
echo -ne "\nDownload Doppio data...\n"
#ncks --overwrite -d time,$time_start,$time_end -d s_rho,0 -v temp $doppio_url $doppio_filename
#echo -n "Download NECOFS data..."
#ncks --overwrite -d time,$time_start,$time_end -v siglay,-1 -v temp $necofs_url $necofs_filename

## Plot this week's Doppio data
#echo -ne "\nCreate Doppio images...\n"
#python3 /home/george/Documents/Plotting/DOPPIO/forecast/doppioplots_forecast_farenheit.py
#echo -ne "\nCreate Doppio gif...\n"
#python3 /home/george/Documents/Plotting/DOPPIO/forecast/doppio_plots_to_gif_forecasts.py

## Download and plot this week's NECOFS data
echo -ne "\nDownload data and create Mass Bay NECOFS plots...\n"
python3 /home/george/Documents/Plotting/MABAY/plot_png_ma_bay.py
echo -ne "\nDownload data and create GOM NECOFS plots...\n"
python3 /home/george/Documents/Plotting/NECOFS/plot_png_GOM.py
echo -ne "\nCreate NECOFS gifs from plots...\n"
python3 /home/george/Documents/Plotting/plots_to_gif_forecast_NECOFS+MABAY.py

## Move the gifs to the newsletter directory and move the data to the old_data folders
echo -ne "\nMoving gifs to the WeeklyUpdates directory...\n"
#mv /home/george/Documents/Plotting/DOPPIO/forecast/plots/F/DOPPIO_forecast_F.gif /home/george/Documents/emolt_project_management/WeeklyUpdates/
mv /home/george/Documents/Plotting/MABAY/forecast/plots/NECOFS_MABAY.gif /home/george/Documents/emolt_project_management/WeeklyUpdates/
mv /home/george/Documents/Plotting/NECOFS/forecast/plots/NECOFS_GOM.gif /home/george/Documents/emolt_project_management/WeeklyUpdates/
#mv $doppio_filename /home/george/Documents/Plotting/DOPPIO/forecast/old_data
mv $necofs_filename /home/george/Documents/Plotting/NECOFS/old_data
echo -ne "\nSuccessfully plotted forecasts. \n"

## Run the Doppio comparison code and plot the outcome
#echo -ne "\nRun Doppio comparison in R...\n"
#Rscript /home/george/Documents/emolt_project_management/WeeklyUpdates/forecast_check/R/compare_and_plot.R

## Move the outputs to the correct location
#echo -ne "\nMoving outputs to the WeeklUpdates directory...\n"
#mv /home/george/doppio_compare.png /home/george/Documents/emolt_project_management/WeeklyUpdates/
#mv /home/george/DoppioComparison_* /home/george/Documents/emolt_project_management/WeeklyUpdates/

## Clear the old .nc data
echo -ne "\nCleaning up...\nDone!\n"
rm /home/george/*.nc

