data <- read.csv("Desktop/stats100c/hw10 dataset.csv", header = TRUE)
attach(data)
str(data)

XX <- cbind(c(1,1), data.matrix(data[1:3]))
YY <- data.matrix(data[4])
#1
xTx <- t(XX)%*%XX
xTxInverse <- solve(t(XX)%*%XX)
xTy <- t(XX)%*%YY
#2
Bhat <- xTxInverse%*%xTy
#3
H <- XX%*%xTxInverse%*%t(XX)
#4
yhat <- XX%*%Bhat
#5
e <- YY-yhat

