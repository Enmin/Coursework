a <- read.table("http://www.stat.ucla.edu/~nchristo/statistics100C/body_fat.txt", header=TRUE)
y <- a$y
x1 <- a$x11
x2 <- a$x12
x3 <- a$x13
x4 <- a$x14
x5 <- a$x15
n <- nrow(a)
ones <- rep(1, nrow(a))
#a
X <- as.matrix(cbind(ones, x1, x2, x3,x4,x5))
XTX <- t(X) %*% X
beta_hat <- solve(XTX) %*% t(X) %*% y
H <- X %*% solve(t(X) %*% X) %*% t(X)
yhat <- X %*% beta_hat
e <- y - yhat
se2 <- t(e) %*% e / (n-5-1)
#b do not reject Ho
c <- matrix(c(0,0,0, 0,0,0, 1,0,0, 0,0,0, 0,1,0, 0,0,1), nrow=3)
g <- matrix(c(0,0,0))
F <- (t(c%*%beta_hat-g)%*%solve(c%*%solve(t(X)%*%X)%*%t(c))%*%(c %*%beta_hat-g)) / (3*se2)
qf(0.95, 3, n-5-1)
#c same as F bot hare 0.9709413
I = diag(nrow(a))
Xr <- as.matrix(cbind(ones, x1, x3))
Hr <-  Xr %*% solve(t(Xr) %*% Xr) %*% t(Xr)
sser <- t(y) %*% (I - Hr) %*% y
ssef <- t(y) %*% (I - H) %*% y
ESP <- (sser-ssef) * (n-5-1) / (ssef * 3)
#d !!!!!!!!!
sigma2 <- 50
B <- matrix(c(-42,2.4,-0.5,1.9,0.1,-0.6),nrow=6)
ncp <- t(c%*%B-g)%*%solve(c%*%solve(t(X)%*%X)%*%t(c))%*%(c %*%B-g) / sigma2
temp<-qf(0.95, 3, n-5-1)
power<-pf(temp,3,n-5-1,ncp) - pf(0.95, n-5-1, ncp)
type_II_error <- 1 - power
#e
C <- matrix(c(2,0,1,2,1,5,1,1,2,1,3,1), nrow=2)
G <- matrix(c(15,25))
beta_hat_c <- beta_hat - solve(XTX) %*% t(C) %*% solve(C%*%solve(XTX)%*%t(C)) %*%(C %*%beta_hat-G)
ec <- y-X%*%beta_hat_c
sec2c <- t(ec) %*% ec / (n-5-1+2)
