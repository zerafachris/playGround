# VIZ 2 - OPENING VERSUS RESULT ##################################################################################################
## load("KingBase2016-03_100000_KILLS.RData")
##########################################################################################################
unique(dfgames$eco)
dfgames_eco <- ddply(dfgames, c("eco"), summarize, 
                     Number = length(date),
                     White = sum(result =='1-0')/length(date) *100, 
                     Black = sum(result =='0-1')/length(date) *100, 
                     Draw = sum(result =='1/2-1/2')/length(date) *100
)
dfgames_eco_excluded <- dfgames_eco[which(!complete.cases(dfgames_eco)),1:2]
dfgames_eco <- dfgames_eco[which(complete.cases(dfgames_eco)),c(1,3,4,5)]
aa <- melt(dfgames_eco, id.var = "eco")
viz2 <- ggplot(aa, aes(x = eco, y = value, colour = variable, group = variable))
viz2 <- viz2 + geom_line() + geom_point()
viz2 <- viz2 + geom_polygon(aes(group = variable, color = variable), fill = NA)
viz2 <- viz2 + theme_tufte(base_family="Helvetica")
viz2 <- viz2 + theme(strip.text.x = element_text(size = rel(1.2)),
                     axis.text.x = element_text(size = rel(1.2)),
                     axis.ticks.y = element_blank(),
                     axis.text.y = element_blank()
)
viz2 <- viz2 + xlab("") + ylab("")
viz2 <- viz2 + labs(x=NULL,y=NULL,title="Likelyhood of winning against opening")
viz2 <- viz2 + theme(plot.title=element_text(face="bold", size=18,hjust=0.5,vjust = -1))
viz2 <- viz2 + theme(legend.margin=margin(0,0,0,-0.5,"cm"))
viz2 <- viz2 + theme(legend.title=element_blank())
viz2 <- viz2 + guides(color = guide_legend(override.aes = list(size = 5)))
viz2 <- viz2 + theme(panel.grid.major = element_line(colour="grey", size=0.5),
                     panel.grid.minor = element_line(colour="grey", size=0.5))
viz2 <- viz2 + scale_y_continuous(limits = c(10,round_any(max(aa$value), 5, f = ceiling)),
                                  expand = c(0, 0),
                                  breaks = seq(10 , 100, 10),
                                  minor_breaks = seq(10,100,5))
viz2_lables <- paste(seq(20,50,10),"%",sep = "")
viz2 <- viz2 + annotate('text',x=0.25,y=seq(21.5,51.5,10),label=viz2_lables,colour = "grey50")
source("01_coord_radar.R")
viz2 <- viz2 + coord_radar()
dfgames_eco_excluded$text <- paste(dfgames_eco_excluded$eco,dfgames_eco_excluded$Number,sep = " x")
dfgames_eco_excluded <- dfgames_eco_excluded$text
dfgames_eco_excluded <- paste(dfgames_eco_excluded,collapse = " ,")
dfgames_eco_excluded <- paste("Games excluded:",dfgames_eco_excluded,collapse = " ")

viz2 
source("01_makeFootnote.R")
makeFootnote(dfgames_eco_excluded)