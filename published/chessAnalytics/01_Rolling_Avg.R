rollmedianR <- function(x, k) {
  n <- length(x)
  k.low <- floor((k+1)/2)
  k.high <- n + 1 - k.low
  repeat {
    y <- rollmedian(x, k, na.pad=TRUE)
    y[1:k.low] <- y[k.low]; y[k.high:n] <- y[k.high]
    if (identical(x, y)) break
    x <- y
  }
  return(y)
}
rollmeanR <- function(x, k) {
  n <- length(x)
  k.low <- floor((k+1)/2)
  k.high <- n + 1 - k.low
  repeat {
    y <- rollmean(x, k, na.pad=TRUE)
    y[1:k.low] <- y[k.low]; y[k.high:n] <- y[k.high]
    if (identical(x, y)) break
    x <- y
  }
  return(y)
}