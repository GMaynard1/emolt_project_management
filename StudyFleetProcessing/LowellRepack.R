## ---------------------------
## Script name: LowellRepack.R
##
## Purpose of script: To repackage a directory of Lowell probe
##    downloads from a single vessel into one large file for
##    upload into the Study Fleet Management System. 
##
## Date Created: 2021-12-21
##
## Copyright (c) NOAA Fisheries, 2021
##
## Email: george.maynard@noaa.gov
##
## ---------------------------
## Notes: Eventually, this logic will be integrated into a 
##  larger script to crawl the directory structure, but for
##  now it must be run for each directory individually
## ---------------------------
## Select a directory to run the procedure on
## The target directory should be one in the format YYYYMM that
## resides within a vessel directory. Eventually, we will expand
## this procedure to loop within a vessel directory
targetDir=choose.dir()

## Enter the vessel name. Eventually this will be replaced with
## a function to read the name from the file structure
vessel=readline(
  prompt="Please enter vessel name (no spaces): "
)

## Set the working directory to the target
setwd(targetDir)

## Create empty lists to store chunks of files
headerList=list()
dataList=list()

## Loop over the .csv files in the directory
for(i in 1:length(dir())){
  ## Read in the full file
  temp=read.delim(dir()[i],header=FALSE)
  ## Split off the header
  headerList[[i]]=temp[1:9,]
  ## Split off the data
  dataList[[i]]=temp[11:nrow(temp),]
  ## Check the header against previous headers to make sure 
  ## they are all the same
  if(i > 1){
    if(prod(headerList[[i]]==headerList[[i-1]])!=1){
      stop(
        paste(
          'headers do not match \n file 1: ',
          dir()[i-1],
          '\n file 2: ',
          dir()[i]
        )
      )
    }
  }
}

## Create a single vector of all of the data from the 
## dataList object
data=unlist(dataList,recursive=FALSE)

## Attach a header and column titles to create a new object
newdata=c(headerList[[1]],temp[10,],data)

## Print the new object out to a file
write(
  newdata,
  file=paste0(
    vessel,
    "_",
    substr(
      getwd(),
      start=nchar(getwd())-5,
      stop=nchar(getwd())
    ),
    ".csv"
  )
)