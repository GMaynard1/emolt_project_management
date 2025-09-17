import netCDF4
import datetime
import pytz
import matplotlib.tri as Tri
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.neighbors import BallTree

## Specify the url for the download
url = 'http://www.smast.umassd.edu:8080/thredds/dodsC/models/fvcom/NECOFS/Forecasts/NECOFS_GOM7_FORECAST.nc?lon[0:1:207080],lat[0:1:207080],lonc[0:1:371289],latc[0:1:371289],siglev[0:1:45][0:1:207080],nv[0:1:2][0:1:371289],time[0:1:192],temp[0:1:192][44][0:1:207080]'
## Load the data via OPeNDAP
nc = netCDF4.Dataset(url)
## Download the eMOLT data
today = datetime.date.today()
weekday = today.weekday()
end_date = today + datetime.timedelta(days=(6-weekday))
start_date = today - datetime.timedelta(days=weekday)
url = "https://erddap.emolt.net/erddap/tabledap/eMOLT_RT.csvp?tow_id%2Csegment_type%2Ctime%2Clatitude%2Clongitude%2Cdepth%2Ctemperature%2Csensor_type%2Cmodel%2Cdata_provider&segment_type=3&time%3E=" + start_date.strftime('%Y-%m-%d') + "T00%3A00%3A00Z&time%3C=" + end_date.strftime('%Y-%m-%d') +"T16%3A16%3A40Z"
emolt = pd.read_csv(url)
## Grab unique tow ids
tows = np.unique(emolt['tow_id'])
## Save a daily average temperature and location for each tow
emolt_avg = []
for tow in tows:
  condition = emolt['tow_id'] == tow
  subset = emolt[condition]
  subset['date'] = pd.to_datetime(subset['time (UTC)'])
  subset['date'] = subset['date'].dt.date
  dates = np.unique(subset['date'])
  for date in dates:
    d_condition = subset['date'] == date
    d_subset = subset[d_condition]
    avg_dict = {
      'tow': tow,
      'date': date,
      'avg_temp': np.mean(d_subset['temperature (degree_C)']),
      'latitude': np.mean(d_subset['latitude (degrees_north)']),
      'longitude': np.mean(d_subset['longitude (degrees_east)'])
    }
    emolt_avg.append(avg_dict)

emolt_avg = pd.DataFrame(emolt_avg)
emolt_avg['NECOFS_spatial_index'] = None
emolt_avg['NECOFS_temporal_index'] = None
time_var = nc.variables['time']
time_units = time_var.units
dates = netCDF4.num2date(time_var[:],units=time_units)
emolt_avg['date'] = pd.to_datetime(emolt_avg['date'])
emolt_avg['forecast_temp'] = None

for row in emolt_avg.iterrows():
  rlat=row[1]['latitude']
  rlon=row[1]['longitude']
  ref_point = np.array([rlat,rlon])
  coords=np.vstack((nc['lat'],nc['lon'])).T
  tree=BallTree(np.radians(coords),metric='haversine')
  distances,indices = tree.query(np.radians(ref_point.reshape(1,-1)),k=1)
  closest_index=indices[0][0]
  emolt_avg.loc[[row[0]],'NECOFS_spatial_index'] = closest_index
  x=abs(emolt_avg['date'][row[0]]-dates)
  emolt_avg.loc[[row[0]],'NECOFS_temporal_index'] = x.argmin()
  ftime = emolt_avg['NECOFS_temporal_index'][row[0]]
  floc = emolt_avg['NECOFS_spatial_index'][row[0]]
  emolt_avg['forecast_temp'][row[0]] = nc.variables['temp'][ftime, -1, floc]
  
emolt_avg['diff_temp']=emolt_avg['avg_temp']-emolt_avg['forecast_temp']



###### LEFT OFF HERE ##### 
# for 
# difftime = list(range(0,10,1))
# for x in difftime:
#   time_var = nc.variables['time']
#   start = datetime.datetime.now(datetime.UTC) + datetime.timedelta(hours=x)
#   itime = netCDF4.date2index(start,time_var,select='nearest')
#   dtime = netCDF4.num2date(time_var[itime],time_var.units)
#   daystri = dtime.strftime('%Y-%m-%d %H:%M')
#   daystr = dt.datetime.strptime(daystri, '%Y-%m-%d %H:%M')
#   utc_stamp = daystr.replace(tzinfo=pytz.UTC)
#   daystr2 = utc_stamp.astimezone(pytz.timezone('America/New_York'))
#   daystri2 = daystr2.strftime('%Y-%m-%d %H:%M')
#   lat = nc.variables['lat'][:]
#   lon = nc.variables['lon'][:]
#   latc = nc.variables['latc'][:]
#   lonc = nc.variables['lonc'][:]
#   nv = nc.variables['nv'][:].T - 1
#   siglev = nc.variables['siglev'][:]
#   tri = Tri.Triangulation(lon, lat, triangles=nv)
#   ilayer = -1  ## [ 0=surface, -1=bottom]
#   temp = nc.variables['temp'][itime, ilayer, :]
#   temp2 = temp*1.8+32
#   ax=[-76, -66, 35, 45]
#   # by = ma.getdata(blat)
#   # bx = ma.getdata(blon)
#   # bz = ma.getdata(depth)
#   # bz = bz*0.54680665
#   ind = np.argwhere((lon >= ax[0]) & (lon <= ax[1]) & (lat >= ax[2]) & (lat <= ax[3]))
#   levels = np.arange(0,30,1)
#   fig1, ax1 = plt.subplots()
#   ax1.set_aspect('equal')
#   ax1.patch.set_facecolor('0.75')
#   tcf = ax1.tricontourf(tri, temp, cmap='plasma', levels=levels)
#   cbar=fig1.colorbar(tcf)
#   ax1.tricontour(tri, temp, colors='k',linewidths=0)
#   cbar.set_label('Bottom Temp (C)', rotation=-90)
#   plt.xlim(ax[0],ax[1])
#   plt.ylim(ax[2],ax[3])
#   filename='test_'+str(x)+'.png'
#   plt.suptitle(daystri2)
#   plt.savefig(filename)
#   plt.close(filename)
