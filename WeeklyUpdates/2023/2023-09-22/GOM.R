library(marmap)
library(lubridate)
library(scatterplot3d)
library(RColorBrewer)
filelist=dir("C:/Users/george.maynard/Documents/OneOffs/202309_GOM_Lee/data/")
data=read.csv(paste0("C:/Users/george.maynard/Documents/OneOffs/202309_GOM_Lee/data/",filelist[1]),skip=8)
data=subset(data,data$Depth..m.<=0.80*max(data$Depth..m.))
data$profile=NA
p=1
for(i in 1:nrow(data)){
  if(i==1){
    data$profile[i]=p
  } else {
    if(data$Depth..m.[i]>data$Depth..m.[i-1]){
      data$profile[i]=p
    } else {
      data$profile[i]=p+1
    }
  }
}
for(i in filelist[-1]){
  x=read.csv(paste0("C:/Users/george.maynard/Documents/OneOffs/202309_GOM_Lee/data/",i),skip=8)
  x=subset(x,x$Depth..m.<=0.8*max(x$Depth..m.))
  x$profile=NA
  p=p+2
  for(j in 1:nrow(x)){
    if(j==1){
      x$profile[j]=p
    } else {
      if(x$Depth..m.[j]>x$Depth..m.[j-1]){
        x$profile[j]=p
      } else {
        x$profile[j]=p+1
      }
    }
  }
  data=rbind(data,x)
}

data$Timestamp=dmy_hms(data$datet.GMT.)
data$Depth=data$Depth..m.*-0.546807
data$Temp=(data$Temperature..C.*9/5)+32
cols=brewer.pal(11,"RdYlBu")
pal=colorRampPalette(cols)
CR=rev(pal(31))
data$col=NA
for(i in seq(0,30)){
  data$col[which(round(data$Temperature..C.,0)==i)]=CR[i]
}
plot(
  data$Depth~data$Temp,
  type='n',
  xlab="Temperature (F)",
  ylab="Depth (fathoms)",
  main="Gulf of Maine",
  xlim=c(32,80),
  ylim=c(-45,0))
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
