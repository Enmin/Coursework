data <- read.csv("Desktop/stats100c/hw9.csv", header = TRUE)
attach(data)
str(data)

XX <- cbind(c(1,1), data.matrix(data[1:3]))
YY <- data.matrix(data[4])
hat.mat <- XX%*%solve(t(XX)%*%XX)%*%t(XX)
rowSums(hat.mat)
colSums(hat.mat)

#beta
solve(t(XX)%*%XX)%*%t(XX)%*%YY

XX <- cbind(c(0), data.matrix(data[1:3]))
YY <- data.matrix(data[4])
# cannot solve the matrix at this time, and row sum of h matrix is not 1
