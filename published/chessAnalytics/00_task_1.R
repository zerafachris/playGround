# # TASK 1 - VISUALIZATIONS ####

# # Clear variables ####
rm(list=ls(all=TRUE))

# # PACKAGES ####
library(stringr)
library(ggplot2)
library(RColorBrewer)
library(reshape2)
library(ggthemes)
library(zoo)
library(plyr)
# library(pbapply)
library(scales)

# # CUSTOM FUNCTIONS ####
source("01_Rolling_Avg.R")

# # PREP PGN PARSER #####
# ## Transformation from PGN to R Data
# # This takes approx. 2-3 HOURS
# # If you require to transform the data again, use the function 01_pgn_parser_function code below:
# # ZIP <- "KingBase2016-03-pgn.zip"
# # source("01_pgn_parser_function.R")
# # pgn_parser(ZIP)
# # OTHERWISE, data can be loaded by using:
# load("KingBase2016-03.RData")
# # create sample dataset of 100,000 randomly selected entries
# # set.seed(55)
# # SS <- sample(seq(1,nrow(dfgames)),100000)
# # dfgames <- dfgames[SS,]
# # save(dfgames, file = "KingBase2016-03_100000.RData")
# # load("KingBase2016-03_100000.RData")

# # PREP NUMBER OF MOVES, TAKES, CHECKS, CHECKMATES #####
# # number of moves, kills, checks, checkmates
# dfgames$moves <- str_count(dfgames$pgn, "\\S+")-1
# dfgames$kills <- str_count(dfgames$pgn,"x")
# # dfgames$checkmates <- str_count(dfgames$pgn,"#")
# # dfgames$checks <- str_count(dfgames$pgn,"\\+")

# # PREP VIZ 1 - HEATMAP WITH KILL ZONE ######
# # function which returns cells where capture occurred
# source("01_captures.R")
# dfgames$captures <- unlist(pblapply(dfgames$pgn, FUN = function (xx) {captures(xx)}))
# # load("KingBase2016-03_CAPTURES.RData")
# # split cell kills into different columns within dataframe
# board <- expand.grid(X=letters[1:8],Y=seq(1,8))
# CELL = paste(board$X,board$Y,sep = "")
# CELL_KILLS <- data.frame(dfgames$captures, do.call(rbind, strsplit(dfgames$captures, split = "_", fixed= TRUE)))
# CELL_KILLS <- CELL_KILLS[-1]
# colnames(CELL_KILLS) <- CELL
# remove(board)
# save(CELL_KILLS, file = "KingBase2016-03_CELL_KILLS.RData")
# load("KingBase2016-03_CAPTURES.RData")
# load("KingBase2016-03_CELL_KILLS.RData")
# convert factors to numeric
# for (i in seq(1,length(CELL_KILLS)) ){
#   print(i)
#   CELL_KILLS[i] <- pbsapply(CELL_KILLS[i], function(XX) as.numeric(as.character(XX)))
# }
# sapply(CELL_KILLS,mode)
# # check that number of kills match
# sum(CELL_KILLS)
# sum(dfgames$kills)
# CELL_KILLS_MAT <- melt(t(matrix(colSums(CELL_KILLS), nrow = 8,byrow = TRUE)))
# CELL_KILLS_MAT$PERCENT <- (CELL_KILLS_MAT$value/ sum(dfgames$kills))*100
# #check percent calculation is correct
# sum(CELL_KILLS_MAT$PERCENT)
# # save(CELL_KILLS_MAT, file = "KingBase2016-03_VIZ1.RData")

# PLOT VIZ 1 ######
print('VIZ 1 - HEATMAP')
# PLOT heatmap with the number of takes occuring within each cell of the chess board. Values are displayed as a percentage and count.
load("KingBase2016-03_VIZ1.RData") 
viz1 <- ggplot(CELL_KILLS_MAT, aes(x = Var1, y = Var2, fill = value))
# # define tiles for heatmap
viz1 <- viz1 + geom_tile(color="white", size=0.1)
# # choose fill palette
viz1 <- viz1 + scale_fill_distiller(palette = "Spectral")
# # labels
viz1 <- viz1 + coord_equal() + labs(x=NULL, y=NULL,
                                    title="Kill zone across the chess board",
                                    subtitle=" Percent\\Count (million)") 
