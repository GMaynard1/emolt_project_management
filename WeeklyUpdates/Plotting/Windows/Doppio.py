import netCDF4
import datetime
import pytz
import matplotlib.tri as Tri
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.neighbors import BallTree
import csv
import os
from tqdm import tqdm
import time

start_line = time.time()
pd.set_option('display.max_columns',None)
## Specify the url for the download
url = 'https://tds.marine.rutgers.edu/thredds/dodsC/roms/doppio/2017_da/his/History_Best?lon_rho[0:1:105][0:1:241],lat_rho[0:1:105][0:1:241],time[0:1:69131],temp[0:1:69131][0][0:1:105][0:1:241]'
## Load the data via OPeNDAP
nc = netCDF4.Dataset(url)
## Download the eMOLT data
today = datetime.date.today()
weekday = today.weekday()
end_date = today + datetime.timedelta(days=(6-weekday))
start_date = today - datetime.timedelta(days=weekday)
url = "https://erddap.emolt.net/erddap/tabledap/eMOLT_RT_QAQC.csvp?tow_id%2Csegment_type%2Ctime%2Clatitude%2Clongitude%2Cdepth%2Ctemperature%2Csensor_type%2Cmodel%2Cdata_provider&segment_type=3&time%3E=" + start_date.strftime('%Y-%m-%d') + "T00%3A00%3A00Z&time%3C=" + end_date.strftime('%Y-%m-%d') +"T16%3A16%3A40Z"
emolt = pd.read_csv(url)
emolt = emolt.dropna()
## Grab unique tow ids
tows = np.unique(emolt['tow_id'])
## Save a daily average temperature and location for each tow
emolt_avg = []
for tow in tqdm(tows, desc="Segregating tows by date and location"):
  condition = emolt['tow_id'] == tow
  subset = emolt[condition].copy()
  subset.loc[:, 'date'] = pd.to_datetime(subset['time (UTC)'])
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
emolt_avg['Doppio_spatial_index'] = None
emolt_avg['Doppio_temporal_index'] = None
time_var = nc.variables['time']
time_units = time_var.units
dates = netCDF4.num2date(time_var[:],units=time_units)
emolt_avg['date'] = pd.to_datetime(emolt_avg['date'])
emolt_avg['forecast_temp'] = None
lat=nc['lat_rho'][:]
lon=nc['lon_rho'][:]
lat=lat.compressed()
lon=lon.compressed()

coords=np.vstack((lat,lon)).T
tree=BallTree(np.radians(coords),metric='haversine')

for row in tqdm(emolt_avg.iterrows(), desc="Finding closest model nodes"):
  rlat=row[1]['latitude']
  rlon=row[1]['longitude']
  ref_point = np.array([rlat,rlon])
  distances,indices = tree.query(np.radians(ref_point.reshape(1,-1)),k=1)
  closest_index=indices[0][0]
  emolt_avg.loc[[row[0]],'Doppio_spatial_index'] = closest_index
  x=abs(emolt_avg['date'][row[0]]-dates)
  emolt_avg.loc[[row[0]],'Doppio_temporal_index'] = x.argmin()
  ftime = emolt_avg['Doppio_temporal_index'][row[0]]
  ftime = ftime.astype(int)
  floc = emolt_avg['Doppio_spatial_index'][row[0]]
  floc = floc.astype(int)
  flat = coords[[floc]][0,0]
  flat = np.ma.where(nc['lat_rho'][:]==flat)[0][0]
  flon = coords[[floc]][0,1]
  flon = np.ma.where(nc['lon_rho'][:]==flon)[1][0]
  ftemperature=nc.variables['temp'][ftime,0,flat,flon]
  emolt_avg.loc[row[0],'forecast_temp'] = ftemperature
  
emolt_avg['diff_temp']=emolt_avg['avg_temp']-emolt_avg['forecast_temp']

now=datetime.datetime.now()
output_directory = ('C:/Users/george.maynard/Documents/emolt_project_management/WeeklyUpdates/'+now.strftime('%Y')+'/'+now.strftime('%Y-%m-%d')+'/')
filename= os.path.join(output_directory,('Doppio_comparison_'+now.strftime("%Y%m%d")+'.csv'))

emolt_avg.to_csv(filename,index=False)

finish_line = time.time()
execution_time = finish_line - start_line
print(f"Doppio comparison took: {execution_time} seconds")


