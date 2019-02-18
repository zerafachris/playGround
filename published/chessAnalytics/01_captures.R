#create chessboard with captures
captures <- function (BB) { # BB <- dfgames$pgn[1]  # BB <- "asas 12" 
  a <- which(strsplit(BB, "")[[1]]=="x")
  b <- a+2
  a <- a+1
  if ( length(a) == 0){
    caps <- paste(rep("0",64),collapse = "_")
  } else {
  CELL <- substring(BB,a,b)
  #CELL <- substr(BB,a,b)
  board <- expand.grid(X=letters[1:8],Y=seq(1,8))
  board <- data.frame(CELL = paste(board$X,board$Y,sep = ""))
  # populate with captures
  board$KILLS <- sapply(board$CELL, function(string) sum(string==CELL))
  caps <- paste(board$KILLS, collapse = "_")
  }
  return(caps)
}