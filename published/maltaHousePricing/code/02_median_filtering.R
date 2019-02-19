median_filter <- function(sig, threshold=3) { diff <- abs(sig - median(sig))
median_diff <- median(diff)
if (median_diff == 0) {
  s <- 0 } else {
    s <- diff / median_diff }
return(ifelse(s > threshold, median(sig), sig)) }