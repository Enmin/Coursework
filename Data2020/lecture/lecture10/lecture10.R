rm(list=ls())
library(R2WinBUGS)
## Read in the data

setwd("/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/dataset")

police <- read.table("police.txt", header=T)
attach.all(police)
#PUT yes

##remove weird category
police2 <- police[-which(stops/past.arrests == Inf),]


head(police2)
## Model fitting

 # constant term

fit.1 <- glm (stops ~ 1, family=poisson)
summary(fit.1)

 # ethnicity indicator

fit.2 <- glm (police2$stops ~ factor(police2$eth), family=poisson, offset=log(police2$past.arrests))
summary(fit.2)

#####Question 1
###Divide in group can you use as covariate the variable crime. 
###1=violent crimes, 2=weapons offenses, 3=property crimes, 4=drug offenses
#Compared to the baseline category 1 (violent crimes), what is the percentage and the coefficient of being stopped for category 3 (property crimes)?


#ethnicity & precints indicators
fit.3 <- glm (police2$stops ~ factor(police2$eth) + factor(police2$precinct) , family=poisson, offset=log(police2$past.arrests))
summary(fit.3)

#########
# check the overdispersion
fit.4 <- glm (police2$stops ~ factor(police2$eth) + factor(police2$precinct) , family=quasipoisson, offset=log(police2$past.arrests))
summary(fit.4)
##1 way
plot(fit.4, which=1) 

#2way, compute by yourself
fitted.4 <- fitted(fit.4)
res.4 <- resid(fit.4)
pred.4 <- predict(fit.4)
stdres.4 = rstandard(fit.4)


plot(pred.4, res.4)

#####Question 2
##divide in group: make a better plot by using ggplot



#####Question 3
##divide in group: can you check now with the standardized residual value, will you get overdipersion or not?

