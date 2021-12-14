## Read & clean the data
# get radon data
# Data are at http://www.stat.columbia.edu/~gelman/arm/examples/radon
library ("arm")
library(BRugs)
library(R2WinBUGS)

srrs2 <- read.table ("/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/lecture/R-script/lecture19/srrs2.dat", header=T, sep=",")
mn <- srrs2$state=="MN"
radon <- srrs2$activity[mn]
log.radon <- log (ifelse (radon==0, .1, radon))
floor <- srrs2$floor[mn]       # 0 for basement, 1 for first floor
n <- length(radon)
y <- log.radon
x <- floor
head(srrs2)


# get county index variable
county.name <- as.vector(srrs2$county[mn])
uniq <- unique(county.name)
J <- length(uniq)
county <- rep (NA, J)
for (i in 1:J){
  county[county.name==uniq[i]] <- i
}

 # no predictors
ybarbar = mean(y)

sample.size <- as.vector (table (county))
sample.size.jittered <- sample.size*exp (runif (J, -.1, .1))
cty.mns = tapply(y,county,mean)
cty.vars = tapply(y,county,var)
cty.sds = mean(sqrt(cty.vars[!is.na(cty.vars)]))/sqrt(sample.size)
cty.sds.sep = sqrt(tapply(y,county,var)/sample.size)

## Figure 12.1 (a)

par(mfrow=c(1,2))
plot (sample.size.jittered, cty.mns, cex.lab=.9, cex.axis=1,
      xlab="sample size in county j",
      ylab="avg. log radon in county j",
      pch=20, log="x", cex=.3, mgp=c(1.5,.5,0),
      ylim=c(0,3.2), yaxt="n", xaxt="n")
axis (1, c(1,3,10,30,100), cex.axis=.9, mgp=c(1.5,.5,0))
axis (2, seq(0,3), cex.axis=.9, mgp=c(1.5,.5,0))
for (j in 1:J){
  lines (rep(sample.size.jittered[j],2),
         cty.mns[j] + c(-1,1)*cty.sds[j], lwd=.5)
#         cty.mns[j] + c(-1,1)*mean(cty.sds[!is.na(cty.sds)]), lwd=.5)
}
abline(h=mlm.radon.nopred$median$mu.a)
title("No pooling",cex.main=.9, line=1)
#abline(h=ybarbar)
points(sample.size.jittered[36],cty.mns[36],cex=4)




## Complete pooling regression
lm.pooled <- lm (y ~ x)
display (lm.pooled)

## No pooling regression
lm.unpooled <- lm (y ~ x + factor(county) -1)
display (lm.unpooled)

## Comparing-complete pooling & no-pooling (Figure 12.2)
x.jitter <- x + runif(n,-.05,.05)
display8 <- c (36, 1, 35, 21, 14, 71, 61, 70)  # counties to be displayed
y.range <- range (y[!is.na(match(county,display8))])

par (mfrow=c(2,4), mar=c(4,4,3,1), oma=c(1,1,2,1))
for (j in display8){
  plot (x.jitter[county==j], y[county==j], xlim=c(-.05,1.05), ylim=y.range,
        xlab="floor", ylab="log radon level", cex.lab=1.2, cex.axis=1.1,
        pch=20, mgp=c(2,.7,0), xaxt="n", yaxt="n", cex.main=1,
        main=uniq[j])
  axis (1, c(0,1), mgp=c(2,.7,0), cex.axis=1.1)
  axis (2, seq(-1,3,2), mgp=c(2,.7,0), cex.axis=1.1)
  curve (coef(lm.pooled)[1] + coef(lm.pooled)[2]*x, lwd=.5, lty=2, add=TRUE)
  curve (coef(lm.unpooled)[j+1] + coef(lm.unpooled)[1]*x, lwd=.5, add=TRUE)
}

## No-pooling ests vs. sample size (plot on the left on figure 12.3)
sample.size <- as.vector (table (county))
sample.size.jittered <- sample.size*exp (runif (J, -.1, .1))

