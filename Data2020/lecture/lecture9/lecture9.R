rm(list=ls())

library("arm")


wells <- read.table("/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/lecture/R-script/lecture9/wells.dat")
attach.all (wells)
head(wells)



## Histogram on distance (Figure 3)

hist (dist, breaks=seq(0,10+max(dist[!is.na(dist)]),10), 
   xlab="Distance (in meters) to the nearest safe well", 
   ylab="", main="", mgp=c(2,.5,0))



## Logistic regression with one predictor

fit.1 <- glm (switch ~ dist, family=binomial(link="logit"))
display (fit.1)

summary(fit.1)



## Repeat the regression above with distance in 100-meter units

dist100 <- dist/100
fit.2 <- glm (switch ~ dist100, family=binomial(link="logit"))
summary(fit.2)



## Graphing the fitted model with one predictor (4)

jitter.binary <- function(a, jitt=.05){
  ifelse (a==0, runif (length(a), 0, jitt), runif (length(a), 1-jitt, 1))
}

switch.jitter <- jitter.binary(switch)

plot(dist, switch.jitter, xlab="Distance (in meters) to nearest safe well", ylab="Pr (switching)", type="n", xaxs="i", yaxs="i", mgp=c(2,.5,0))
curve (invlogit(coef(fit.1)[1]+coef(fit.1)[2]*x), lwd=1, add=TRUE)
points (dist, jitter.binary(switch), pch=20, cex=.1)





## Histogram on arsenic levels (Figure 5.10)

hist (arsenic, breaks=seq(0,.25+max(arsenic[!is.na(arsenic)]),.25), freq=TRUE, xlab="Arsenic concentration in well water", ylab="", main="", mgp=c(2,.5,0))



## Logistic regression with second input variable

fit.3 <- glm (switch ~ dist100 + arsenic, family=binomial(link="logit"))
display (fit.3)
summary(fit.3)




 #equivalently

plot(dist, switch.jitter, xlim=c(0,max(dist)), xlab="Distance (in meters) to nearest safe well", ylab="Pr (switching)", type="n", xaxs="i", yaxs="i", mgp=c(2,.5,0))
curve (invlogit(coef(fit.3)[1]+coef(fit.3)[2]*x/100+coef(fit.3)[3]*.50), lwd=.5, add=TRUE)
curve (invlogit(coef(fit.3)[1]+coef(fit.3)[2]*x/100+coef(fit.3)[3]*1.00), lwd=.5, add=TRUE)
points (dist, jitter.binary(switch), pch=20, cex=.1)
text (50, .27, "if As = 0.5", adj=0, cex=.8)
text (75, .50, "if As = 1.0", adj=0, cex=.8)

plot(arsenic, switch.jitter, xlim=c(0,max(arsenic)), xlab="Arsenic concentration in well water", ylab="Pr (switching)", type="n", xaxs="i", yaxs="i", mgp=c(2,.5,0))
curve (invlogit(coef(fit.3)[1]+coef(fit.3)[2]*0+coef(fit.3)[3]*x), from=0.5, lwd=.5, add=TRUE)
curve (invlogit(coef(fit.3)[1]+coef(fit.3)[2]*0.5+coef(fit.3)[3]*x), from=0.5, lwd=.5, add=TRUE)
points (arsenic, jitter.binary(switch), pch=20, cex=.1)
text (1.5, .78, "if dist = 0", adj=0, cex=.8)
text (2.2, .6, "if dist = 50", adj=0, cex=.8)



## Logistic regression with interactions

fit.4 <- glm (switch ~ dist100 + arsenic + dist100:arsenic, 
  family=binomial(link="logit"))
summary(fit.4)

## Centering the input variables

c.dist100 <- dist100 - mean (dist100)
c.arsenic <- arsenic - mean (arsenic)

## Refitting the model with centered inputs

fit.5 <- glm (switch ~ c.dist100 + c.arsenic + c.dist100:c.arsenic,
  family=binomial(link="logit"))
summary(fit.5)

## Graphing the model with interactions 
par(mfrow=c(1,2))
plot(dist, switch.jitter, xlim=c(0,max(dist)), xlab="Distance (in meters) to nearest safe well", 
   ylab="Pr (switching)", type="n", xaxs="i", yaxs="i", mgp=c(2,.5,0))
curve (invlogit(cbind (1, x/100, .5, .5*x/100) %*% coef(fit.4)), lwd=.5, add=TRUE)
curve (invlogit(cbind (1, x/100, 1.0, 1.0*x/100) %*% coef(fit.4)), lwd=.5, add=TRUE)
points (dist, jitter.binary(switch), pch=20, cex=.1)
text (50, .37, "if As = 0.5", adj=0, cex=.8)
text (75, .50, "if As = 1.0", adj=0, cex=.8)

plot(arsenic, switch.jitter, xlim=c(0,max(arsenic)), xlab="Arsenic concentration in well water",
   ylab="Pr (switching)", type="n", xaxs="i", yaxs="i", mgp=c(2,.5,0))
