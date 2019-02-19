## SUMMARY OF DATA using VISUALS ###############################################
print('SUMMARY OF DATA USING VISUALS')
# rm(list=ls(all=TRUE))
load('02_3_tm_ready.RData')
# LIBRARIES
# library(ggplot2,ggthemes,Hmisc,ggmap,scales,RColorBrewer,plyr,ggrepel,reshape2)
# # VIZ 1 - LOCALITY VS PRICE  ########
print('VIZ 1 - GEOVIZ SHOWING LOCALITY VS PRICE')
load('02_LOCALITY_LAT_LONG.RData') # load Lat-Long data and merge
df_loc_price <- df[,which(names(df) %in% c('LOCALITY','PRICE'))]
df_loc_price <- ddply(df_loc_price,.(LOCALITY),summarise,MEAN_PRICE=mean(PRICE))
df_loc_price <- merge(x = df_loc_price, y = df_geoloc, by = "LOCALITY", all.x = TRUE)
df_loc_price <- subset(df_loc_price,!is.na(LAT)) #remoce NA
df_loc_price$LOCALITY <- capitalize(df_loc_price$LOCALITY)

MAP_centre <- c(left=14.17,bottom = 35.8, right=14.58,top=36.09) # DEFINE LAT-LONG BOUNDARIES FOR MALTA
MAP_MT <- get_map(location = MAP_centre,
                  source = 'stamen',
                  maptype = "toner-lite",
                  crop = TRUE)# GET MAP
viz1 <- ggmap(MAP_MT,extent = 'device') # SAVE TO GGPLOT ENVIRONEMENT

load('viz1.Rdata') # LOAD MAP
viz1 <- viz1 + geom_point(aes(y=LON, x=LAT,
                              color = MEAN_PRICE),
                          data = df_loc_price,
                          alpha=0.45,
                          size=df_loc_price$MEAN_PRICE*.000015,
                          na.rm = TRUE) # ADD POINTS WITH MEAN PRICE
viz1 <-  viz1 + scale_colour_distiller(name = 'Mean price',
                                       type = 'div',
                                       palette = "Spectral",
                                       guide = 'colourbar',
                                       labels = dollar_format(suffix = "", prefix = "€")) # DEFINE COLOUR SETTINGS
df_top_price <- head(df_loc_price[order(df_loc_price$MEAN_PRICE,decreasing = TRUE),],10) # ORDER AND SELECT TOP 10
viz1 <- viz1 + geom_text_repel(aes(y=LON,x=LAT,
                                   label = LOCALITY),
                               data = df_top_price,
                               color = 'grey40') # ADD ANNOTATIONS
viz1 <- viz1 + theme_tufte(base_family="Helvetica") #THEME SETTINGS
viz1 <- viz1 + theme(legend.position = c(0.1, 0.15),
                     legend.background = element_rect(color = "black",fill = "white",
                                                      size = 0.5, linetype = "solid"),
                     plot.title=element_text(hjust=0.5))#ADDITIONAL SETTINGS
viz1 <- viz1 + ggtitle("Top 10 highest mean properties across Malta") #TITLE
viz1 <- viz1 + labs(x="Latitude",y="Longitude")#LABELS
df_top_price$TITLE <- paste("€",format(round(df_top_price$MEAN_PRICE,0), big.mark=","),sep="")#LIST FORMATTING
df_top_price$ID <- seq.int(nrow(df_top_price)) #ID FOR LIST
df_top <- paste(df_top_price$ID,'. ',
                df_top_price$LOCALITY," ",
                df_top_price$TITLE,sep = '',collapse = '\n')#CONVERT LIST TO SINGLE LINE
viz1 <- viz1  + annotate("text", x = 14.57, y = 36.08, label = df_top,
                         hjust = 1, vjust = 1)#PAST STRING TO MAP
#viz1
ggsave("02_viz1_highest_mean_properties.tiff", plot = viz1,
       height = 7.5, width = 7.5, unit='in',dpi = 600) #SAVE TO FILE
