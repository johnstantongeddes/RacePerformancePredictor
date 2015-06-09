toHMS <- function(x){
  if (!is.numeric(x)) stop("x must be a numeric")
  if (length(x)<=0)return(x)
  
  H <- formatC(x %/% 3600, width=2, flag="0")
  M <- formatC(x %% 3600 %/% 60, width=2, flag="0")
  seconds <- x %% 60
  # formatting for seconds
  if(seconds < 10) { 
    S <- formatC(x %% 60, width=2, flag="0", digits=1) } else 
    S <- formatC(x %% 60, width=2, flag="0", digits=2)
  
  paste(H, M, S, sep = ":")
} 