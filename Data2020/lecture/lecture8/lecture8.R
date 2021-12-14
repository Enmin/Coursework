rm(list=ls())
library(ggplot2)
library(arm)

## Read the data

# The R codes & data files should be saved in the same directory for
# the source command to work
#install.packages('R2WinBUGS',dependencies=TRUE, repos='http://cran.rstudio.com/')
#library('R2WinBUGS')

###set the directory
#setwd('/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/lecture/R-script')

#source("4.7_Fitting.R") # where data was cleaned; set the directory to be where this file is
####put NO

#library(foreign)
#data <- read.dta('nes5200_processed_voters_realideo.dta')

#yr <- 1992
#nes.year <- data[,"year"]

#ok <- nes.year==yr & presvote<3
#vote <- presvote[ok] - 1
#income <- data$income[ok]
#black2 <- data$black[ok]
#age2 <-data$age[ok]
#sex2 <- data$sex[ok]
#edu <- data$educ1[ok]

#data_pool <- cbind(vote, income, black2, age2, sex2, edu)

#head(data_pool)
#save(data_pool, file='/Users/devito.roberta/dataPOOL.rda')

library(foreign)
load('/Users/devito.roberta/dataPOOL.rda')
head(data_pool)
income <- data_pool[,2]
vote <- data_pool[,1]
 # Estimation
fit.1 <- glm (vote ~ income, data=data.frame(data_pool), family=binomial(link="logit"))
summary(fit.1)

 # Graph figure 1 
 curve (invlogit(fit.1$coef[1] + fit.1$coef[2]*x), 1, 5, ylim=c(-.01,1.01),
         xlim=c(-2,8), xaxt="n", xaxs="i", mgp=c(2,.5,0),
         ylab="Pr (Republican vote)", xlab="Income", lwd=4)
  curve (invlogit(fit.1$coef[1] + fit.1$coef[2]*x), -2, 8, lwd=.5, add=T)
  axis (1, 1:5, mgp=c(2,.5,0))
  mtext ("(poor)", 1, 1.5, at=1, adj=.5)
  mtext ("(rich)", 1, 1.5, at=5, adj=.5)
  points (jitter(income, .5), jitter (vote, .08), pch=20, cex=.1)

 # Graph figure 2
sim.1 <- sim(fit.1)
curve (invlogit(fit.1$coef[1] + fit.1$coef[2]*x), .5, 5.5, ylim=c(-.01,1.01),
         xlim=c(.5,5.5), xaxt="n", xaxs="i", mgp=c(2,.5,0),
         ylab="Pr (Republican vote)", xlab="Income", lwd=1)
  axis (1, 1:5, mgp=c(2,.5,0))
  mtext ("(poor)", 1, 1.5, at=1, adj=.5)
  mtext ("(rich)", 1, 1.5, at=5, adj=.5)
  points (jitter (income, .5), jitter (vote, .08), pch=20, cex=.1)



## Evaluation at the central income category
invlogit(-1.40 + 0.33*3)


## Evaluation at the mean
invlogit(-1.40 + 0.33*mean(income, na.rm=T))

## Interpret the coefficient, difference of 1 income corresponds to a positive difference of 8% in the
## prob of supporting Bush
invlogit(-1.40 + 0.33*3)- invlogit(-1.40 + 0.33*2)


## Divide by 4 rule: a difference of 1 income category corresponds to no more than 8% of positive difference in the
## prob of supporting Bush

0.33/4



########
###Q for groups
###Q 1 Can you do the same for the variable called black2? Which model do you prefer?

###Q 2 a difference of 1 black2 category correposnds to...



### model with more covariates
fit.3 <- glm (vote ~ income +  black2, family=binomial(link="logit"))
summary(fit.3)