# # VIZ 2 - TYPE VS PRICE ####
print('VIZ 2 - BOX-WHISKER PLOT SHOWING TYPE VS PRICE')
df_type_price <- df[,which(names(df) %in% c('TYPE','PRICE'))] #df for type vs price
df_type_price$TYPE <- sapply(df_type_price$TYPE, function(XX) capitalize(XX)) # capitalize words
df_type_price_mean <- ddply(df_type_price, .(TYPE), summarise, MEAN = round(mean(PRICE),0)) #calculate mean
df_type_price_stats <- as.data.frame(table(df_type_price$TYPE)) # calulcation of stats
df_type_price_stats <- df_type_price_stats[order(df_type_price_stats$Freq,decreasing = TRUE),] #order with the most popular type
df_type_price_stats$PER <- round((df_type_price_stats$Freq / sum(df_type_price_stats$Freq)*100),1) # calculate percentage
names(df_type_price_stats)[1] <- 'TYPE'#RENAME FIRST COLUMN FOR CONTINUITY
df_type_price_stats <- merge(x = df_type_price_stats,
                             y = df_type_price_mean,
                             by = 'TYPE', all.x = TRUE) #MERGE COMPUTED STATS
df_type_price_stats$MEAN <- paste("€",format(df_type_price_stats$MEAN, big.mark=","),sep="") #FORMAT CURRENCY
df_type_price_stats$TITLE <- paste(df_type_price_stats$TYPE,"\n",
                                   df_type_price_stats$MEAN,sep = '') #DEFINE TITLE
df_type_price_stats <- df_type_price_stats[,which(names(df_type_price_stats) %in% c('TYPE','TITLE','Freq','MEAN'))] # retain TYPE and TITLE only
df_type_price <- merge(x = df_type_price,
                       y = df_type_price_stats,
                       by = 'TYPE', all.x = TRUE) # merge the data with stats title
# remove € and , from Mean Price
df_type_price$MEAN2 <- gsub('€','',df_type_price$MEAN)
df_type_price$MEAN2 <- gsub(',','',df_type_price$MEAN2)
df_type_price$TITLE <- factor(df_type_price$TITLE,
                              levels = unique(df_type_price[order(df_type_price$MEAN2,decreasing = TRUE),"TITLE"]) ) #ORDER according to Mean Price
# remove properties which are less than 1% of the data
XX <- c('office','plot','palazzo','commercial','land','shop','site','restaurant','bar','industrial','field','hostel','bakery','mansion','shed','remissa')
XX <- capitalize(XX)
df_type_price <- df_type_price[!grepl(paste("^",XX,"$",sep = "",collapse = "|"),
                                      df_type_price$TYPE, ignore.case = FALSE),]
# PLOT
viz2 <- ggplot(data = subset(df_type_price,!is.na(TITLE)),
               aes(x = TITLE, y = PRICE)) + geom_boxplot(aes(fill = MEAN )) #DEFINE BASIS FOR PLOT - BARPLOT
viz2 <- viz2 + theme_tufte(base_family="Helvetica") #THEME SETTINGS
viz2 <- viz2 + theme(axis.text.x = element_text(angle = 45, hjust = 1,vjust = 1),
                     plot.title=element_text(hjust=0.5),
                     legend.position="none")#ADDITIONAL THEME SETTINGS
viz2 <- viz2 + scale_y_continuous(labels = dollar_format(suffix = "", prefix = "€"))#FORMAT SCALE
viz2 <- viz2 + ggtitle("Type of Property vs Price")#TITLE
viz2 <- viz2 + labs(x="Type of Property",y="Price")#LABELS
viz2 <- viz2 + scale_fill_manual(name = "Mean price",
                                 values = rev(colorRampPalette(brewer.pal(9,'RdBu'))(12)),
                                 labels = unique(df_type_price$MEAN))#LEGEND FORMATTING
