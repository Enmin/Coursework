data <- read.csv("Desktop/stats100c/hw9.csv", header = TRUE)
attach(data)
y <- data$Y
x1 <- data$X1
x2 <- data$X2
x3 <- data$X3
x4 <- data$X4

#b 1
#Full regression:
ones <- rep(1, nrow(data))
X <- as.matrix(cbind(ones,x1, x2, x3, x4))
beta_hat <- solve(t(X) %*% X) %*% t(X) %*% y

#Partial regression of y on x1,x2,x3,x4:
ones <- rep(1, nrow(data))
X1 <- as.matrix(cbind(ones,x1, x2))

beta_hat1 <- solve(t(X1) %*% X1) %*% t(X1) %*% y

H1 <- X1 %*% solve(t(X1) %*% X1) %*% t(X1)

y11 <- (diag(nrow(data)) - H1) %*% y

#Create the X2 matrix:
X2 <- as.matrix(cbind(x3, x4))

X22 <- (diag(nrow(data)) - H1) %*% X2

beta2_hat <- solve(t(X22) %*% X22) %*% t(X22) %*% y11

# b 2
I = diag(12)
H = matrix(c(1), nrow=12, ncol=12)
ystar <- (I-H) %*% y
x2star <- (I-H) %*% X
bhat = lm(ystar ~ x2star)

