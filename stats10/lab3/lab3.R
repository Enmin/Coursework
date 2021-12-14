library(histogram)
#-------------1-----------------
#a
soil<-read.table("http://www.stat.ucla.edu/~nchristo/statistics_c173_c273/soil_complete.txt", header=TRUE)
linear_model <- lm(soil$lead ~ soil$zinc)
summary(linear_model)
#b
plot(soil$lead ~ soil$zinc, xlab="zinc", ylab="lead", main="regression of lead on zinc")
abline(linear_model, col="red", lwd=2)
#c
plot(linear_model$residuals ~ soil$zinc, main="residual plot")
abline(a=0, b=0,col='red',lwd=2)

#--------------2---------------
#a
ice <-read.csv("~/Desktop/stats10/lab3/sea_ice.csv", header = TRUE)
ice$Date <-as.Date(ice$Date, "%m/%d/%Y")
linear_model2 <- lm(ice$Extent ~ ice$Date)
summary(linear_model2)
#b
plot(ice$Extent ~ ice$Date, xlab="date", ylab="extent", main="regression of extent on time")
abline(linear_model2, col="red", lwd=2)
#c
plot(linear_model2$residuals ~ ice$Date, main="residual plot")
abline(a=0, b=0,col='red',lwd=2)

#--------------3--------------
#b
set.seed(123)
numbers = 1:6
rand_dice = replicate(5000, sample(numbers, 2, replace = TRUE))
outcome <- colSums(rand_dice)
histogram(outcome)
#c
t<-table(outcome)
double <- (t[6] + t[10])/5000
lose <- (t[1]+t[2]+t[11])/5000

#-------------4-------------
dbinom(145, size = 365, prob = 0.4)
pbinom(175, size = 365, prob = 0.4) - pbinom(125, size = 365, prob = 0.4)
1-pnorm(230, mean=200, sd=20)
