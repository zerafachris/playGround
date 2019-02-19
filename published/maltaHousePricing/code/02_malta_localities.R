library(rvest)
library(dplyr)
# scrape table from wikipedia
link <- read_html("https://en.wikipedia.org/wiki/List_of_localities_in_Malta")
# localities
localities <- link %>%
  html_nodes("#mw-content-text h3+ ul li , #mw-content-text h3") %>%
  html_text()
# council
council <- link %>%
  html_nodes("h3 .mw-headline") %>%
  html_text()
# remove [edit] from text
localities <- gsub("\\[edit\\]","",localities) #REMOVE [edit]
# concatenate the council with the locality
c = 0 # COUNTER
loc = NA
for (i in seq(1,length(localities))) #OVER ALL ENTRIES IN LIST
{
  if (localities[i] %in% council) # CHECK IF ITEM IN LIST IS A council
  { #IF YES, CONCATENATE council AND SUBSEQUENCT 
    c=c+1
    loc[i] <- paste(council[c],localities[i],sep = "_")
  } else {
    loc[i] <- paste(council[c],localities[i],sep = "_")
  }
}
# CLEAN THE DATA
#head(loc)
df_localities <- data.frame(Raw_Text =loc,stringsAsFactors=F)
df_localities$localities <- localities
df_localities$council <- pbsapply(df_localities$Raw_Text,
                                   function(xx) unlist(strsplit(xx,"_"))[1] )
df_localities$localities <- pbsapply(df_localities$localities,
                                     function(xx) unlist(strsplit(xx," - "))[1])
#head(df_localities,20)
df_localities <- df_localities[c("localities","council")]
df_localities$council <- tolower(gsub(".\\(.*?\\)","",df_localities$council))
df_localities$localities <- tolower(gsub(".\\(.*?\\)","",df_localities$localities))
df_localities$council <- (gsub("ħ\'","",df_localities$council))
df_localities$localities <- (gsub("ħ\'","",df_localities$localities))
df_localities <- df_localities[which(df_localities$localities != df_localities$council),]
df_localities$council <- (gsub("^ħal ","",df_localities$council))
df_localities$localities <- (gsub("^ħal ","",df_localities$localities))
df_localities$council <- (gsub("^il-","",df_localities$council))
df_localities$localities <- (gsub("^il-","",df_localities$localities))
df_localities$council <- (gsub("^l-i","",df_localities$council))
df_localities$localities <- (gsub("^l-i","",df_localities$localities))
df_localities$council <- (gsub("^in-","",df_localities$council))
df_localities$localities <- (gsub("^in-","",df_localities$localities))
df_localities$council <- (gsub("^ir-","",df_localities$council))
df_localities$localities <- (gsub("^ir-","",df_localities$localities))
df_localities$council <- (gsub("^tal-","",df_localities$council))
df_localities$localities <- (gsub("^tal-","",df_localities$localities))
df_localities$council <- (gsub("^is-","",df_localities$council))
df_localities$localities <- (gsub("^is-","",df_localities$localities))
df_localities$council <- (gsub("^tas-","",df_localities$council))
df_localities$localities <- (gsub("^tas-","",df_localities$localities))
df_localities$council <- (gsub("^ix-","",df_localities$council))
df_localities$localities <- (gsub("^ix-","",df_localities$localities))
df_localities$council <- (gsub("^haż-","",df_localities$council))
df_localities$localities <- (gsub("^haż-","",df_localities$localities))
df_localities$council <- (gsub("^iż-","",df_localities$council))
df_localities$localities <- (gsub("^iż-","",df_localities$localities))
df_localities$council <- (gsub("^l-","",df_localities$council))
df_localities$localities <- (gsub("^l-","",df_localities$localities))
df_localities$council <- (gsub("^ta' ","",df_localities$council))
df_localities$localities <- (gsub("^ta' ","",df_localities$localities))
#unique(df_localities$council)
df_localities <- as.data.frame(sapply(df_localities, gsub, pattern ="ħ", replacement ="h"))
df_localities <- as.data.frame(sapply(df_localities, gsub, pattern ="ż", replacement ="z"))
df_localities <- as.data.frame(sapply(df_localities, gsub, pattern ="ġ", replacement ="g"))
df_localities <- as.data.frame(sapply(df_localities, gsub, pattern ="ċ", replacement ="c"))
df_localities <- as.data.frame(sapply(df_localities, gsub, pattern ="à", replacement ="a"))
df_localities <- as.data.frame(sapply(df_localities, gsub, pattern ="é", replacement ="e"))
df_localities$localities <- pbsapply(as.character(df_localities$localities),
                                     function(xx) unlist(strsplit(xx,"- "))[1])