curve (invlogit(cbind (1, 0, x, 0*x) %*% coef(fit.4)), lwd=.5, add=TRUE)
curve (invlogit(cbind (1, 0.5, x, 0.5*x) %*% coef(fit.4)), lwd=.5, add=TRUE)
points (arsenic, jitter.binary(switch), pch=20, cex=.1)
text (1.5, .8, "if dist = 0", adj=0, cex=.8)
text (2.2, .6, "if dist = 50", adj=0, cex=.8)

 #equivalently

plot(dist, switch.jitter, xlim=c(0,max(dist)), xlab="Distance (in meters) to nearest safe well", 
   ylab="Pr (switching)", type="n", xaxs="i", yaxs="i", mgp=c(2,.5,0))
curve (invlogit(coef(fit.4)[1]+coef(fit.4)[2]*x/100+coef(fit.4)[3]*.50+coef(fit.4)[4]*(x/100)*.50),
   lwd=.5, add=TRUE)
curve (invlogit(coef(fit.4)[1]+coef(fit.4)[2]*x/100+coef(fit.4)[3]*1.00+coef(fit.4)[4]*(x/100)*1),
   lwd=.5, add=TRUE)
points (dist, jitter.binary(switch), pch=20, cex=.1)
text (50, .37, "if As = 0.5", adj=0, cex=.8)
text (75, .50, "if As = 1.0", adj=0, cex=.8)

plot(arsenic, switch.jitter, xlim=c(0,max(arsenic)), xlab="Arsenic concentration in well water",
   ylab="Pr (switching)", type="n", xaxs="i", yaxs="i", mgp=c(2,.5,0))
curve (invlogit(coef(fit.4)[1]+coef(fit.4)[2]*0+coef(fit.4)[3]*x+coef(fit.4)[4]*0*x), from=0.5,
   lwd=.5, add=TRUE)
curve (invlogit(coef(fit.4)[1]+coef(fit.4)[2]*0.5+coef(fit.4)[3]*x+coef(fit.4)[4]*0.5*x), 
  from=0.5, lwd=.5, add=TRUE)
points (arsenic, jitter.binary(switch), pch=20, cex=.1)
text (1.5, .8, "if dist = 0", adj=0, cex=.8)
text (2.2, .6, "if dist = 50", adj=0, cex=.8)

## Adding social predictors

educ4 <- educ/4

 # with community organization variable

fit.6 <- glm (switch ~ c.dist100 + c.arsenic + c.dist100:c.arsenic +
  assoc + educ4, family=binomial(link="logit"))
summary(fit.6)

 # without community organization variable

fit.7 <- glm (switch ~ c.dist100 + c.arsenic + c.dist100:c.arsenic +
  educ4, family=binomial(link="logit"))
summary (fit.7)

## Adding further interactions (centering education variable)

c.educ4 <- educ4 - mean(educ4)

fit.8 <- glm (switch ~ c.dist100 + c.arsenic + c.educ4 + c.dist100:c.arsenic +
  c.dist100:c.educ4 + c.arsenic:c.educ4, family=binomial(link="logit"))
summary (fit.8)


## Residual Plot (Figure 5.13 (a))

pred.8 <- fit.8$fitted.values

plot(c(0,1), c(-1,1), xlab="Estimated  Pr (switching)", ylab="Observed - estimated", type="n", main="Residual plot", mgp=c(2,.5,0))
abline (0,0, col="gray", lwd=.5)
points (pred.8, switch-pred.8, pch=20, cex=.2)

### Binned residual Plot 

 ## Defining binned residuals

binned.resids <- function (x, y, nclass=sqrt(length(x))){
  breaks.index <- floor(length(x)*(1:(nclass-1))/nclass)
  breaks <- c (-Inf, sort(x)[breaks.index], Inf)
  output <- NULL
  xbreaks <- NULL
  x.binned <- as.numeric (cut (x, breaks))
  for (i in 1:nclass){
    items <- (1:length(x))[x.binned==i]
    x.range <- range(x[items])
    xbar <- mean(x[items])
    ybar <- mean(y[items])
    n <- length(items)
    sdev <- sd(y[items])
    output <- rbind (output, c(xbar, ybar, n, x.range, 2*sdev/sqrt(n)))
  }
  colnames (output) <- c ("xbar", "ybar", "n", "x.lo", "x.hi", "2se")
  return (list (binned=output, xbreaks=xbreaks))
}

 ## Binned residuals vs. estimated probability of switching 
##n class is the number of bins
br.8 <- binned.resids (pred.8, switch-pred.8, nclass=40)$binned
plot(range(br.8[,1]), range(br.8[,2],br.8[,6],-br.8[,6]), xlab="Estimated  Pr (switching)", ylab="Average residual", type="n", main="Binned residual plot", mgp=c(2,.5,0))
abline (0,0, col="gray", lwd=.5)
lines (br.8[,1], br.8[,6], col="gray", lwd=.5)
lines (br.8[,1], -br.8[,6], col="gray", lwd=.5)
points (br.8[,1], br.8[,2], pch=19, cex=.5)

 ## Plot of binned residuals vs. inputs of interest

  # distance  
  par(mfrow=c(1,2))
