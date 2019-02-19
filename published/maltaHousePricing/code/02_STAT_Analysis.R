## STAT ANALYSIS OF DATA ###############################################
print('STAT ANALYSIS OF DATA')
# rm(list=ls(all=TRUE))
load('02_3_tm_ready.RData')
# LIBRARIES
library(Hmisc)

library('data.table')
library('testthat')
library('gridExtra')
library('corrplot')
library('GGally')
library('ggplot2')
library('e1071')
library('dplyr')
library(nortest)
library(scales)
library(grid)

source('02_DO_PLOTS.R') #functions for quick plots

# # STATS ####
df_stats <- df
# STATS - Data Prep #####
# convert to numeric 
df_stats$PHONE <- as.numeric(df_stats$PHONE)
df_stats$GARAGE <- as.numeric(df_stats$GARAGE)
df_stats$SHELL <- as.numeric(df_stats$SHELL)
df_stats$FURNISHED <- as.numeric(df_stats$FURNISHED)
df_stats$POOL <- as.numeric(df_stats$POOL)
df_stats$ENSUITE <- as.numeric(df_stats$ENSUITE)
df_stats$TYPE_GROUPING <- capitalize(df_stats$TYPE_GROUPING)
df_stats$DAY_NUM <- as.numeric(df_stats$DAY_NUM)
df_stats$YEAR <- as.numeric(df_stats$YEAR)
df_stats$BEDROOM <- as.numeric(df_stats$BEDROOM)
df_stats$BATHROOM <- as.numeric(df_stats$BATHROOM)
df_stats$QUARTER <- as.numeric(df_stats$QUARTER)
df_stats$COUNT <- as.numeric(df_stats$COUNT)
# SOME SETTINGS ON THE FACTORS
df_stats$MONTH <- factor(df_stats$MONTH,
                          levels = tolower(month.name))
var_char <- names(df_stats)[which(sapply(df_stats, is.character))] # character variables
var_char <- c(var_char, 'MONTH') #add Month to Character
print(paste('Number of Character Variables:',length(var_char), sep = ' '))
var_num <- names(df_stats)[which(sapply(df_stats, is.numeric))] # numeric variables
print(paste('Number of Numeric Variables:',length(var_num), sep = ' '))
df_stats_char <- df_stats[,which(names(df_stats) %in% var_char)] #create variable with Character list
df_stats_num <- df_stats[,which(names(df_stats) %in% var_num)] #create variable with NUMERIC list
# # STATS - ANALYSIS ON CATEGORICAL FUNCTIONS ####
tiff(filename = '02_STATS_CAT_1.tiff',
           height = 8, width = 8, unit='in',res = 300)
doPlots(df_stats_char, fun = plotHist, ii = 1:6, ncol = 2)    
dev.off()
# STATS - further look at LOCALITY ####
df_loc <- as.data.frame(table(df_stats_char$LOCALITY)) #CREATA NEW DF
df_loc <- head(df_loc[order(df_loc$Freq,decreasing = TRUE),],40) #NEW ORDER
names(df_loc)[1] <- 'LOCALITY' #RENAME
df_loc$LOCALITY <- factor(df_loc$LOCALITY,
                       levels = df_loc$LOCALITY) #REORDER
LOC1 <- ggplot(data=df_loc, aes(x=LOCALITY,y=Freq)) + geom_bar(stat = 'identity') + theme_light() + xlab(label = 'LOCALITY') + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
LOC1
ggsave("02_STATS_CAT_2_locality.tiff", plot = LOC1,
       height = 5, width = 7.5, unit='in',dpi = 600) #SAVE TO FILE
# further look at TYPE ####
df_type <- as.data.frame(table(df_stats_char$TYPE)) #new df
df_type <- df_type[order(df_type$Freq,decreasing = TRUE),] #REORDER
names(df_type)[1] <- 'TYPE' #RENAME
df_type$TYPE <- factor(df_type$TYPE,
                       levels = df_type$TYPE) #LEVELS
TYPE1 <- ggplot(data=df_type, aes(x=TYPE,y=Freq)) + geom_bar(stat = 'identity') + theme_light() + xlab(label = 'TYPE') + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
TYPE1
ggsave("02_STATS_CAT_3_type.tiff", plot = TYPE1,
       height = 5, width = 7.5, unit='in',dpi = 600) #SAVE TO FILE
