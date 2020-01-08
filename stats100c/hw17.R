a <- read.table("http://www.stat.ucla.edu/~nchristo/statistics_c173_c273/jura.txt",header=TRUE)
y <- a$Pb
x1 <- a$Cd
x2 <- a$Co
x3 <- a$Cr
x4 <- a$Cu
x5 <- a$Ni
x6 <- a$Zn
n <- nrow(a)
ones <- rep(1, nrow(a))
#a
X <- as.matrix(cbind(ones, x1, x2, x3,x4,x5,x6))
#b
H <-  X %*% solve(t(X) %*% X) %*% t(X)
beta_hat <- solve(t(X) %*% X) %*% t(X) %*% y
e <- y - X%*%beta_hat
se2 <- t(e) %*% e / (n-6-1)
XTX = t(X) %*% X
#lf <- lm(y~x1+x2+x3+x4+x5+x6)
#lr <- lm(y~x2+x4+x5+x6)
# the summary confirms the above calculation of full model
#c, d
c <- matrix(c(0,0,1,0,0,0,0,1,0,0,0,0,0,0), nrow=2)
g <- matrix(c(0,0), nrow=2)
I = diag(nrow(a))
F <- (t(c%*%beta_hat-g)%*%solve(c%*%solve(t(X)%*%X)%*%t(c))%*%(c %*%beta_hat-g)) / (2*se2)
#e same as result in d
Xr <- as.matrix(cbind(ones, x2, x4,x5,x6))
Hr <-  Xr %*% solve(t(Xr) %*% Xr) %*% t(Xr)
sser <- t(y) %*% (I - Hr) %*% y
ssef <- t(y) %*% (I - H) %*% y
ESP <- (sser-ssef) * (n-6-1) / (ssef * 2)
#f its square equals that of f test
cf <- c(0,0,0,0,1,0,0)
t <- cf %*% beta_hat  / sqrt(se2[1,1] * t(cf) %*% solve(XTX) %*% cf)
#g
C <- matrix(c(0,0,1,0,1,0,0,1,0,0,-3,1,0,1), nrow=2)
G <- matrix(c(2,3))
beta_hat_c <- beta_hat - solve(XTX) %*% t(C) %*% solve(C%*%solve(XTX)%*%t(C)) %*% (C %*%beta_hat-G)
ec <- y-X%*%beta_hat_c
sec2c <- t(ec) %*% ec / (n-6-1+2)
#h
C1 <- matrix(c(1,0,0,1), nrow=2)
C2 <- matrix(c(0,0,1,0,0,0,-3,1,0,1), nrow=2)
X1 <- as.matrix(cbind(x2,x3))
X2 <- as.matrix(cbind(ones,x1,x4,x5,x6))
X2r <- X2 - X1 %*% solve(C1) %*% C2
yr <- y - X1 %*% solve(C1) %*% G
beta2_r <- solve(t(X2r) %*% X2r) %*% t(X2r) %*% yr
beta1_r <- solve(C1) %*% (G - C2 %*% beta2_r)
qf <- lm(y ~ x1+x2+x3+x4+x5+x6)
qr <- lm(yr ~ X2r[,2]+X2r[,3]+X2r[,4]+X2r[,5])
ssef <- summary(qf)$sigma^2*(nrow(a)-6-1)
sser <- summary(qr)$sigma^2*(nrow(a)-4-1)
ESPh <- ((sser-ssef)/2)/(ssef/(nrow(a)-6-1))
#i
Fi <- (t(C%*%beta_hat-G)%*%solve(C%*%solve(t(X)%*%X)%*%t(C))%*%(C %*%beta_hat-G)) / (2*se2)
#j
#A <- diag(nrow(beta_hat)) - solve(XTX) %*% t(C) %*% solve(C%*%solve(XTX)%*%t(C)) %*% C
#var_beta_hat_c = var(y) * A %*% solve(XTX) %*% t(A)
var_beta_hat_c <- summary(qr)$sigma^2 *solve(XTX)
