data <- read.csv("Desktop/stats100c/hw9.csv", header = TRUE)
attach(data)
y <- data$Y
x1 <- data$X1
x2 <- data$X2
x3 <- data$X3
x4 <- data$X4

ones <- rep(1, nrow(data))
X <- as.matrix(cbind(x1, x2, x3, x4))
H12 <-  X %*% solve(t(X) %*% X) %*% t(X)
beta_hat <- solve(t(X) %*% X) %*% t(X) %*% y

#Partial regression of y on x1,x2,x3,x4:
ones <- rep(1, nrow(data))
X1 <- as.matrix(cbind(x1, x2))
X1beta1_hat <- solve(t(X1) %*% X1) %*% t(X1) %*% y
H1 <- X1 %*% solve(t(X1) %*% X1) %*% t(X1)
y11 <- (diag(nrow(data)) - H1) %*% y

#Create the X2 matrix:
X2 <- as.matrix(cbind(x3, x4))
X22 <- (diag(nrow(data)) - H1) %*% X2
beta2_hat <- solve(t(X22) %*% X22) %*% t(X22) %*% y11

#a
I = diag(nrow(data))
left <- t(y) %*% (I-H12) %*% y
right <- t(y-X2%*%beta2_hat) %*% (I-H1) %*% (y-X2%*%beta2_hat)
all.equal(left,right)
#b
left <- t(y) %*% (I-H1) %*% y - t(y) %*% (I-H12) %*% y
middle <- t(beta2_hat) %*% t(X2) %*% (I-H1) %*% y
right <- t(beta2_hat) %*% t(X2)%*%(I-H1)%*%X2 %*% beta2_hat
all.equal(left,right,middle)
#c
covmatrix <- solve(t(X1)%*%X1) %*% t(X1) %*% (I-H1) %*% X22 %*% solve(t(X22)%*%X22)