df_localities$council <- (gsub("^haz-","",df_localities$council))
df_localities$localities <- (gsub("^haz-","",df_localities$localities))
df_localities$council <- (gsub("^had-","",df_localities$council))
df_localities$localities <- (gsub("^had-","",df_localities$localities))
df_localities$council <- (gsub("^belt ","",df_localities$council))
df_localities$localities <- (gsub("^belt ","",df_localities$localities))
df_localities$localities <- (gsub("*\\(double face zone0","",df_localities$localities))
#unique(df_localities$council)
df_localities$council[grepl(".*marsaskala*.",df_localities$council,ignore.case = FALSE )] <- "marsaskala"
df_localities$council[grepl(".*fontana*.",df_localities$council,ignore.case = FALSE )] <- "fontana"
df_localities$council[which(df_localities$council == "zebbug and marsalforn")] <- "zebbug (gozo)"
df_localities$council[which(df_localities$council == "munxar and ix-xlendi")] <- "Xlendi"
df_localities$council[which(df_localities$council == "raba")] <- "rabat (gozo)"
df_localities$council[which(df_localities$council == "rabat, malta")] <- "rabat (malta)"
# additional commands
df_localities$localities <- tolower(df_localities$localities)
df_localities$council <- tolower(df_localities$council)
xx <- c('tax-','il-','l-','ir','taz-','bir-','tac-','tat-','tad-','tar-','tad-','wied','it-', 'tan-')
xx <- paste('df_localities$localities <- (gsub("*',xx,' *","",df_localities$localities))',sep="")
for (i in seq(xx)){
  eval(parse(text=xx[i]))
}  
# remove possible duplicate localities
xx <-  df_localities %>% group_by(localities) %>% mutate(count =n())
df_localities <- df_localities[which(xx$count == 1),]
# segregate Malta & Gozo
MALTA <- unique(df_localities$council)[1:54]
GOZO <- unique(df_localities$council)[55:68]
for (i in seq(1,nrow(df_localities))){
  if (df_localities$council[i] %in% MALTA){
    df_localities$MG[i] <- "M"
  } else if (df_localities$council[i] %in% GOZO){
    df_localities$MG[i] <- "G"
  }
}
df_localities$MG_loc  <- paste(df_localities$MG,df_localities$council,sep = "_")
df_localities <- df_localities[which(df_localities$localities != 'valletta'),]
df_localities$loc_coun <- paste(df_localities$localities, df_localities$council, sep ="_")
df_localities <- df_localities[which(df_localities$loc_coun != 'xewkija_zejtun'),]
df_localities <- df_localities[which(df_localities$loc_coun != 'fgura_gharb'),]
df_localities <- df_localities[which(!(df_localities$localities %in% unique(df_localities$council))),]

xx <- unique(df_localities$council)[55:68]
df_localities$council_2 <- df_localities$council
for (i in seq(1,nrow(df_localities))){ # i <-10
  if  (df_localities$council_2[i] %in% xx){
    df_localities$council_2[i] <- paste("gozo", df_localities$council_2[i], sep = " ")
  }
}
df_localities$council_2 <- gsub(' \\([a-z]*\\)$','',df_localities$council_2)
  


# write.csv(df_localities, file = "02_localities_wiki.csv")
# dput(unique(df_localities), file = "list.txt")
df_localities <- subset(df_localities,select = -c(loc_coun))
save(df_localities,file= "02_malta_localities.RData")


unique(df_localities$localities)
unique(df_localities$council)
unique(df_localities$council_2)
