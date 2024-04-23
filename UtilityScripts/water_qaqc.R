require(sp)
require(rgdal)
require(dplyr)
require(maps)

## Download, unzip, and read land as GeoJSONs from the World Bank
## https://datacatalog.worldbank.org/search/dataset/0038272

land=readOGR(dsn="C:/Users/george.maynard/Documents/GitHubRepos/emolt_project_management/UtilityScripts/WB_Boundaries_GeoJSON_highres/WB_Land.geojson")

## Example dataframe of locations to check
locations=data.frame(
  names=c("CAPE COD BAY","SPAIN","ALASKA","INDIAN OCEAN","NEW ZEALAND"),
  lat=c(41.919484262758665,40.1174809522091,65.59054428685316,-18.61636424485178,-44.19687138371396),
  lon=c(-70.31139170449191,-3.9866708268064435,-152.85665394993177,78.20791541309468,170.86172952051226)
)

## Or uncomment this line and import a data frame with columns 'lon' and 'lat'
#locations=read.csv(file.choose())

## Start timer for performance monitoring by uncommenting this line
#start=Sys.time()

## Reproject dataframe into spatial data object that matches land geojson projection
coordinates(locations)=c('lon','lat')
as(locations,"SpatialPoints")
proj4string(locations)=CRS("+proj=longlat +datum=WGS84")

## Check to see if locations are on land or in water
locations$Water=over(locations,land)$featurecla
locations$Water=ifelse(
  is.na(locations$Water),
  TRUE,
  FALSE
)

## End timer for performance monitoring and calculate time elapsed by uncommenting these lines
#end=Sys.time()
#end-start

## View Results
as.data.frame(locations)
table(locations$Water)