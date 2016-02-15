# data from https://data.gov.in/catalog/indian-railways-train-time-table-0
# inspiration http://curiousanalytics.blogspot.com.es/2015/04/indian-railways-network-using-r.html

# load packages
library("dplyr")
library("readr")
library("lubridate")
# get and transform data
timetable <- read_csv("train_data/timetable.csv")
names(timetable) <- c("trainNo", "trainName",
                      "islno",
                      "stationCode", "stationName",
                      "arrivalTime",
                      "departureTime", "distance",
                      "sourceStationCode", "sourceStationName",
                      "destStationCode", "destStationName")
timetable <- timetable%>%
  # time as time
  mutate(arrivalTime = hms(arrivalTime),
         departureTime = hms(departureTime)) %>%
  mutate(hourDeparture = hour(departureTime),
         numDeparture = as.character(departureTime),
         trainNo = gsub("'", "", trainNo)) 

save(timetable, file = "train_data/train_timetable.Rdata")