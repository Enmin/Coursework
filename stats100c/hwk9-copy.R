leverage <- read.csv("Desktop/stats100c/hw9.csv", header = TRUE)
attach(leverage)
str(leverage)

XX <- cbind(c(1,1), data.matrix(leverage[1:3]))
YY <- data.matrix(leverage[4])
hat.mat <- XX%*%solve(t(XX)%*%XX)%*%t(XX)
#Very large matrix
rowSums(hat.mat)
#  [1] 1 1 1 1 1 1 1 1 1 1 1 1
# by symmetry it is also true that
colSums(hat.mat)
# will all sum to 1

#By OLS we have the beta matrix
solve(t(XX)%*%XX)%*%t(XX)%*%YY

# Without the intercept; We can "drop" the intercept by having
# the first row of the x matrix simply equal 0.
XX <- cbind(c(0), data.matrix(leverage[1:3]))
YY <- data.matrix(leverage[4])
hat.mat <- XX%*%solve(t(XX)%*%XX)%*%t(XX)
#Very large matrix
rowSums(hat.mat)
#  [1] 1 1 1 1 1 1 1 1 1 1 1 1
# by symmetry it is also true that
colSums(hat.mat)
# will all sum to 1