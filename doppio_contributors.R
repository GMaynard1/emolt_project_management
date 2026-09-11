rutgers_erddap_url <- "https://tds.marine.rutgers.edu/erddap/"

# 2. Define the dataset ID extracted from your link
dataset_id <- "DOPPIO_REALTIME_MOD"

# 3. Use tabledap() to fetch the 2025 data
# We apply constraints for time >= Jan 1, 2025 and time <= Dec 31, 2025.
# Note: You can optionally restrict the output columns using the 'fields' parameter.
doppio_2025_data <- rerddap::tabledap(
  x = dataset_id,
  url = rutgers_erddap_url,
  'time>=2025-01-01T00:00:00Z',
  'time<=2025-12-31T23:59:59Z',
  'obs_type=6'
)
x=subset(doppio_2025_data,doppio_2025_data$obs_type==6)
x=subset(x,x$depth<=-1)
nrow(subset(x,x$obs_provenance==734))/nrow(x)

y=subset(doppio_2025_data,doppio_2025_data$obs_provenance%in%(seq(741,750,1)))
z=subset(doppio_2025_data,doppio_2025_data$obs_provenance%in%(seq(1741,1750,1)))
(nrow(y)+nrow(z))/nrow(doppio_2025_data)

