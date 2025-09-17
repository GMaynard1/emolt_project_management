strata=sf::read_sf("C:/Users/george.maynard/Documents/GIS/survey_strata/strata.shp")
botgrid=read.csv("C:/Users/george.maynard/Documents/GitHubRepos/BotGrid/fishbot_realtime_aggregated_season_strata.csv")
for(s in c("fall","winter","spring","summer")){
  for(y in seq(2006,2025)){
    data=subset(botgrid,botgrid$year==y&botgrid$season==s)
    x=merge(strata,data,by="STRATA",all.x=TRUE)
    filename=paste0("C:/Users/george.maynard/Documents/GIS/botGrid_strata/",y,"_",s,".shp")
    sf::st_write(x,filename)
  }
}
