pgn_parser <- function(ZIP){
# Original package can be found here: https://github.com/jbkunst/chess-db from script 01_pgn_parser.R
####
  # Function which parses a zip file containing chess PGN data; and return:
  # Event: the name of the tournament or match event.
  # Site: the location of the event. This is in City, Region COUNTRY format, where COUNTRY is the three-letter International Olympic Committee code for the country. An example is New York City, NY USA.
  # Date: the starting date of the game, in YYYY.MM.DD form. ?? is used for unknown values.
  # Round: the playing round ordinal of the game within the event.
  # White: the player of the white pieces, in Lastname, Firstname format.
  # Black: the player of the black pieces, same format as White.
  # Result: the result of the game. This can only have four possible values: 1-0 (White won), 0-1 (Black won), 1/2-1/2 (Draw), or * (other, e.g., the game is ongoing).
  # 
  #   Data will be exported to "KingBase2016-03.RData"
  #   This can be loaded into R by executing:
  #   load("KingBase2016-03.RData") 
  #
  # Function works as follows:
  #   [1] Parses a .zip file, 
  #   [2] Creates a directory named data-raw, 
  #   [3] Unzips the data inside data-raw,
  #   [4] Processed the PGN game data as follows:
  #       [a] Identifies where individual games start and finish within a single PGN
  #       [b] Splits a single game into Header Components which relate to the EVENT, SITE, DATE, ROUND, COLOUR OF PAWNS, RESULTS, SKILL LEVEL (ELO), OPENING MOVE (ECO) and MOVES THROUGHOUT THE GAME (PGN)
  #       [c] Repeats for every game, every PGN file
####
  
#### Packages
library("magrittr")
library("plyr")
library("dplyr")
library("readr")
library("stringr")

#### Parameters
#ZIP          <- "KingBase2016-03-pgn.zip"
PATH_RAWDATA  <- "data-raw"
PATH_WORKING  <- "data_WORKING"
VERBOSE       <- TRUE

#### Folders
l_ply(c(PATH_RAWDATA, PATH_WORKING), function(x){
  unlink(x, recursive = TRUE)
  file.remove(x)
  dir.create(x)
})

##### UNZIP ZIP FILE INTO RAW DATA FILE
raw_data_path <- paste(getwd(),"/data-raw",sep ='')
unzip(ZIP,exdir = raw_data_path )
print('Complete unzipping of file')

#### PROCESS THE GAME DATA
files_pgn <- dir(PATH_RAWDATA, pattern = ".*pgn$", full.names = TRUE)
files_pgn
load_times <- ldply(files_pgn, function(f){ # f <- sample(files_pgn, size = 1)
  t0 <- Sys.time() # set start time
  if (VERBOSE) print(f)
  flines <- readLines(f) # Read in the lines individually
  no_info <- which(str_length(flines) == 0) #identify empty lines
  no_info <- no_info[seq(length(no_info)) %% 2 == 0] # go to the 2nd empty row
  no_info <- c(0, no_info) # return the location of 2nd empty row
  # create data frame which contains the pairs for the start-end line for individual games
  df_cuts <- data_frame(from = head(no_info, -1) + 1,to = tail(no_info, -1) - 1)
  # apply the function row to the individual games idenified by the bounds in df_cut
  df_games <- ldply(seq(nrow(df_cuts)), function(row){ # row <- 5
    pgn <- flines[seq(df_cuts[row, ]$from, df_cuts[row, ]$to)] # this is one game
    ## select the game moves only
    pgn2 <- pgn[seq(which(pgn == "") + 1, length(pgn))] %>% 
      paste0(collapse = " ") 
    ## game data
    headers <- pgn[seq(which(pgn == "")) - 1]
    data_keys <- str_extract(headers, "\\w+") #clean up headers
    data_vals <- str_extract(headers, "\".*\"") %>% str_replace_all("\"", "") #extract values for the headers
    # create a dataframe for a single game
    df_game <- t(data_vals) %>%
      data.frame(stringsAsFactors = FALSE) %>%
      setNames(data_keys) %>%
      mutate(pgn = pgn2)
  # whilst parsing the different files, print a progress bar, then save the result of a single PGN in dataframe
    }, .progress = ifelse(VERBOSE, "text", "none")) %>% tbl_df()
  
  df_games <- df_games %>% 
    select(Event, Site, Date, Round, White, Black, Result,
           WhiteElo, BlackElo, ECO, pgn) %>% 
    mutate(Date = str_replace_all(Date, "\\.", "-"),
           WhiteElo = as.numeric(WhiteElo),
           BlackElo = as.numeric(BlackElo)) %>% 
    setNames(tolower(names(.)))
  f2 <- str_replace(basename(f), "\\.\\w+", "") #extract file name
  # save as txt files in PATH_WORKING
  gz <- gzfile(file.path(PATH_WORKING,  sprintf("games_%s.txt.gz", f2)), "w") 
  write.table(df_games, file = gz, quote = FALSE, sep = "\t", row.names = FALSE) 
  close(gz)
  # print stats for the time taken
  diff <- difftime(Sys.time(), t0, units = "hours")
  df_summary <- data_frame(f, ngames = nrow(df_games), time_hrs = diff)
  print(df_summary)
}, .progress = ifelse(VERBOSE, "text", "none"))
# print the time taken to load the data
load_times %>% summarise(sum(ngames), sum(time_hrs))
# create df from the temp tables created and save to KingBase2016-03.RData
dfgames <- ldply(dir(PATH_WORKING, full.names = TRUE), read_tsv) %>% tbl_df()
save(dfgames, file = "KingBase2016-03.RData")
## Clean UP
unlink(PATH_WORKING, recursive = TRUE)
unlink(PATH_RAWDATA, recursive = TRUE)

####
#### data is loadable using
#### load("KingBase2016-03.RData")
####
}