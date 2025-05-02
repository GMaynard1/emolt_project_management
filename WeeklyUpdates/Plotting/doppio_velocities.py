import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import netCDF4
import urllib.request
import datetime


def shrink(a, b):
    """Return array shrunk to fit a specified shape by triming or averaging.

    a = shrink(array, shape)

    array is an numpy ndarray, and shape is a tuple (e.g., from
    array.shape). a is the input array shrunk such that its maximum
    dimensions are given by shape. If shape has more dimensions than
    array, the last dimensions of shape are fit.

    as, bs = shrink(a, b)

    If the second argument is also an array, both a and b are shrunk to
    the dimensions of each other. The input arrays must have the same
    number of dimensions, and the resulting arrays will have the same
    shape.
    Example
    -------

    >>> shrink(rand(10, 10), (5, 9, 18)).shape
    (9, 10)
    >>> map(shape, shrink(rand(10, 10, 10), rand(5, 9, 18)))
    [(5, 9, 10), (5, 9, 10)]

    """

    if isinstance(b, np.ndarray):
        a = shrink(a, b.shape)
        b = shrink(b, a.shape)
        return (a, b)

    if isinstance(b, int):
        b = (b,)

    if len(a.shape) == 1:  # 1D array is a special case
        dim = b[-1]
        while a.shape[0] > dim:  # only shrink a
            if (dim - a.shape[0]) >= 2:  # trim off edges evenly
                a = a[1:-1]
            else:  # or average adjacent cells
                a = 0.5 * (a[1:] + a[:-1])
    else:
        for dim_idx in range(-(len(a.shape)), 0):
            dim = b[dim_idx]
            a = a.swapaxes(0, dim_idx)  # put working dim first
            while a.shape[0] > dim:  # only shrink a
                if (a.shape[0] - dim) >= 2:  # trim off edges evenly
                    a = a[1:-1, :]
                if (a.shape[0] - dim) == 1:  # or average adjacent cells
                    a = 0.5 * (a[1:, :] + a[:-1, :])
            a = a.swapaxes(0, dim_idx)  # swap working dim back

    return a


def rot2d(x, y, ang):
    '''rotate vectors by geometric angle'''
    xr = x * np.cos(ang) - y * np.sin(ang)
    yr = x * np.sin(ang) + y * np.cos(ang)
    return xr, yr


years=range(2008,2022)
for y in list(years):
    for d in list(range(1,365)):
        day = datetime.datetime.strptime((str(y) +" "+ str(d)), '%Y %j')
        day_iso = day.strftime('%Y-%m-%dT%H:%M:%SZ')
        date = day.strftime('%Y-%m-%d')
        url = ("https://tds.marine.rutgers.edu/thredds/ncss/roms/doppio/DopAnV3R3-ini2007_da/avg?var=angle&var=mask_rho&var=u&var=v&horizStride=1&time_start=2007-01-02T12%3A00%3A00Z&time_end=2023-12-30T12%3A00%3A00Z&timeStride=1&time="+date+"T12%3A00%3A00Z&vertStride=1&accept=netcdf")
        #url = 'http://geoport.whoi.edu/thredds/dodsC/coawst_2_2/fmrc/coawst_2_2_best.ncd'
        #url = 'http://geoport.whoi.edu/thredds/dodsC/coawst_4/use/fmrc/coawst_4_use_best.ncd'
        #url = 'http://testbedapps-dev.sura.org/thredds/dodsC/alldata/Shelf_Hypoxia/tamu/roms/tamu_roms.nc'
        #url = 'http://tds.ve.ismar.cnr.it:8080/thredds/dodsC/ismar/model/field2/run1/Field_2km_1108_out30min_his_0724.nc'
        #url='http://tds.ve.ismar.cnr.it:8080/thredds/dodsC/field2_test/run1/his'
        #####################################################################################
        #nc = netCDF4.Dataset(url)
        urllib.request.urlretrieve(url, "/home/george/Desktop/doppio_velocities.nc")
        #urllib.request.urlretrieve("https://tds.marine.rutgers.edu/thredds/ncss/roms/doppio/DopAnV2R3-ini2007_da/mon_avg?var=angle&var=h&var=mask_rho&var=mask_u&var=mask_v&var=ubar&var=vbar&var=u&var=v&north=46.6113&west=-80.5186&east=-59.6902&south=32.2394&disableLLSubset=on&disableProjSubset=on&horizStride=1&time_start=2007-01-17T00%3A00%3A00Z&time_end=2021-08-16T00%3A00%3A00Z&timeStride=1&time=2021-08-16T00%3A00%3A00Z&vertCoord=&accept=netcdf", "/home/george/Desktop/doppio_velocities.nc")
        nc = netCDF4.Dataset("/home/george/Desktop/doppio_velocities.nc")

        mask = nc.variables['mask_rho'][:]
        lon_rho = nc.variables['lon_rho'][:]
        lat_rho = nc.variables['lat_rho'][:]
        anglev = nc.variables['angle'][:]

        tvar = nc.variables['ocean_time']      # usual ROMS

        #start = datetime.datetime.utcnow()
        tidx = netCDF4.date2index(day,tvar,select='nearest') # get nearest index to now
        tidx = -1
        timestr = netCDF4.num2date(tvar[tidx], tvar.units).strftime('%b %d, %Y %H:%M')

        zlev = 0
        u = nc.variables['u'][tidx, zlev, :, :]
        v = nc.variables['v'][tidx, zlev, :, :]

        u = shrink(u, mask[1:-1, 1:-1].shape)
        v = shrink(v, mask[1:-1, 1:-1].shape)

        u, v = rot2d(u, v, anglev[1:-1, 1:-1])

        lon=lon_rho[1:-1,1:-1]
        lat=lat_rho[1:-1,1:-1]
        plt.figure(figsize=(12, 8))
        basemap = Basemap(projection='merc',llcrnrlat=40,urcrnrlat=42,llcrnrlon=-72,urcrnrlon=-68,resolution='i')

        basemap.drawcoastlines()
        basemap.fillcontinents()
        basemap.drawcountries()
        basemap.drawstates()

        x_rho, y_rho = basemap(lon,lat)

        spd=np.sqrt(u**2+v**2)

        def masknan(prop):
            return np.ma.masked_where(np.isnan(prop), prop)

        #h1 = basemap.pcolormesh(x_rho, y_rho, spd, vmin=0, vmax=1.0)
        nsub=1
        scale=0.3
        basemap.quiver(x_rho[::nsub,::nsub],y_rho[::nsub,::nsub],u[::nsub,::nsub],v[::nsub,::nsub],scale=1.0/scale, zorder=1e35, width=0.002)
        #basemap.colorbar(h1,location='right',pad='5%')
        filename = ('/home/george/Desktop/Doppio_avg/'+date+'.png')
        plt.suptitle(date)
        plt.savefig(filename)
        plt.close()
#title('Surface Current in the Gulf of Maine: ' + timestr)