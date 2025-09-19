setwd("C:/Users/george.maynard/Downloads/Jericho DO/")
files=dir()
for(file in files){
  if(file==files[1]){
    data=read.csv(file)
  } else {
    x=read.csv(file)
    data=rbind(data,x)
  }
}
data=subset(data,data$Water.Detect....>50)
data$ISO.8601.Time=lubridate::ymd_hms(data$ISO.8601.Time)
plot(
  data$Dissolved.Oxygen..mg.l.~data$ISO.8601.Time,
  xlab = "",
  ylab = "DO mg/l",
  ylim = c(0,12),
  pch=16,
  col='darkgray')
abline(h=6,col='blue',lty=2,lwd=2)
abline(h=2,col='red',lty=2,lwd=2)
