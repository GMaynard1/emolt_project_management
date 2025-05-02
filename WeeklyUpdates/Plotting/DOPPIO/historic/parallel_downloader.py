import requests
import time
from multiprocessing import cpu_count
from multiprocessing.pool import ThreadPool
import pandas as pd
import datetime

start_date = datetime.datetime(2023,6,1,00,00,00,0)
end_date = datetime.datetime(2023,7,17,00,00,00,0)
date_list = pd.date_range(start_date,end_date,freq='D')

urls = []
files = []

for day in date_list:
    daystri = day.strftime('%Y-%m-%dT%H:%M:%SZ')
    daystri2 = day.strftime('%Y-%m-%d')
    daystri3 = day.strftime('%Y%m%d')
    urls.append('https://tds.marine.rutgers.edu/thredds/ncss/roms/doppio/2017_da/his/runs/History_RUN_' + daystri + '?var=temp&horizStride=1&time='+daystri2+'T12%3A00%3A00Z&vertCoord=-0.9875&addLatLon=true&accept=netcdf')
    files.append(r'/home/george/Documents/Plotting/DOPPIO/historic/data/DOPPIO_'+daystri3+'.nc')

inputs = zip(urls, files)

def download_url(args):
    t0 = time.time()
    url, fn = args[0], args[1]
    try:
        r = requests.get(url)
        with open(fn, 'wb') as f:
            f.write(r.content)
        return(url, time.time() - t0)
    except Exception as e:
        print('Exception in download_url():', e)
def download_parallel(args):
    cpus = cpu_count()
    results = ThreadPool(cpus - 1).imap_unordered(download_url, args)
    for result in results:
        print('url:', result[0], 'time (s):', result[1])

download_parallel(inputs)