load("train_data/train_timetable.RData")
load("geo_data/geoInfo.RData")
timetable <- timetable %>% 
  # Remove 'JN', which represents junction, from station names     
  mutate(sourceStationName = gsub(" JN", "", sourceStationName),
         destStationName = gsub(" JN", "", destStationName),
         stationName = gsub(" JN", "", stationName)) %>%
  # Append "railway India" in station name
  mutate(sourceStationName = paste0(sourceStationName, " railway India"),
         destStationName = paste0(destStationName, " railway India"),
         stationName = paste0(stationName, " railway India"))

# add stationName2 which is the next station for the train
timetableMap <- timetable %>% 
  arrange(trainNo) %>%
  group_by(trainNo) %>%
  mutate(nextStationName = lead(stationName)) %>%
  select(trainNo, stationName, nextStationName, everything()) %>%
  ungroup() %>%
  mutate(stationName = tolower(gsub(" railway India", "", stationName)),
         nextStationName = tolower(gsub(" railway India", "", nextStationName)))
# add latitude and longitude
geo1 <- timetableMap %>% left_join(listNames, c("stationName" = "name")) %>%
  select(lat, long)
latA <- geo1$lat
longA <- geo1$long
geo2 <- timetableMap %>% left_join(listNames, c("nextStationName" = "name")) %>%
  select(lat, long)
latB <- geo2$lat
longB <- geo2$long

timetableMap <- timetableMap %>%
  mutate(lat1 = latA,
         long1 = longA,
         lat2 = latB,
         long2 = longB) %>%
  select(trainNo,
         stationName,
         lat1,
         long1,
         nextStationName,
         lat2, 
         long2, 
         everything())

save(timetableMap, file="train_data/complemented_timetable.RData")
