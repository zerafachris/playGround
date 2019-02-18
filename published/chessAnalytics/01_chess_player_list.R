function( ){
  
temp <- tempfile()
download.file("http://ratings.fide.com/download/players_list.zip",temp)
unzip(temp, "players_list_foa.txt")
unlink(temp)
remove("temp","list_players")

list_players <- readLines("players_list_foa.txt")
list_players <- list_players[-1] #remove header
list_players <- data.frame(ID   = trimws(substr(list_players,1,15)),
                              NAME = trimws(substr(list_players,16,76)),
                              FED  = trimws(substr(list_players,77,79)),
                              SEX= trimws(substr(list_players,80,81))
                              )
list_players$FORENAME <- lapply(strsplit(as.character(list_players$NAME),","),"[",2)
list_players$SURNAME <- lapply(strsplit(as.character(list_players$NAME),","),"[",1)
}