# # STATS - ANALUYSIS ON NUMERICAL FUNCTIONS ####
tiff(filename = '02_STATS_NUM_1_qplots.tiff',height = 8, width = 8, unit='in',res = 300)
suppressWarnings(doPlots(df_stats_num, fun = plotDen, ii = 1:6, ncol = 2)) #QUICK PLOTS
dev.off()
tiff(filename = '02_STATS_NUM_2_qplots.tiff',height = 8, width = 8, unit='in',res = 300)
suppressWarnings(doPlots(df_stats_num, fun = plotDen, ii = 7:13, ncol = 2))
dev.off()
# STATS - FURTHER look at price ####
df_price <- as.numeric(df$PRICE)
tiff(filename = '02_STATS_NUM_3_price_1.tiff',height = 8, width = 8, unit='in',res = 300)
def.par <- par(no.readonly = TRUE) # save original settings for par
par(mfrow=c(2,1))
par(mar = c(3, 3, 1, 1), oma = c(1, 1, 1, 1))
# Histogram with Box-Whisker ####
h <- hist(df_price, plot = FALSE)
xfit<-seq(min(df_price),max(df_price),length=100)
yfit<-yfit<-dnorm(xfit,mean=mean(df_price),sd=sd(df_price))
yfit <- yfit*diff(h$mids[1:2])*length(df_price)
plot (h, axes = TRUE, main = "Further look into Price")
lines(xfit, yfit, col="blue", lwd=2)
leg1 <- paste("Mean = €", round(mean(df_price), digits = 0))
leg2 <- paste("SD = €", round(sd(df_price),digits = 0)) 
legend(x = "topright", c(leg1,leg2), bty = "n")
## box-whisker plot
boxplot(df_price, horizontal = TRUE)
leg1 <- paste("Median = €", round(median(df_price), digits = 4))
lq <- quantile(df_price, 0.25)
leg2 <- paste("25th quantile =  €", round(lq,digits = 4)) 
uq <- quantile(df_price, 0.75)
leg3 <- paste("75th quantile = €", round(uq,digits = 4)) 
legend(x = "top", leg1, bty = "n")
legend(x = "bottom", paste(leg2, leg3, sep = "; "), bty = "n")
## reset the graphics display to default
par(def.par)
dev.off()
# Histogram & log(PRICE) ####
hist_1 <- suppressWarnings(ggplot(df, aes(x=PRICE)) + geom_histogram(col = 'white') + theme_light() +scale_x_continuous(labels = comma)) #normal histogram
hist_2 <- suppressWarnings(ggplot(df, aes(x=log(PRICE+1))) + geom_histogram(col = 'white')+ theme_light() +scale_x_continuous(labels = comma)) #log 0 is undefined
tiff(filename = '02_STATS_NUM_4_price_2.tiff',height = 8, width = 8, unit='in',res = 300)
grid.newpage()
grid.draw(rbind(ggplotGrob(hist_1),
                ggplotGrob(hist_2),
                size = "last"))
dev.off()
# # STATS - CORRELATIONS MATRIX ####
# map non-numeric attributes to numbers
# STATS - Convert MONTH ####
month_to_number <- function(XX) match(tolower(XX), tolower(month.name)) #function which converts Month to Num
df_stats$MONTH <- sapply(df_stats$MONTH, function(XX) month_to_number(XX)) # apply on column
# STATS - Convert DISTRICT ####
eval(parse(text= paste("df_stats$DISTRICT[grepl('^",unique(df_stats$DISTRICT),"$',df_stats$DISTRICT)] <- '",seq(1,length(unique(df_stats$DISTRICT))),"'",sep = '', collapse = ';'))) # convert district to numeric where:
# "Western" = 1
# "Northen" = 2
# "North_Harbour" = 3
# "South_Eastern" = 4
# "South_Harbour" = 5
# "Gozo"         =6
# "unknown"    =7
# STATS - Convert PHONE ####
df_stats$PHONE[grepl('\\D',df_stats$PHONE)] <- '0' # set unknown numbers to 0
# STATS - Convert TYPE_GROUPING ####
eval(parse(text= paste("df_stats$TYPE_GROUPING[grepl('^",unique(df_stats$TYPE_GROUPING),"$',df_stats$TYPE_GROUPING)] <- '",seq(1,length(unique(df_stats$TYPE_GROUPING))),"'",sep = '', collapse = ';'))) # convert TYPE_GROUPING to numeric where:
# NA  =0
# "commercial" = 1
# "maisonette" = 2
# "villa" = 3
# "apartment" =4
# "house"=6
df_stats[is.na(df_stats)]<-0
# STATS - convert to numeric factors ####
df_stats$PHONE <- as.numeric(df_stats$PHONE)
df_stats$DISTRICT <- as.numeric(df_stats$DISTRICT)
df_stats$TYPE_GROUPING <- as.numeric(df_stats$TYPE_GROUPING)
# subset the data
df_stats <- subset(df_stats, select = -c(LOCALITY,TYPE,MALTA_GOZO,DATE))
df_stats <- subset(df_stats, select = -c(MONTH,DAY_NUM,YEAR))
# rename COLUMN NAMES
names(df_stats) <- capitalize(tolower(names(df_stats)))
names(df_stats)[which(names(df_stats) == 'Type_grouping')] <- 'PropertyType'
df_stats <- data.matrix(df_stats) # convert df to matrix
df_stats_corr <- cor(df_stats) #compute correlation matrix
p.mat <- cor.mtest(df_stats) # matrix of the p-value of the correlation
col <- colorRampPalette(c("#7F0000","red","#FF7F00","yellow", 
                           "cyan", "#007FFF", "blue","#00007F")) #define colour bar
cex.before <- par("cex") # save settings before cor
par(cex = 0.8) #text size
tiff(filename = '02_STATS_5_corr_mat.tiff',height = 8, width = 8, unit='in',res = 300)
corrplot(df_stats_corr, insig = "blank", method = "color",
         addCoef.col="black", 
         order = "FPC", tl.cex = 1/par("cex"),
         cl.pos="b",cl.cex = 1/par("cex"), addCoefasPercent = FALSE,
         col=col(100)) #correlation plot
dev.off()
par(cex = cex.before)
# STATS - analysis of high correlation ####
corr_high_bound <- 0.05 # high corr
corr_low_bound <- -.02 # low corr
df_stats_highcorr <- c(names(df_stats_corr[,'Price'])[which(df_stats_corr[,'Price'] > corr_high_bound)],names(df_stats_corr[,'Price'])[which(df_stats_corr[,'Price'] < corr_low_bound)]) #pick out bounds
df_stats_corr_bound <- df_stats[,which(colnames(df_stats) %in% df_stats_highcorr)] #select high corr
tiff(filename = '02_STATS_6_scatters_high_corr.tiff',height = 8, width = 8, unit='in',res = 300) 
doPlots(as.data.frame(df_stats_corr_bound), fun = plotCorr, ii = 1:6)
dev.off()

## xgboosting ####
