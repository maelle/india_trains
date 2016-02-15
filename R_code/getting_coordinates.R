# load data and packages
load("train_data/train_timetable.RData")
library("stringdist")
library("ggmap")
library("dplyr")

# transform it a bit
timetable <- timetable %>% 
  # Remove 'JN', which represents junction, from station names     
  mutate(sourceStationName = gsub(" JN", "", sourceStationName),
         destStationName = gsub(" JN", "", destStationName),
         stationName = gsub(" JN", "", stationName)) %>%
  # Append "railway India" in station name
  mutate(sourceStationName = paste0(sourceStationName, " railway India"),
         destStationName = paste0(destStationName, " railway India"),
         stationName = paste0(stationName, " railway India"))

# get unique names
listNames <- unique(c(unique(timetable$stationName),
                      unique(timetable$sourceStationName),
                      unique(timetable$destStationName)))
# then use ggmap geocode functions,
# because of the daily limit do it in two parts 
# either two days or send the data to someone else :-)
# list1 <- listNames[1:2200]
# list2 <- listNames[2201:4334]
# save(list1, file="list1.RData")
# save(list2, file="list2.RData")
# geoInfo1 <- geocode(list1)
# data1 <- data.frame(name = list1,
#                     lat = geoInfo1$lat,
#                     long = geoInfo1$long)
# save(data1, file = "geo_data/part1.RData")
# geoInfo2 <- geocode(list2)
# data2 <- data.frame(name = list2,
#                    lat = geoInfo2$lat,
#                    long = geoInfo2$long)
# save(data2, file = "geo_data/part2.RData")



# priority to coordinates we got from Google maps !

load("geo_data/part1.RData")
load("geo_data/part2.RData")
listNames <- rbind(data1, data2)
listNames <- tbl_df(listNames) %>%
  mutate(name = gsub(" railway India", "", name)) %>%
  mutate(name = tolower(name))

sum(is.na(listNames$lat))

load("osm_data/OSMdataIndiaStations.RData")
dataIndiaStations <- mutate(dataIndiaStations,
                            name = tolower(name))

# find close matches
ClosestMatch2 <- function(string, stringVector){
  stringVector[amatch(string, stringVector, maxDist=Inf)]
}
ClosestMatchCoord <- function(string, stringVector){
  amatch(string, stringVector, maxDist=Inf)
} 

indices <- which(is.na(listNames$lat))
values <- rbind(ClosestMatch2(listNames$name[indices],
                              dataIndiaStations$name),
                listNames$name[indices])
matches <- ClosestMatchCoord(listNames$name[indices],
                             dataIndiaStations$name)

latNew <- dataIndiaStations$lat[matches]
latNew[stringdist(values[1,],
                  values[2,]) > 1] <- NA
lonNew <- dataIndiaStations$lon[matches]
lonNew[stringdist(values[1,],
                  values[2,]) > 1] <- NA
# complete
listNames[indices,]$lat <- latNew
listNames[indices,]$long <- lonNew

save(listNames, file = "geo_data/geoInfo.RData")

# and now add coordinates info to our timetable