viz2 <- viz2 + coord_flip()#FLIP COORDINATES
#viz2
ggsave("02_viz2_property_vs_price.tiff", plot = viz2,
       height = 5, width = 5, unit='in',dpi = 600)#SAVE TO FILE
# # VIZ 3 - WHEN TO BUY ####
print('VIZ - LINE CHARTS SHOWING WHICH TIME OF THE YEAR PROPERTIES ARE BELOW MEAN SELLING PRICE')
# change grouping
df_when2buy <- df #STARTING POINT
df_when2buy$MONTH <- substr(capitalize(as.character(df_when2buy$MONTH)),1,3) #abbreviate and substring
df_when2buy$MONTH <- factor(df_when2buy$MONTH,levels = month.abb) #order months
df_when2buy$TYPE_GROUPING <- capitalize(df_when2buy$TYPE_GROUPING) # capitalize type
df_when2buy$TYPE_GROUPING <- factor(df_when2buy$TYPE_GROUPING,
                                    levels = c("Apartment","Maisonette","House","Villa","Commercial",NA)) #order propert type
# summarise the data
df_mean_type <- ddply(df_when2buy,.(TYPE_GROUPING),summarise,
                      PRICE_TYPE = mean(PRICE)) #mean price per type GROUPING
df_when2buy <- ddply(df_when2buy,.(TYPE_GROUPING,MONTH),summarise,
                     MEAN_PRICE =mean(PRICE),COUNT= length(TYPE)) #CALCULATE COUNT
df_when2buy <- merge(x = df_when2buy,
                     y = df_mean_type,
                     by = 'TYPE_GROUPING', all.x = TRUE) # merge the data with stats title
# plot
viz3 <- ggplot(data = subset(df_when2buy,!is.na(TYPE_GROUPING)),
               aes(x = MONTH,y = MEAN_PRICE,
                   group = TYPE_GROUPING,
                   color = TYPE_GROUPING)) #DEFINE BASIS DATA
viz3 <- viz3 + geom_line(aes(x = MONTH,
                             y = PRICE_TYPE),
                         colour = 'grey60', linetype = "dashed") #ADD BACKGROUND LINE
viz3 <- viz3 + geom_line() + geom_point() #when2buy data
viz3 <- viz3 + geom_text(data = subset(df_when2buy,!is.na(TYPE_GROUPING)),
                         aes(x = MONTH,y = PRICE_TYPE,
                             label = COUNT),
                         color = 'grey60') #when2buy data
viz3 <- viz3 + scale_y_continuous(labels = dollar_format(suffix = "", prefix = "€")) #FORMAT TEXT
viz3 <- viz3 + facet_grid(TYPE_GROUPING~.,scales = 'free_y') #SET FACETS
viz3 <- viz3 + theme_few(base_family="Helvetica") #THEME SETTINGS
viz3 <- viz3 + theme(plot.title=element_text(hjust=0.5),
                     legend.position="none") #ADDITIONAL THEME SETTINGS
viz3 <- viz3 + ggtitle("When to buy a property below Mean price?") #TITLE
viz3 <- viz3 + labs(x="Month",y="Mean price") #LABELS
# create df with labels for Mean - Count
df_text <- subset(df_when2buy,!is.na(TYPE_GROUPING))
df_text <- ddply(df_text,.(TYPE_GROUPING),summarise,
                 MAXPRICE_TYPE = max(MEAN_PRICE)) #MAX mean price per type
df_text$X <- rep(6,5) #X POSITION OF LABELS
df_text$LABEL <- rep('Mean - Count',5) #LABEL
viz3 <- viz3 + geom_text(data = df_text,
                         aes(x=X,
                             y=MAXPRICE_TYPE-750,
                             label=LABEL))#ADD "Mean - Count" LABEL TO FACETS
#viz3
ggsave("02_viz3_when2buy.tiff", plot = viz3,
       height = 7.5, width = 7.5, unit='in',dpi = 600) # SAVE TO FILE
