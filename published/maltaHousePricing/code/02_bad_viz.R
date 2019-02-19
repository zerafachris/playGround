## REINTERPRET BAD VIZ ####
# # Clear variables ####
rm(list=ls(all=TRUE))
# PACKAGES
require(gdata)
library(ggplot2)
library(reshape2)
library(ggthemes)
library(scales)

df <-  read.xls ("01_bad_viz.xlsx", sheet = 1, header = TRUE)


df_values <- melt(df,id.vars = c('Year','MALTA'))


bad_viz <- ggplot() + geom_bar(data=df_values,aes(x=Year,y=value,fill = variable, color=variable),stat = 'identity',position="dodge") + geom_line(data=df_values,aes(x=Year,y=MALTA),size = 1,color='blue') + theme_gdocs(base_family = 'Helvetica') + ylab('Percentage (%)') + ggtitle('Chart 2.3 At-risk-of-poverty rates by region and year') +  theme(legend.position="bottom",legend.title=element_blank(),legend.direction = 'horizontal') + theme(plot.background = element_blank())+ annotate('text',x=2012,y=19,label = 'Malta, Gozo and Comino combined',color = 'blue') + annotate('segment',x = 2010.3, xend = 2010.75,y = 19, yend = 19,colour = "blue",size = 1) + scale_y_continuous(limits=c(10,20),oob = rescale_none)
bad_viz <- bad_viz + theme(panel.grid.major.x = element_blank())
bad_viz <- bad_viz + annotate("rect", xmin = 2010.25, xmax = 2013.2,
                   ymin = 18.5, ymax = 19.5,
                   alpha = .2)

bad_viz
ggsave("01_bad_viz_edit.tiff", plot = bad_viz,
       height = 5, width = 7, unit='in',dpi = 600)
