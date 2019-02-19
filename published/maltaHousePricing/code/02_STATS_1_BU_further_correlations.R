# # # STATS 1 ####
# # map non-numeric attributes to numbers
# # # MONTH
# month_to_number <- function(XX) match(tolower(XX), tolower(month.name)) #function which converts Month to Num
# df_stats$MONTH <- sapply(df_stats$MONTH, function(XX) month_to_number(XX)) # apply on column
# # # DISTRICT
# eval(parse(text= paste("df_stats$DISTRICT[grepl('^",unique(df_stats$DISTRICT),"$',df_stats$DISTRICT)] <- '",seq(1,length(unique(df_stats$DISTRICT))),"'",sep = '', collapse = ';'))) # convert district to numeric where:
# # "Western" = 1
# # "Northen" = 2
# # "North_Harbour" = 3
# # "South_Eastern" = 4
# # "South_Harbour" = 5
# # "Gozo"         =6
# # "unknown"    =7
# # # PHONE
# df_stats$PHONE[grepl('\\D',df_stats$PHONE)] <- '0' # set unknown numbers to 0
# # # TYPE_GROUPING
# eval(parse(text= paste("df_stats$TYPE_GROUPING[grepl('^",unique(df_stats$TYPE_GROUPING),"$',df_stats$TYPE_GROUPING)] <- '",seq(1,length(unique(df_stats$TYPE_GROUPING))),"'",sep = '', collapse = ';'))) # convert TYPE_GROUPING to numeric where:
# # NA  =0
# # "commercial" = 1
# # "maisonette" = 2
# # "villa" = 3
# # "apartment" =4 
# # "house"=6
# df_stats[is.na(df_stats)]<-0
# # convert to numeric
# df_stats$PHONE <- as.numeric(df_stats$PHONE) 
# df_stats$GARAGE <- as.numeric(df_stats$GARAGE) 
# df_stats$SHELL <- as.numeric(df_stats$SHELL) 
# df_stats$FURNISHED <- as.numeric(df_stats$FURNISHED) 
# df_stats$POOL <- as.numeric(df_stats$POOL) 
# df_stats$ENSUITE <- as.numeric(df_stats$ENSUITE) 
# df_stats$DISTRICT <- as.numeric(df_stats$DISTRICT) 
# df_stats$TYPE_GROUPING <- as.numeric(df_stats$TYPE_GROUPING) 
# # COLUMN NAMES
# names(df_stats) <- capitalize(tolower(names(df_stats)))
# names(df_stats)[which(names(df_stats) == 'Type_grouping')] <- 'Property\ntype'
# # convert df to matrix
# df_stats <- data.matrix(df_stats)
# 
# 
# #compute correlation matrix
# df_stats_corr <- cor(df_stats)
# df_stats_rcorr <- rcorr(df_stats, type = c("pearson","spearman"))
# source('02_flatten_corr_matrix.R')
# flat_corr_matrix <-flatten_corr_matrix(df_stats_rcorr$r,df_stats_rcorr$P)
# 
# 
# tiff(filename = '02_corr_plot_pearson.tiff',
#      height = 8, width = 8, unit='in',res = 300)
# chart.Correlation(df_stats, histogram=TRUE, pch='.', method = 'pearson')
# dev.off()
# 
# tiff(filename = '02_corr_plot_kendall.tiff',
#      height = 8, width = 8, unit='in',res = 300)
# chart.Correlation(df_stats, histogram=TRUE, pch='.', method = 'kendall')
# dev.off()
# 
# tiff(filename = '02_corr_plot_spearman.tiff',
#      height = 8, width = 8, unit='in',res = 300)
# chart.Correlation(df_stats, histogram=TRUE, pch='.', method = 'spearman')
# dev.off()