par (mar=c(5,5,4,2)+.1)
plot (sample.size.jittered, coef(lm.unpooled)[-1], cex.lab=1.2, cex.axis=1.2,
  xlab="sample size in county j", ylab=expression (paste
  ("est. intercept, ", alpha[j], "   (no pooling)")),
  pch=20, log="x", ylim=c(.15,3.5), yaxt="n", xaxt="n")
axis (1, c(1,3,10,30,100), cex.axis=1.1)
axis (2, seq(0,3), cex.axis=1.1)
for (j in 1:J){
  lines (rep(sample.size.jittered[j],2),
    coef(lm.unpooled)[j+1] + c(-1,1)*se.coef(lm.unpooled)[j+1], lwd=.5)
}

## Varying-intercept model w/ no predictors
M0 <- lmer (y ~ 1 + (1 | county))
display (M0)

## Including x as a predictor
M1 <- lmer (y ~ x + (1 | county))
display (M1)


###Divide in group: perform a multi-level model 
##varying intercept but no slope and considering room
## as the x. Would you prefer the model with room or with
##floor as covariate? Why? 


  # estimated regression coefficicents
coef (M1)

  # fixed and random effects
fixef (M1)
ranef (M1)

  # uncertainties in the estimated coefficients
se.fixef (M1)
se.ranef (M1)

  # 95% CI for the slope
fixef(M1)["x"] + c(-2,2)*se.fixef(M1)["x"]
#or
fixef(M1)[2] + c(-2,2)*se.fixef(M1)[2]

  # 95% CI for the intercept in county 26
coef(M1)$county[26,1] + c(-2,2)*se.ranef(M1)$county[26]

  # 95% CI for the error in the intercept in county 26
as.matrix(ranef(M1)$county)[26] + c(-2,2)*se.ranef(M1)$county[26]

  # to plot Figure 12.4
a.hat.M1 <- coef(M1)$county[,1]                # 1st column is the intercept
b.hat.M1 <- coef(M1)$county[,2]                # 2nd element is the slope

par (mfrow=c(2,4))
for (j in display8){
  plot (x.jitter[county==j], y[county==j], xlim=c(-.05,1.05), ylim=y.range,
    xlab="floor", ylab="log radon level", main=uniq[j],cex.lab=1.2,
    cex.axis=1.1, pch=20, mgp=c(2,.7,0), xaxt="n", yaxt="n", cex.main=1.1)
  axis (1, c(0,1), mgp=c(2,.7,0), cex.axis=1)
  axis (2, c(-1,1,3), mgp=c(2,.7,0), cex.axis=1)
  curve (coef(lm.pooled)[1] + coef(lm.pooled)[2]*x, lty=2, col="gray10", add=TRUE)
  curve (coef(lm.unpooled)[j+1] + coef(lm.unpooled)[1]*x, col="gray10", add=TRUE)
  curve (a.hat.M1[j] + b.hat.M1[j]*x, lwd=1, col="black", add=TRUE)
}  

## Multilevel model ests vs. sample size 
a.se.M1 <- se.coef(M1)$county

par (mar=c(5,5,4,2)+.1)
plot (sample.size.jittered, t(a.hat.M1), cex.lab=1.2, cex.axis=1.1,
  xlab="sample size in county j", ylab=expression (paste
  ("est. intercept, ", alpha[j], "   (multilevel model)")),
  pch=20, log="x", ylim=c(.15,3.5), yaxt="n", xaxt="n")
axis (1, c(1,3,10,30,100), cex.axis=1.1)
axis (2, seq(0,3), cex.axis=1.1)
for (j in 1:J){
  lines (rep(sample.size.jittered[j],2),
    as.vector(a.hat.M1[j]) + c(-1,1)*a.se.M1[j], lwd=.5, col="gray10")
}
abline (coef(lm.pooled)[1], 0, lwd=.5)






