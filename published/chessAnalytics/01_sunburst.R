source("01_opening_functions.R")
dfgames$move_1 <- pbsapply(dfgames$pgn, function(x) move_1(x))
dfgames$move_2 <- pbsapply(dfgames$pgn, function(x) move_2(x))
dfgames$move_3 <- pbsapply(dfgames$pgn, function(x) move_3(x))
dfgames$move_4 <- pbsapply(dfgames$pgn, function(x) move_4(x))

library(ggsunburst)
library(treemap)
library(data.tree)
dfgames_opening <- ddply(dfgames, c("move_1","move_2"), summarize, 
                         n = length(date))
dfgames_opening$Path_String <- paste("Start",
                                     dfgames_opening$move_1,
                                     dfgames_opening$move_2,
                                     sep = "/")

opening <- as.Node(dfgames_opening,mode = "table", pathName = "Path_String", pathDelimiter = "/", colLevels = NULL,na.rm = TRUE)
print(opening,"n")
opening_nw <- ToNewick(opening,heightAttribute = "n")

library(ggsunburst)
sb <- sunburst_data(opening_nw)
nw_print(opening_nw)
sunburst(sb)
icicle(sb)
ggtree(sb, polar = TRUE)