# # axis settings
viz1 <- viz1 + scale_x_continuous(breaks = 1:8,
                                  labels = letters[1:8],
                                  sec.axis = dup_axis(),
                                  expand=c(0,0))
# # axis settings
viz1 <- viz1 + scale_y_continuous(breaks = 1:8, 
                                  labels = 1:8, 
                                  sec.axis = dup_axis(),
                                  expand=c(0,0))
# # predefined theme which beautifies plot
viz1 <- viz1 + theme_tufte(base_family="Helvetica")
viz1 <- viz1 + theme(axis.ticks=element_blank())+ theme(axis.text=element_text(size=14))
viz1 <- viz1 + theme(legend.position="none")
# # define annotations
viz1 <- viz1 + geom_text(aes(label = round(value/1000000, 2)),size=2.5,nudge_y = -0.25)
viz1 <- viz1 + geom_text(aes(label = paste(round(CELL_KILLS_MAT$PERCENT,2),"%",sep=""))
                         ,size=3.5,nudge_y = 0)
# # other settings
viz1 <- viz1 + theme(plot.title=element_text(face="bold", size=18,hjust=0.5,vjust = -1))
viz1 <- viz1 + theme(plot.subtitle=element_text(face="italic", size=12,hjust=0.5))
viz1
ggsave("01_viz1.tiff",plot = viz1,
       height = 5, width = 5, unit='in',dpi = 600)

# PREP VIZ 2 - TAKES PER MATCH OVER TIME  #####
# # load("KingBase2016-03_CAPTURES.RData")
# # remove matches without a date
# dfgames_takes <- dfgames[!is.na(dfgames$date),]
# # create Year_Month column
# dfgames_takes$YYMM <- str_sub(dfgames_takes$date,1,7)
# # summarize the dataset with Mean, Standard deviation and 95% confidence interval
# dfgames_takes <- ddply(dfgames_takes, .(YYMM),
#                        summarize,
#                        MEAN = mean(kills),
#                        n = length(kills),
#                        SD = sd(kills),
#                        ERROR =  qt((1+0.95)/2,df=n-1)*SD/sqrt(n))
# # remove dates with less than 10 occurances
# dfgames_takes <- dfgames_takes[which(dfgames_takes$n >= 10),]
# # create column with 95% C.I Upper and Lower Limit
# dfgames_takes$U_LIMIT = dfgames_takes$MEAN + dfgames_takes$ERROR
# dfgames_takes$L_LIMIT = dfgames_takes$MEAN - dfgames_takes$ERROR
# # retain complete cases only
# dfgames_takes <- dfgames_takes[complete.cases(dfgames_takes),]
# # create ID used for labelling
# dfgames_takes$ID <-seq.int(nrow(dfgames_takes))
# # apply a 5-pt rolling meadian filter to smooth across outliers
# source("01_Rolling_Avg.R")
# dfgames_takes$UL_MED <- rollmedianR(dfgames_takes$U_LIMIT,5)
# dfgames_takes$LL_MED <- rollmedianR(dfgames_takes$L_LIMIT,5)
# # save(dfgames_takes, file = "KingBase2016-03_TAKES.RData")

# PLOT VIZ 2 #####
print('VIZ 2 - NUMBER OF TAKES PER MATCH OVER TIME')
# # create plot wit number of takes per match over time, together with 95% confidence interval.
load("KingBase2016-03_TAKES.RData")
viz2 <- ggplot(dfgames_takes, aes(x = ID,y = rollmedianR(MEAN,5)))
# C.I. interval
viz2 <- viz2 + geom_ribbon(aes(ymin=UL_MED, ymax=LL_MED,fill = "95% Conf. Interval")) 
# Mean
viz2 <- viz2 + geom_line(size = 0.5, aes(colour = "Mean take per match"))
# Upper Limit
viz2 <- viz2 + geom_line(aes(ID,UL_MED),linetype='dashed')
# Lower Limit
viz2 <- viz2 + geom_line(aes(ID,LL_MED),linetype='dashed')
viz2 <- viz2 + theme_tufte(base_family="Helvetica")
viz2 <- viz2 + coord_cartesian(xlim=c(31,max(dfgames_takes$ID)),
                               ylim=c(15,18))
