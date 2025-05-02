from pylab import *
import matplotlib.tri as Tri
import netCDF4
import datetime as dt
# DAP Data URL
# GOM7 Grid
url = 'http://www.smast.umassd.edu:8080/thredds/dodsC/FVCOM/NECOFS/Forecasts/NECOFS_GOM7_FORECAST.nc'
# Open DAP
nc = netCDF4.Dataset(url).variables
start = dt.datetime.utcnow() + dt.timedelta(hours=18)
# Get desired time step
time_var = nc['time']
itime = netCDF4.date2index(start,time_var,select='nearest')

# Get lon,lat coordinates for nodes (depth)
lat = nc['lat'][:]
lon = nc['lon'][:]
# Get lon,lat coordinates for cell centers (depth)
latc = nc['latc'][:]
lonc = nc['lonc'][:]
# Get Connectivity array
nv = nc['nv'][:].T - 1
# Get depth
h = nc['h'][:]  # depth
dtime = netCDF4.num2date(time_var[itime],time_var.units)
daystr = dtime.strftime('%Y-%b-%d %H:%M')
tri = Tri.Triangulation(lon,lat, triangles=nv)
# get current at layer [0 = surface, -1 = bottom]
ilayer = -1
u = nc['u'][itime, ilayer, :]
v = nc['v'][itime, ilayer, :]
#area of interest
levels=arange(-100,2,1)
ax = [-70.5, -69.5, 40.5, 41.5]
maxvel = 1
subsample = 3
# find velocity points in bounding box
ind = argwhere((lonc >= ax[0]) & (lonc <= ax[1]) & (latc >= ax[2]) & (latc <= ax[3]))
np.random.shuffle(ind)
Nvec = int(len(ind) / subsample)
idv = ind[:Nvec]
# tricontourf plot of water depth with vectors on top
figure(figsize=(18,10))
subplot(111,aspect=(1.0/cos(mean(lat)*pi/180.0)))
tricontourf(tri, -h, levels=levels, cmap='jet')
axis(ax)
gca().patch.set_facecolor('0.5')
cbar=colorbar()
cbar.set_label('Water Depth (m)', rotation=-90)
Q = quiver(lonc[idv],latc[idv],u[idv],v[idv],scale=20)
maxstr='%3.1f m/s' % maxvel
qk = quiverkey(Q,0.92,0.08,maxvel,maxstr,labelpos='W')
title('NECOFS Velocity, Layer %d, %s UTC' % (ilayer, daystr))
filename = '/home/george/Desktop/NECOFS_bottom_+18.png'
plt.savefig(filename)




