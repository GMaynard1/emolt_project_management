from pylab import *
import numpy as np
import matplotlib.tri as Tri
import matplotlib.pyplot as plt
import netCDF4
import datetime as dt
import pytz
import pandas as pd
from io import StringIO
# Set the URL
## MASSBAY
url = 'http://www.smast.umassd.edu:8080/thredds/dodsC/FVCOM/NECOFS/Forecasts/NECOFS_FVCOM_OCEAN_MASSBAY_FORECAST.nc'
# Load it via OPeNDAP
nc = netCDF4.Dataset(url)
# Query the variables
nc.variables.keys()
## Create a vector of hours to loop over
difftime = list(range(0, 192, 1))
for x in difftime:
    ## Set the start time
    start = dt.datetime.utcnow() + dt.timedelta(hours=x)
    ## Get the desired timestep
    time_var = nc.variables['time']
    itime = netCDF4.date2index(start,time_var,select='nearest')
    dtime = netCDF4.num2date(time_var[itime],time_var.units)
    daystri = dtime.strftime('%Y-%m-%d %H:%M')
    daystr = dt.datetime.strptime(daystri, '%Y-%m-%d %H:%M')
    utc_stamp = daystr.replace(tzinfo=pytz.UTC)
    daystr2 = utc_stamp.astimezone(pytz.timezone('America/New_York'))
    daystri2 = daystr2.strftime('%Y-%m-%d %H:%M')
    ## Get the lat/lon coordinates and depths
    ## For nodes
    lat = nc.variables['lat'][:]
    lon = nc.variables['lon'][:]
    ## For cell centers
    latc = nc.variables['latc'][:]
    lonc = nc.variables['lonc'][:]
    ## Get Connectivity Array
    nv = nc.variables['nv'][:].T - 1
    ## Get Depths
    h = nc.variables['h'][:]
    ## Build triangular grid
    tri = Tri.Triangulation(lon, lat, triangles=nv)
    ## Get bottom temperatures
    ilayer = -1 ## [ 0=surface, -1=bottom]
    temp = nc.variables['temp'][itime, ilayer, :]
    temp2 = temp*1.8+32
    ## Set a region to plot
    ax = [-71.5, -69.25, 40.75, 43.25]
    ## Find temperatures in the bounding box
    ind = np.argwhere((lon >= ax[0]) & (lon <= ax[1]) & (lat >= ax[2]) & (lat <= ax[3]))
    ## Define color ramp
    levels = np.arange(0,30,1)
    levels2 = levels*1.8+32
    ## Plot the figure
    # fig = plt.figure(figsize=(10,7))
    # ax1 = fig.add_subplot(111,aspect=(1/np.cos(np.mean(lat)*np.pi/180)))
    # plt.tricontour(tri, temp, levels=levels, cmap=plt.cm.coolwarm)
    # ax1.patch.set_facecolor('0.5')
    # cbar=plt.colorbar()
    # cbar.set_label('Water Temp (C)',rotation=-90)
    # plt.show()
    fig1, ax1 = plt.subplots()
    ax1.set_aspect('equal')
    ax1.patch.set_facecolor('0.75')
    #tcf = ax1.tricontourf(tri,temp, cmap='jet', levels=levels)
    tcf = ax1.tricontourf(tri, temp2, cmap='plasma', levels=levels2)
    cbar=fig1.colorbar(tcf)
    ax1.tricontour(tri, temp2, colors='k',linewidths=0)
    #cbar.set_label('Bottom Temp (C)',rotation=-90)
    cbar.set_label('Bottom Temp (F)', rotation=-90)
    plt.xlim(ax[0],ax[1])
    plt.ylim(ax[2],ax[3])
    #filename = 'plots/_GOM3_'+daystri+'.png'
    #plt.suptitle(daystri)
    filename = '/home/george/Documents/Plotting/MABAY/forecast/plots/'+daystri2+'.png'
    plt.suptitle(daystri2)
    plt.savefig(filename)
    plt.close()
