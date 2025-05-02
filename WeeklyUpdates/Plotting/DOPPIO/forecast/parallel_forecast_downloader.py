import requests
import time
from multiprocessing import cpu_count
from multiprocessing.pool import ThreadPool
import pandas as pd
import datetime

start_date = datetime.datetime.utcnow()
end_date = start_date + datetime.timedelta(days=7)
date_list = pd.date_range(start_date,end_date,freq='D')

urls = []
files = []
sdaystri = start_date.strftime('%Y-%m-%dT%H:%M:%SZ')
sdaystri2 = start_date.strftime('%Y-%m-%d')
sdaystri3 = start_date.strftime('%Y%m%d')
edaystri = end_date.strftime('%Y-%m-%dT%H:%M:%SZ')
edaystri2 = end_date.strftime('%Y-%m-%d')
edaystri3 = end_date.strftime('%Y%m%d')
urls.append('https://tds.marine.rutgers.edu/thredds/ncss/roms/doppio/2017_da/his/History_Best?var=temp&disableLLSubset=on&disableProjSubset=on&horizStride=1&time_start=' + sdaystri2 + 'T%3A00%3A00%3A00Z&time_end=' + edaystri2 + 'T%3A00%3A00%3A00Z&timeStride=1&vertCoord=-0.9875&accept=netcdf')
files.append(r'/home/george/Documents/Plotting/DOPPIO/forecast/data/DOPPIO_'+sdaystri3+'.nc')

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
