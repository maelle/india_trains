###############################################################
# Load packages and helper functions
###############################################################

library("xml2")
library("lubridate")
library("dplyr")

findThing <- function(vector, thing){
  lala <- unlist(strsplit(vector, " "))
  value <- lala[grepl(thing, lala)][1]
  value <- gsub(thing, "", value)
  value <- gsub("=\"", "", value)
  value <- gsub("\"", "", value)
  value <- gsub(">\n", "", value)
  return(value)
}

findThingBis <- function(vector, thing){
  lala <- unlist(strsplit(vector, " "))
  value <- lala[which(grepl(thing, lala))+1][1]
  value <- gsub(thing, "", value)
  value <- gsub("v=\"", "", value)
  value <- gsub("\"", "", value)
  value <- gsub(">\n", "", value)
  value <- gsub("/", "", value)
  return(value)
}

###############################################################
# Load file
###############################################################

filePath <- "osm_data/india_train_stations.osm"
test <- read_xml(filePath)

essai <- as.character(test)
essai <- unlist(strsplit(essai, "</node>"))
essai <- essai[2:(length(essai)-1)]


###############################################################
# Transform data into data.frame
###############################################################

timestamp <- unlist(lapply(essai, findThing, "timestamp"))
id <- unlist(lapply(essai, findThing, "id"))
version <- unlist(lapply(essai, findThing, "version"))
uid <- unlist(lapply(essai, findThing, "uid"))
user <- unlist(lapply(essai, findThing, "user"))
changeset <- unlist(lapply(essai, findThing, "changeset"))
lat <- unlist(lapply(essai, findThing, "lat"))
lon <- unlist(lapply(essai, findThing, "lon"))
name <- unlist(lapply(essai, findThingBis, "name"))
nameJa <- unlist(lapply(essai, findThingBis, "name:ja"))

dataIndiaStations <- data.frame(timestamp = ymd_hms(timestamp),
                                id = factor(id),
                                version = factor(version),
                                uid = factor(uid),
                                user = factor(user),
                                changeset = factor(changeset),
                                lat = as.numeric(lat),
                                lon = as.numeric(lon),
                                name = as.factor(name),
                                nameJa = as.factor(nameJa))
dataIndiaStations <- tbl_df(dataIndiaStations) %>%
  filter(!is.na(lat),
         !is.na(lon))
dataIndiaStations
save(dataIndiaStations, file ="osm_data/OSMdataIndiaStations.RData")