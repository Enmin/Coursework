a <- read.table("http://www.stat.ucla.edu/~nchristo/statistics100c/soil_complete.txt", header=TRUE)
#Response variable:
y <- a$lead
#Predictor variables:
x1 <- a$cadmium
x2 <- a$copper
x3 <- a$zinc
n <- nrow(a)
ones <- rep(1, nrow(a))
X <- as.matrix(cbind(ones, x1, x2, x3))
H <-  X %*% solve(t(X) %*% X) %*% t(X)
I = diag(nrow(a))
beta_hat <- solve(t(X) %*% X) %*% t(X) %*% y
c <- as.matrix(cbind(0,0,1,0))
gamma <- as.matrix(cbind(0))

nomi <- (t(c%*%beta_hat - gamma) %*% solve(c%*%solve(t(X)%*%X)%*%t(c)) %*% (c%*%beta_hat - gamma)) / var(y)
denomi <- t(y) %*% (I - H) %*% y / var(y)
f <- nomi / denomi
t <- sqrt(f)

ssef <-  t(y) %*% (I - H) %*% y
# constrained
Xr <- as.matrix(cbind(ones, x1, x3))
Hr <-  Xr %*% solve(t(Xr) %*% Xr) %*% t(Xr)
sser <- t(y) %*% (I - Hr) %*% y

esop <- (sser-ssef)/ (ssef/(n-4))
