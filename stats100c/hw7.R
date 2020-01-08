a1 <- read.table("http://www.stat.ucla.edu/~nchristo/statistics100c/soil.txt", header=TRUE)
attach(a1)
l = lm(lead~zinc)
eb0 = 17.367688
eb1 = 0.289523
vb0 = 4.344268
vb1 = 0.007296
e = b0-3*b1-15
sesquare = sum((lead - eb0 - eb1*zinc)^2)
sigma = sqrt(sesquare * (sum(zinc^2)+6*mean(zinc)+9)/sum((zinc-mean(zinc))^2))
t = e/sigma
