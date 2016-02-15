library("OpenStreetMap")
library("ggplot2")
library("dplyr")
library("gganimate")
library("animation")

load("train_data/complemented_timetable.RData")

# Some transformations for getting projected coordinates
# and not having missing data
timetableMap <- timetableMap %>% filter(!is.na(nextStationName))%>%
  mutate(x1 = NA, x2 = NA,
         y1 = NA, y2 = NA)

whichNotNA1 <- which(!is.na(timetableMap$lat1))
whichNotNA2 <- which(!is.na(timetableMap$lat2))

monitors_merc1 <- as.data.frame(
  projectMercator(timetableMap$lat1[whichNotNA1], 
                  timetableMap$long1[whichNotNA1], drop=FALSE))
x1 <- monitors_merc1$x
y1 <- monitors_merc1$y
monitors_merc2 <- as.data.frame(
  projectMercator(timetableMap$lat2[whichNotNA2], 
                  timetableMap$long2[whichNotNA2], drop=FALSE))
x2 <- monitors_merc2$x
y2 <- monitors_merc2$y

timetableMap$x1[whichNotNA1] <- x1
timetableMap$y1[whichNotNA1] <- y1
timetableMap$x2[whichNotNA2] <- x2
timetableMap$y2[whichNotNA2] <- y2


# Video for one train

number <- "07703"

onetrain <- filter(timetableMap,
                   trainNo == number,
                   stationName != "godavari",
                   nextStationName != "godavari") %>%
  arrange(departureTime) %>%
  mutate(sourceStationName = gsub(" railway India", "", sourceStationName),
         destStationName = gsub(" railway India", "", destStationName))
if(nrow(onetrain)>5){
  print(number)
  onetrain <- mutate(onetrain,
                     segment = 1:nrow(onetrain)) %>%
    mutate(segment = paste0(stringr::str_pad(segment, 2, pad = "0"),"-", stationName))
  p <- ggplot2::autoplot(indiaMap)+ theme_bw()+
    geom_segment(data = onetrain, aes(x = x1,
                                      y = y1,
                                      xend = x2,
                                      yend = y2,
                                      frame = segment,
                                      cumulative = TRUE),
                 size = 2, colour = "darkblue")+
    theme(axis.line=element_blank(),axis.text.x=element_blank(),
          axis.text.y=element_blank(),axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          text = element_text(size=20),
          axis.title.y=element_blank(),legend.position="none",
          panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),plot.background=element_blank())+
    ggtitle(paste0(onetrain$sourceStationName[1], " to ", onetrain$destStationName[1])) +
    theme(plot.title = element_text(lineheight=1, face="bold"))
  ani.options(interval = 1, ani.width = 800, ani.height = 800)
  gg_animate(p, paste0("video/", number,"mapOne.mp4"))
  #gg_animate(p, paste0(getwd(),"/video/", number,"mapOne.gif"))
}