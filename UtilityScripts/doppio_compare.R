data=read.csv(file.choose())
data$FOR=data$forecast_temp*9/5+32
data$OBS=data$obs_temp*9/5+32
sum(abs(data$FOR-data$OBS)<=2)/nrow(data)