# create Year labels to be plotted on X axis
dfgames_takes$YEAR <- str_sub(dfgames_takes$YYMM,1,4)
viz2_ticks <- ddply(dfgames_takes, .(YEAR), summarize, NUM = min(ID),MAX = max(ID))
viz2 <- viz2 + theme(axis.text.x = element_text(angle = 90, hjust = 1))
viz2 <- viz2 + scale_x_continuous(breaks = viz2_ticks$NUM, labels = viz2_ticks$YEAR)
viz2 <- viz2 + labs(x=NULL, y="Takes per game",title="Takes per match post-1995")
viz2 <- viz2 + theme(plot.title=element_text(face="bold", size=18,hjust=0.5,vjust = -1))
viz2 <- viz2 + scale_y_continuous(breaks = seq(13,18,1), labels = seq(13,18,1)
                                  ,expand=c(0,0))
viz2 <- viz2 + scale_colour_manual("",values="blue") + scale_fill_manual("",values="#FF9999")
viz2 <- viz2 + theme(legend.position="bottom",
                      legend.direction="horizontal",
                      legend.box="horizontal")
viz2
ggsave("01_viz2.tiff", plot = viz2,
       height = 5, width = 7.5, unit='in',dpi = 600)

# # PREP VIZ 3 - LIKELYHOOD OF WINNING DEPENDING ON COLOUR #####
# # load("KingBase2016-03_CAPTURES.RData")
# # white win: 1-0
# # black win: 0-1
# # draw
# source("01_Rolling_Avg.R")
# # remove matches without dates
# dfgames_date <- dfgames[!is.na(dfgames$date),]
# # create Year_Month header to group on
# dfgames_date$YYMM <- str_sub(dfgames_date$date,1,7)
# # retain valid results only
# dfgames_date <- dfgames_date[which(dfgames_date$result != "*"),]
# dfgames_date <- dfgames_date[!is.na(dfgames_date$result),]
# # summarise the results
# dfgames_date <- ddply(dfgames_date, c("YYMM"), summarize,
#                       n = length(date),
#                       #WhiteNum = sum(result =='1-0'),
#                       #BlackNum = sum(result =='0-1'),
#                       #DrawNum = sum(result =='1/2-1/2'),
#                       White = sum(result =='1-0')/length(date),
#                       Black = sum(result =='0-1')/length(date),
#                       Draw = sum(result =='1/2-1/2')/length(date))
# # retain dates which had more than 10 results
# dfgames_date <- dfgames_date[which(dfgames_date$n >= 10),]
# # create dataframes with Win, Draw and Black results to allow for plotting of Stacked Column Chart.
# # Values have been smoothed with a 5-py median filter to remove outliers
# df_WIN <- dfgames_date
# df_WIN$ID <-seq.int(nrow(dfgames_date))
# df_WIN <- df_WIN[c("ID","White","Black","Draw")]
# df_DRAW <- data.frame( ID = df_WIN$ID,
#                     Draw = rollmedianR(df_WIN$Draw,5))
# df_DRAW$Draw <-rollmedianR(df_DRAW$Draw,3)
# df_BLACK <- data.frame( ID = df_WIN$ID,
#                      Black = rollmedianR(df_WIN$Black,5))
# df_BLACK$Black<-rollmedianR(df_BLACK$Black,3)
# df_WIN <- melt(df_WIN, id.var = "ID")
# df_DRAW <- melt(df_DRAW, id.var = "ID")
# df_BLACK <- melt(df_BLACK, id.var = "ID")
# df_BLACK$value <- df_BLACK$value + df_DRAW$value
# # save(dfgames_date,viz2_ticks, df_WIN, df_BLACK, df_DRAW, file = "KingBase2016-03_VIZ3.RData")

# PLOT VIZ 3 #####
print('VIZ 3 - LIKELYHOOD OF WINNING POST-1995')
load("KingBase2016-03_VIZ3.RData")
viz3 <- ggplot(data = df_WIN, aes(x = ID, y = value))
viz3 <- viz3 + geom_area(aes(fill= variable), position = 'stack')  
viz3 <- viz3 + theme_tufte(base_family="Helvetica")
viz3 <- viz3 + theme(axis.text.x = element_text(angle = 90, hjust = 1))
viz3 <- viz3 + scale_x_continuous(breaks = viz2_ticks$NUM,
                                  labels = viz2_ticks$YEAR)
viz3 <- viz3 + scale_y_continuous(labels=percent)
viz3 <- viz3 + labs(x=NULL,
                    y=NULL,
                    title="Likelyhood of winning post-1995")
