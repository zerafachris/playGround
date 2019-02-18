# VIZ 3 - LENGTH OF MATCHES OVER TIME ################################################################################################
dfgames_date <- dfgames[!is.na(dfgames$date),]
dfgames_date$YYMM <- substr(dfgames_date$date,1,7)
dfgames_date <- dfgames_date[order(dfgames_date$date),]
dfgames_date <- ddply(dfgames_date, .(YYMM), summarize, MEAN = mean(moves), n = length(moves), SD = sd(moves), ERROR =  qt((1+conf_level)/2,df=n-1)*SD/sqrt(n),U_LIMIT = MEAN + ERROR,L_LIMIT = MEAN - ERROR)
dfgames_date <- dfgames_date[complete.cases(dfgames_date),]
dfgames_date$ID <-seq.int(nrow(dfgames_date))
source("Rolling_Median.R")
dfgames_date$UL_MED <- rollmedianR(dfgames_date$U_LIMIT,5)
dfgames_date$LL_MED <- rollmedianR(dfgames_date$L_LIMIT,5)
viz3 <- ggplot(dfgames_date, aes(x = ID,y = rollmedianR(MEAN,5)))
viz3 <- viz3 + geom_ribbon(aes(ymin=UL_MED, ymax=LL_MED,fill = "red")) 
viz3 <- viz3 + geom_line(col = 'white',size = 1)
viz3 <- viz3 + geom_line(aes(ID,UL_MED),linetype='dashed')
viz3 <- viz3 + geom_line(aes(ID,LL_MED),linetype='dashed')
viz3 <- viz3 + theme_tufte(base_family="Helvetica")
viz3 <- viz3 + coord_cartesian(ylim=c(60,95),xlim=c(34,275))
dfgames_date$YEAR <- substr(dfgames_date$YYMM,1,4)
viz3_ticks <- ddply(dfgames_date, .(YEAR), summarize, NUM = min(ID),MAX = max(ID))
viz3 <- viz3 + theme(axis.text.x = element_text(angle = 90, hjust = 1))
viz3 <- viz3 + scale_x_continuous(breaks = viz3_ticks$NUM, labels = viz3_ticks$YEAR,expand=c(0,0))
viz3 <- viz3 + theme(legend.position="none")
viz3 <- viz3 + labs(x=NULL, y="Plays per game",title="Mean ± 95% confidence interval\nfor plays per game",
                    subtitle="(2 plays = 1 move)")
viz3 <- viz3 + theme(plot.title=element_text(face="bold", size=18,hjust=0.5,vjust = -1))
viz3 <- viz3 + theme(plot.subtitle=element_text(face="italic", size=12,hjust=0.5))
viz3 <- viz3 + scale_y_continuous(breaks = seq(60,95,5), labels = seq(60,95,5),expand=c(0,0))
viz3 <- viz3 + theme(panel.grid.major = element_line(colour = "grey",size = 0.5))
viz3
remove(viz3_ticks,dfgames_date)