# # VIZ 4 - DISTRIBUTION OF TYPE BY DISTRICT ####
print('VIZ 4 - BARCHARTS SHOWING DISTRIBUTION OF PROPERTY TYPES ACROSS THE DISTRICT IN MALTA & GOZO')
df_type_loc <- df
df_type_loc <- ddply(df_type_loc,.(TYPE_GROUPING,DISTRICT),summarise,
                     COUNT= length(TYPE_GROUPING),MEAN_PRICE = mean(PRICE)) #SUMMARIZE ON TYPE_GROUPING AND DISTRICT
df_type_loc_sum <- ddply(df,.(DISTRICT),summarise,GROUPSUM= length(TYPE_GROUPING)) #TOTAL NUMBER OF PROPS PER DISTRICT
df_type_loc <- merge(x = df_type_loc,
                     y = df_type_loc_sum,
                     by = 'DISTRICT', all.x = TRUE) # merge the data
df_type_loc$PERCENTAGE <- round(df_type_loc$COUNT / df_type_loc$GROUPSUM,1) #CALC PERCENTAGE
df_type_loc$DISTRICT <- gsub("_"," ",df_type_loc$DISTRICT) #FORMAT DISTRICT
df_type_loc$DISTRICT <- factor(df_type_loc$DISTRICT,
                               levels = c("Gozo","Northen","Western","North Harbour","South Harbour","South Eastern")) #FORMAT DISTRICT LEVELS
df_type_loc <- subset(df_type_loc,!is.na(TYPE_GROUPING)) #REMOVE NA
df_type_loc <- df_type_loc[which(df_type_loc$DISTRICT != 'unknown'),] #REMOVE UNKNOWNS
df_type_loc$TYPE_GROUPING <- capitalize(df_type_loc$TYPE_GROUPING) #CAPITALISE
# PLOT
viz4 <- ggplot(data = df_type_loc,aes(x = DISTRICT,y = PERCENTAGE,
                                      fill = factor(TYPE_GROUPING))) #DEFINE BASIS
viz4 <- viz4 + geom_bar(stat = "identity", position = 'dodge') #DEFINE CHART ELEMENT
viz4 <- viz4 + scale_y_continuous(labels = percent_format()) #FORMAT Y AXIS
viz4 <- viz4 + facet_wrap(~DISTRICT, scales = 'free') #DEFINE FACET
viz4 <- viz4 + theme_few(base_family="Helvetica") #THEME SETTINGS
viz4 <- viz4 + theme(plot.title=element_text(hjust=0.5),
                     legend.position="bottom",
                     axis.text.x = element_blank(),
                     axis.ticks.x = element_blank(),
                     axis.title.x = element_blank(),
                     legend.title = element_blank()) #ADDITIONAL THEME SETTINGS
viz4 <- viz4 + ggtitle("Distribution of Property Type by District") #TITLE
viz4 <- viz4 + labs(y="District percentage") #LABELS
# viz4 <- viz4 + geom_text(aes(label = paste('€',round(MEAN_PRICE/1000,0),
#                                            'K',sep = '')),
#                  position = position_dodge(width = 0.9),
#                  vjust = 'inward',
#                  size = 3)
#viz4
ggsave("02_viz4_district_distribution.tiff", plot = viz4,
       height = 5, width = 7.5, unit='in',dpi = 600) #SAVE TO FILE
# # VIZ 5 - BUSINESS OF NEWSPAPER #####
df_busy <- df
df_busy <- ddply(df_busy, .(MONTH), summarise, NUMBER_ADVERTS = sum(COUNT))
df_busy$MONTH <- substr(capitalize(df_busy$MONTH),1,3)
df_busy$MONTH <- factor(df_busy$MONTH,
                          levels = month.abb)



viz5 <- ggplot(data = df_busy,
       aes(x=MONTH,
           y=NUMBER_ADVERTS)) + geom_bar(stat = 'identity')

# # NEXT ####