viz3 <- viz3 + theme(plot.title=element_text(face="bold", size=18,hjust=0.5,vjust = -1))
viz3 <- viz3 + guides(fill=guide_legend(title=NULL))
viz3 <- viz3 + theme(legend.position="bottom")
viz3 <- viz3 + coord_cartesian(xlim=c(43,max(df_WIN$ID)))
# # determine 3 locations where to annotate the percentage of matches
# levels(cut_number(seq(43,max(df_WIN$ID)),3))
# subset of 5: c(67,116,164,213,261)
# subset of 3: c(84, 164, 245)
viz3_label <- df_WIN[which(df_WIN$ID %in% c(84, 164, 245)),]
viz3_label$y <- NA
viz3_label <- within(viz3_label, y[variable == "White"] <- 0.36/2)
viz3_label <- within(viz3_label, y[variable == "Black"] <- .36+(.29/2))
viz3_label <- within(viz3_label, y[variable == "Draw"] <- .36+.29+(.35/2))
viz3_label$value <- paste(round(viz3_label$value*100,1),"%",sep = "")
viz3 <- viz3 + annotate('text',
                x = rev(viz3_label$ID),
                y = viz3_label$y,
                label = rev(viz3_label$value))
viz3
ggsave("01_viz3.tiff", plot = viz3,
       height = 5, width = 7, unit='in',dpi = 600)

# PREP VIZ 4 - GAME LENGTH FREQUENCY #####
# variable for plotting was already computed as moves in the initial prep

# PLOT VIZ 4 #####
print('VIZ 4 - NUMMER OF PLYS')
load("KingBase2016-03_CAPTURES.RData")
# # 1 move is defined a 1 ply.
# # retain matched with moves less than 200
viz4 <- ggplot(dfgames[which(dfgames$moves <= 200),], aes(x = moves))
viz4 <- viz4 + geom_histogram(binwidth = 1,aes(fill = ..count..))
viz4 <- viz4 + theme_tufte(base_family="Helvetica")
viz4 <- viz4 + labs(x="Number of Plys",
                    y="Frequency",
                    title="Game length (max. 200-plys)")
viz4 <- viz4 + theme(plot.title=element_text(face="bold", size=18,hjust=0.5,vjust = 0))
# # annotate with the mean
viz4 <- viz4 + annotate("text",
                        x = mean(dfgames$moves) + 3,
                        y = Inf,
                        label = paste("Mean:",round(mean(dfgames$moves),1),sep = " "),
                        vjust=1, hjust=0)
viz4 <- viz4 + theme(axis.line.x = element_line(color="black"),
                     axis.line.y = element_line(color="black"))
viz4 <- viz4 + geom_vline(xintercept = mean(dfgames$moves),
                          color = 'black',
                          linetype = 2)
viz4 <- viz4 + guides(fill=guide_legend(title="Frequency"))
viz4 <- viz4 + theme(legend.justification=c(1,1),
                     legend.position=c(1, 1))
# # change fill parameters
viz4 <- viz4 + scale_fill_distiller(palette = "Spectral",
                                    breaks=pretty_breaks(n = 10),
                                    direction = -1)
viz4 <- viz4 + scale_x_continuous(breaks = pretty_breaks(n = 10)) 
viz4 <- viz4 + scale_y_continuous(breaks = pretty_breaks(n = 10))
XX <- dfgames[which(dfgames$moves <= 200),] #
viz4 <- viz4 + geom_vline(xintercept = quantile(XX$moves, 0.25),
                  color = 'blue',
                  linetype = 2) + annotate("text",
                                           x = quantile(XX$moves, 0.25) - 3,
                                           y = 25000,
                                           color ='blue',
                                           label = paste("Lower Q:",round(quantile(XX$moves, 0.25),1),sep = " "),hjust=1)
viz4 <- viz4 + geom_vline(xintercept = quantile(XX$moves, 0.75),color = 'blue',
                          linetype = 2) + annotate("text",
                                                   x = quantile(XX$moves, 0.75) + 3,
                                                   y = 25000,
                                                   color ='blue',
                                                   label = paste("Upper Q:",round(quantile(XX$moves, 0.75),1),sep = " "),hjust=0)
viz4  
ggsave("01_viz4.tiff", plot = viz4,
       height = 5, width = 7, unit='in',dpi = 600)

# THE END ####
# BYE BYE ####
print('TASK 1A - Done')
print('TASK 1A - BYE BYE')