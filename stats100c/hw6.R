a1 <- read.table("http://www.stat.ucla.edu/~nchristo/statistics100c/soil.txt", header=TRUE)
a <- a1[1:30, ]
attach(a)
l1 = lm(lead~zinc)
ncpar <- 0.05*sqrt(29*var(zinc))/sqrt(600)
answer <- pt(qt(0.975,28), 28, ncp=ncpar, lower.tail=FALSE) + pt(-qt(0.975, 28), 28, ncp=ncpar)
