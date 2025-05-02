import netCDF4
import numpy as np
import matplotlib.pyplot as plt
import numpy.ma as ma
import datetime
import pytz
import os
import glob
import urllib.request

os.chdir("/home/george/Documents/Plotting/DOPPIO/forecast/data/")
datasets = sorted(glob.glob("*.nc"))
urllib.request.urlretrieve("https://tds.marine.rutgers.edu/thredds/ncss/roms/doppio/2017_da/his/runs/History_RUN_2024-02-13T00:00:00Z?var=h&north=46.6113&west=-80.5186&east=-59.6902&south=32.2394&horizStride=1&time_start=2024-02-13T00%3A00%3A00Z&time_end=2024-02-19T12%3A00%3A00Z&timeStride=1&vertCoord=&addLatLon=true&accept=netcdf", "/home/george/Documents/Plotting/DOPPIO/bathy.nc")
bath = netCDF4.Dataset("/home/george/Documents/Plotting/DOPPIO/bathy.nc")

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
		blat = bath.variables['lat_rho'][:]
		blon = bath.variables['lon_rho'][:]

		## Get the temperature values
		temp = nc.variables['temp'][id]
		
		## Get the max depth coordinate
		depth = bath.variables['h'][:]

		## Get the time and convert to a string
		start = datetime.datetime(2017,11,1,00,00,00,0)
		dtime= start + datetime.timedelta(hours = t)
		daystri = dtime.strftime('%Y-%m-%d %H:%M')
		daystr = datetime.datetime.strptime(daystri, '%Y-%m-%d %H:%M')
		utc_stamp = daystr.replace(tzinfo=pytz.UTC)
		daystr2 = utc_stamp.astimezone(pytz.timezone('America/New_York'))
		daystri2 = daystr2.strftime('%Y-%m-%d %H:%M')

		## Set the region to plot
		ax = [-75.5, -72, 38, 39]
		ind = np.argwhere((lon >= ax[0]) & (lon <= ax[1]) & (lat >= ax[2]) & (lat <= ax[3]))
		y = ma.getdata(lat)
		x = ma.getdata(lon)
		z = ma.getdata(temp)
		z = z*1.8+32
		by = ma.getdata(blat)
		bx = ma.getdata(blon)
		bz = ma.getdata(depth)
		bz = bz*0.54680665
		## Name the image output
		filename = '/home/george/Documents/Plotting/DOPPIO/forecast/plots/F/'+daystri2+'.png'
		## Define color ramp
		levels = np.arange(0,30,1)
		levels = levels*1.8+32
		fig1, ax1 = plt.subplots()
		ax1.set_aspect('equal')
		ax1.patch.set_facecolor('0.75')
		tcf = ax1.contourf(x,y,z[0], cmap='jet', levels=levels)
		cbar=fig1.colorbar(tcf)
		cbar.set_label('Bottom Temp (F)',rotation=-90)
		plt.xlim(ax[0], ax[1])
		plt.ylim(ax[2], ax[3])
		plt.suptitle(daystri2+' America/New_York')
		plt.contour(bx,by,bz,levels=(30,50,100),colors=('white','gray','black'))
		plt.savefig(filename, dpi=400)
		plt.close()
		id = id + 1