br.dist <- binned.resids (dist, switch-pred.8, nclass=40)$binned
plot(range(br.dist[,1]), range(br.dist[,2],br.dist[,6],-br.dist[,6]), xlab="Distance to nearest safe well", ylab="Average residual", type="n", main="Binned residual plot", mgp=c(2,.5,0))
abline (0,0, col="gray", lwd=.5)
lines (br.dist[,1], br.dist[,6], col="gray", lwd=.5)
lines (br.dist[,1], -br.dist[,6], col="gray", lwd=.5)
points (br.dist[,1], br.dist[,2], pch=19, cex=.5)

  # arsenic (Figure 5.13 (b))
br.arsenic <- binned.resids (arsenic, switch-pred.8, nclass=40)$binned
plot(range(0,br.arsenic[,1]), range(br.arsenic[,2],br.arsenic[,6],-br.arsenic[,6]), xlab="Arsenic level", ylab="Average residual", type="n", main="Binned residual plot", mgp=c(2,.5,0))
abline (0,0, col="gray", lwd=.5)
lines (br.arsenic[,1], br.arsenic[,6], col="gray", lwd=.5)
lines (br.arsenic[,1], -br.arsenic[,6], col="gray", lwd=.5)
points (br.arsenic[,1], br.arsenic[,2], pch=19, cex=.5)



## Log transformation

log.arsenic <- log (arsenic)
c.log.arsenic <- log.arsenic - mean (log.arsenic)

fit.9 <- glm (switch ~ c.dist100 + c.log.arsenic + c.educ4 +
  c.dist100:c.log.arsenic + c.dist100:c.educ4 + c.log.arsenic:c.educ4,
  family=binomial(link="logit"))
summary(fit.9)

fit.9a <- glm (switch ~ dist100 + log.arsenic + educ4 +
  dist100:log.arsenic + dist100:educ4 + log.arsenic:educ4,
  family=binomial(link="logit"))
summary(fit.9a)



## Graph for log model fit.9a (Figure 5.15 (a))
par(mfrow=c(1,2))

plot(arsenic, switch.jitter, xlim=c(0,max(arsenic)), xlab="Arsenic concentration in well water", ylab="Pr (switching)", type="n", xaxs="i", yaxs="i", mgp=c(2,.5,0))
curve (invlogit(coef(fit.9a)[1]+coef(fit.9a)[2]*0+coef(fit.9a)[3]*log(x)+coef(fit.9a)[4]*mean(educ4)+coef(fit.9a)[5]*0*log(x)+coef(fit.9a)[6]*0*mean(educ4)+coef(fit.9a)[7]*log(x)*mean(educ4)), from=.50, lwd=.5, add=TRUE)
curve (invlogit(coef(fit.9a)[1]+coef(fit.9a)[2]*.5+coef(fit.9a)[3]*log(x)+coef(fit.9a)[4]*mean(educ4)+coef(fit.9a)[5]*.5*log(x)+coef(fit.9a)[6]*.5*mean(educ4)+coef(fit.9a)[7]*log(x)*mean(educ4)), from=.50, lwd=.5, add=TRUE)
points (arsenic, jitter.binary(switch), pch=20, cex=.1)
text (1.2, .8, "if dist = 0", adj=0, cex=.8)
text (1.8, .6, "if dist = 50", adj=0, cex=.8)

## Graph of binned residuals for log model fit.9 (Figure 5.15 (b))

pred.9 <- fit.9$fitted.values

br.fit.9 <- binned.resids (arsenic, switch-pred.9, nclass=40)$binned
plot(range(0,br.fit.9[,1]), range(br.fit.9[,2],br.fit.9[,6],-br.fit.9[,6]), xlab="Arsenic level", ylab="Average residual", type="n", main="Binned residual plot\nfor model with log (arsenic)", mgp=c(2,.5,0))
abline (0,0, col="gray", lwd=.5)
lines (br.fit.9[,1], br.fit.9[,6], col="gray", lwd=.5)
lines (br.fit.9[,1], -br.fit.9[,6], col="gray", lwd=.5)
points (br.fit.9[,1], br.fit.9[,2], pch=19, cex=.5)



## Error rates

 # in general

error.rate <- mean((predicted>0.5 & y==0) | (predicted<0.5 & y==1))

 # for modell fit.9

error.rate <- mean((pred.9>0.5 & switch==0) | (pred.9<0.5 & switch==1))



##likelihood ratio test
install.packages('lmtest',dependencies=TRUE, repos='http://cran.rstudio.com/')
library(lmtest)

lrtest(fit.1,fit.3)
lrtest(fit.1,fit.9)

