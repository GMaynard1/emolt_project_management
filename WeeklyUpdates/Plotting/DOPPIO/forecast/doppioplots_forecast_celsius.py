import netCDF4
import numpy as np
import matplotlib.pyplot as plt
import numpy.ma as ma
import datetime
import pytz
import os
import glob

os.chdir("/home/george/Documents/Plotting/DOPPIO/forecast/data/")
datasets = sorted(glob.glob("*.nc"))

for d in datasets:
	# ----- LOAD THE DATA -----
	nc = netCDF4.Dataset(d)

	# ----- QUERY THE VARIABLES -----
	nc.variables.keys()

	## Get the times
	times = ma.getdata(nc.variables['time'][:])
	id = 0
	for t in times:
		## Get the lat/lon coordinates
		lat = nc.variables['lat_rho'][:]
		lon = nc.variables['lon_rho'][:]

		## Get the temperature values
		temp = nc.variables['temp'][id]

		## Get the time and convert to a string
		start = datetime.datetime(2017,11,1,00,00,00,0)
		dtime= start + datetime.timedelta(hours = t)
		daystri = dtime.strftime('%Y-%m-%d %H:%M')
		daystr = datetime.datetime.strptime(daystri, '%Y-%m-%d %H:%M')
		utc_stamp = daystr.replace(tzinfo=pytz.UTC)
		daystr2 = utc_stamp.astimezone(pytz.timezone('America/New_York'))
		daystri2 = daystr2.strftime('%Y-%m-%d %H:%M')

		## Set the region to plot
		ax = [-75, -66, 38, 45]
		ind = np.argwhere((lon >= ax[0]) & (lon <= ax[1]) & (lat >= ax[2]) & (lat <= ax[3]))
		y = ma.getdata(lat)
		x = ma.getdata(lon)
		z = ma.getdata(temp)
		## Name the image output
		filename = '/home/george/Documents/Plotting/DOPPIO/forecast/plots/C/'+daystri2+'.png'
		## Define color ramp
		levels = np.arange(0,30,1)
		fig1, ax1 = plt.subplots()
		ax1.set_aspect('equal')
		ax1.patch.set_facecolor('0.75')
		tcf = ax1.contourf(x,y,z[0], cmap='jet', levels=levels)
		cbar=fig1.colorbar(tcf)
		cbar.set_label('Bottom Temp (C)',rotation=-90)
		plt.xlim(ax[0], ax[1])
		plt.ylim(ax[2], ax[3])
		plt.suptitle(daystri2+' UTC')
		plt.savefig(filename)
		plt.close()
		id = id + 1
