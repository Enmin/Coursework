library(histogram)
#-------------1-----------------
#a
flint <- read.csv("~/Desktop/stats10/lab2/flint.csv")
#b
mean(flint$Pb >= 15)
#c
region <- flint$Region
copper <- flint$Cu
is_north <- region == "North"
north_cu <- copper[is_north]
mean(north_cu)
#d
pb <- flint$Pb
is_danger <- pb >= 15
danger_cu <- copper[is_danger]
mean(danger_cu)
#e
mean(flint$Cu)
mean(flint$Pb)
#f
boxplot(flint$Pb, main="boxplot of lead levels")

#------------2-----------------
#a
life<-read.table("http://www.stat.ucla.edu/~nchristo/statistics12/countries_life.txt", header=TRUE)
plot(life$Income, life$Life, xlab="income", ylab="Life", main="Life against Income")
#b
boxplot(life$Income, main="boxplot of Income")
histogram::histogram(life$Income, main="histogram of Income")
#c
income <- life$Income
is_above <- income >= 1000
is_below <- income < 1000
above_1000 <- life[is_above,]
below_1000 <- life[is_below,]
#d
plot(below_1000$Income, below_1000$Life, xlab="income", ylab="Life", main="Life against Income")
cor(below_1000$Income, below_1000$Life)

#------------3------------------
#a
maas<-read.table("http://www.stat.ucla.edu/~nchristo/statistics12/soil.txt", header=TRUE)
summary(maas$lead)
summary(maas$zinc)
#b
histogram(maas$lead, main="histogram of lead")
histogram(log(maas$lead), main="histogram of log(lead)")
#c
plot(log(maas$lead), log(maas$zinc), xlab="log(lead)", ylab="log(zinc)", main="log(lead) vs log(zinc)")
#d
ppm_colors <- c("green", "yellow", "red")
ppm_levels <- cut(maas$lead, c(0,150,400, 1000))
plot(maas$x, maas$y,xlab="longtitude", ylab="lattitude", main="ppm plot", "n")
points(maas$x, maas$y, cex=maas$lead/mean(maas$lead), col=ppm_colors[as.numeric(ppm_levels)], pch=19)

#------------4------------------
#a
LA <-read.table("http://www.stat.ucla.edu/~nchristo/statistics12/la_data.txt", header=TRUE)
plot(LA$Longitude, LA$Latitude, xlim=c(-119,-118), ylim=c(33.5,35), xlab="longtitude", ylab="lattitude", main="LA plot", "n")
map("county", "california", add = TRUE)
#b
zero_school <- LA$Schools != 0
LA_subset <- LA[zero_school,]
plot(LA_subset$Income, LA_subset$Schools, main="Schools vs Income")
