move_1 <- function(AA) { #AA <- dfgames$pgn[2]
  AA <- strsplit(AA, "[.]")[[1]][2]
  AA <- paste(AA,collapse = " ")
  AA <- strsplit(AA,  " ")[[1]][1]
  return(AA)
}
move_2 <- function(AA) { #AA <- dfgames$pgn[2]
  AA <- strsplit(AA, "[.]")[[1]][2]
  AA <- paste(AA,collapse = " ")
  AA <- strsplit(AA,  " ")[[1]][2]
  return(AA)
}
move_3 <- function(AA) { #AA <- dfgames$pgn[2]
  AA <- strsplit(AA, "[.]")[[1]][3]
  AA <- paste(AA,collapse = " ")
  AA <- strsplit(AA,  " ")[[1]][1]
  return(AA)
}
move_4 <- function(AA) { #AA <- dfgames$pgn[2]
  AA <- strsplit(AA, "[.]")[[1]][3]
  AA <- paste(AA,collapse = " ")
  AA <- strsplit(AA,  " ")[[1]][2]
  return(AA)
}
opening_move <-function(AA) { #AA <- dfgames$pgn[2]
  AA <- strsplit(AA, "[.]")[[1]][2:4]
  AA <- paste(AA,collapse = " ")
  AA <- strsplit(AA,  " ")[[1]][c(1,2,4,5,7,8)]
  AA <- paste(AA,collapse = "-")
  return(AA)
}