# # SCRIPT TO CREATE DF WITH LAT-LON FOR UNIQUE LOCALITES
rm(list=ls(all=TRUE))
# PACKAGES
library(ggmap)
# LOAD DATA
load("02_3_tm_ready.RData")
# obtain geocode from GOOGLE API
latlon <- geocode(unique(df$LOCALITY)) # get lat-lon from Google API
lat <- as.numeric(latlon[,1]) # as numeric
lon <- as.numeric(latlon[,2]) # as numeric
df_geoloc <- as.data.frame(unique(df$LOCALITY)) # create dataframe from localities and lat lon
names(df_geoloc)[1] <- 'LOCALITY' # set name for localities
df_geoloc$LAT <- lat
df_geoloc$LON <- lon
# Script unable to find the following
# 1: geocode failed with status ZERO_RESULTS, location = "fleurdelys" 
# 2: geocode failed with status ZERO_RESULTS, location = "unknown" 
# 3: geocode failed with status ZERO_RESULTS, location = "gozo san lawrenz" 
# 4: geocode failed with status ZERO_RESULTS, location = "floriana" 
# 5: geocode failed with status ZERO_RESULTS, location = "st thomas bay" 
# 6: geocode failed with status ZERO_RESULTS, location = "quisisana" 
# 7: geocode failed with status ZERO_RESULTS, location = "gozo qbajjar" 
# Replace missing with hard coded options
# fleurdelys 35.894523, 14.467834
df_geoloc$LON[grepl("fleurdelys",df_geoloc$LOCALITY)] <- 35.894523
df_geoloc$LAT[grepl("fleurdelys",df_geoloc$LOCALITY)] <- 14.467834
# gozo san lawrenz 36.055 14.20417
df_geoloc$LON[grepl("gozo san lawrenz",df_geoloc$LOCALITY)] <- 36.055
df_geoloc$LAT[grepl("gozo san lawrenz",df_geoloc$LOCALITY)] <- 14.20417
# floriana 35.89234 14.50290
df_geoloc$LON[grepl("floriana",df_geoloc$LOCALITY)] <- 35.89234
df_geoloc$LAT[grepl("floriana",df_geoloc$LOCALITY)] <- 14.50290
#"st thomas bay"  35.85720 14.56626
df_geoloc$LON[grepl("st thomas bay",df_geoloc$LOCALITY)] <- 35.85720
df_geoloc$LAT[grepl("st thomas bay",df_geoloc$LOCALITY)] <- 14.56626
# quisisana 35.91067 14.50836
df_geoloc$LON[grepl("quisisana",df_geoloc$LOCALITY)] <- 35.91067
df_geoloc$LAT[grepl("quisisana",df_geoloc$LOCALITY)] <- 14.50836
# "gozo qbajjar"  36.07616 14.25591
df_geoloc$LON[grepl("gozo qbajjar",df_geoloc$LOCALITY)] <- 36.07616
df_geoloc$LAT[grepl("gozo qbajjar",df_geoloc$LOCALITY)] <- 14.25591
# pieta 35.89341 14.49417
df_geoloc$LON[grepl("pieta",df_geoloc$LOCALITY)] <- 35.89341
df_geoloc$LAT[grepl("pieta",df_geoloc$LOCALITY)] <- 14.49417
# paola 35.88211 14.51018
df_geoloc$LON[grepl("paola",df_geoloc$LOCALITY)] <- 35.88211
df_geoloc$LAT[grepl("paola",df_geoloc$LOCALITY)] <- 14.51018
# safi 35.83622 14.49271
df_geoloc$LON[grepl("safi",df_geoloc$LOCALITY)] <- 35.83622
df_geoloc$LAT[grepl("safi",df_geoloc$LOCALITY)] <- 14.49271
# pembroke 35.92907 14.47524
df_geoloc$LON[grepl("pembroke",df_geoloc$LOCALITY)] <- 35.92907
df_geoloc$LAT[grepl("pembroke",df_geoloc$LOCALITY)] <- 14.47524
# salina -> bahar ic caghaq 35.93726 14.45195
df_geoloc$LON[grepl("salina",df_geoloc$LOCALITY)] <- 35.93726 
df_geoloc$LAT[grepl("salina",df_geoloc$LOCALITY)] <-  14.45195
# rabat 35.88550 14.37337
df_geoloc$LON[grepl("rabat",df_geoloc$LOCALITY)] <- 35.88550
df_geoloc$LAT[grepl("rabat",df_geoloc$LOCALITY)] <- 14.37337
# marsa 35.87358 14.49271
df_geoloc$LON[grepl("marsa",df_geoloc$LOCALITY)] <- 35.87358
df_geoloc$LAT[grepl("marsa",df_geoloc$LOCALITY)] <- 14.49271
# madliena  35.92314 14.47384
df_geoloc$LON[grepl("madliena",df_geoloc$LOCALITY)] <- 35.92314
df_geoloc$LAT[grepl("madliena",df_geoloc$LOCALITY)] <- 14.47384

# check that values make sense
# MALTA RANGE
# Latitude	35.917973
# Longitude	14.409943
# df_geoloc
# sort(unique(df$LOCALITY),decreasing = FALSE)
# min( as.numeric(df_geoloc$LAT),na.rm = TRUE)
# max( as.numeric(df_geoloc$LAT),na.rm = TRUE)
# min( as.numeric(df_geoloc$LON),na.rm = TRUE)
# max( as.numeric(df_geoloc$LON),na.rm = TRUE)

save(df_geoloc,file = '02_LOCALITY_LAT_LONG.RData')