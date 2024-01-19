library(marmap)
library(lubridate)
library(scatterplot3d)
library(RColorBrewer)

## List of files
files = dir("C:/Users/george.maynard/Documents/OneOffs/202310_SouthShore_Lee/Data")
## Set the proportion of the water column to sample
pdepth=0.85
## South Shore
data=read.csv(
  file = paste0(
    "C:/Users/george.maynard/Documents/OneOffs/202310_SouthShore_Lee/Data/",
    files[1]
  ),skip=8)
data=subset(data,data$Depth..m.<=pdepth*max(data$Depth..m.))
data$Timestamp=dmy_hms(data$datet.GMT.)
data$profile=NA
data$direction=NA
p=1
data=data[order(data$Timestamp),]
for(i in 1:nrow(data)){
  if(i==1){
    data$profile[i]=p
  } else {
    if(data$Depth..m.[i]>data$Depth..m.[i-1]&&floor_date(data$Timestamp[i],unit="day")==floor_date(data$Timestamp[i],unit="day")){
      data$profile[i]=p
      data$direction[i]="DOWN"
    } else {
      p=p+1
      data$profile[i]=p
      data$direction[i]="UP"
    }
  }
}
data2=data
data=subset(data,data$HEADING=="EMPTY")
for(j in unique(data2$profile)){
  data3=subset(data2,data2$profile==j)
  if(nrow(data3)>5){
    data=rbind(data,data3)
  }
}
for(z in 2:length(files)){
  data2=read.csv(
    file=paste0(
      "C:/Users/george.maynard/Documents/OneOffs/202310_SouthShore_Lee/Data/",
      files[z]
    ),
    skip=8
  )
  data2=subset(data2,data2$Depth..m.<=pdepth*max(data$Depth..m.))
  data2$profile=NA
  data2$direction=NA
  data2$Timestamp=dmy_hms(data2$datet.GMT.)
  data2=data2[order(data2$Timestamp),]
  p=p+1
  for(i in 1:nrow(data2)){
    if(i==1){
      data2$profile[i]=p
    } else {
      if(data2$Depth..m.[i]>data2$Depth..m.[i-1]&&floor_date(data2$Timestamp[i],unit="day")==floor_date(data2$Timestamp[i],unit="day")){
        data2$profile[i]=p
        data2$direction[i]="DOWN"
      } else {
        p=p+1
        data2$profile[i]=p
        data2$direction[i]="UP"
      }
    }
  }
  for(j in unique(data2$profile)){
    data3=subset(data2,data2$profile==j)
    if(nrow(data3)>5){
      data=rbind(data,data3)
    }
  }
}
data$Depth=data$Depth..m.*-0.546807
data$Temp=(data$Temperature..C.*9/5)+32
cols=brewer.pal(11,"RdYlBu")
pal=colorRampPalette(cols)
CR=rev(pal(31))
data$col=NA
for(i in seq(0,30)){
  data$col[which(round(data$Temperature..C.,0)==i)]=CR[i]
}
for(i in unique(data$profile)){
  x=subset(data,data$profile==i)
  
  plot(
    x$Depth~x$Temp,
    type='l',
    xlim=c(45,75),
    ylim=c(-20,0),
    main=paste0(
      "Profile: ",
      i,
      " Time: ",
      difftime(max(x$Timestamp),min(x$Timestamp),units="mins"),
      " Direction: ",
      unique(x$direction,na.rm=TRUE)
    )
  )
}
plot(
  data$Depth~data$Temp,
  type='n',
  xlab="Temperature (F)",
  ylab="Depth (fathoms)",
  main=pdepth,
  xlim=c(45,75),
  ylim=c(-20,0))
data=data[order(data$Timestamp),]
for(i in unique(data$profile)){
  x=subset(data,data$profile==i)
  if(x$Timestamp[1]<ymd("2023-09-16")){
    col='lightpink'
  } else {
    col='blue'
  }
  lines(x$Depth~x$Temp,col=col,lwd=2)
}
