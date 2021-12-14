rm(list=ls())
library(foreign)
library(ggplot2)
library(MASS)
data <- read.dta('/Users/roberta/Desktop/pollution.dta')
head(data)
attach(data)



poorind <- ifelse(poor>14,1,0)

summary(lm(mort~so2+educ+nonw))
summary(lm(mort~so2+educ+nonw+poorind))
AIC(lm(mort~so2+educ+nonw))
BIC(lm(mort~so2+educ+nonw))
AIC(lm(mort~so2+educ+nonw+poorind))
BIC(lm(mort~so2+educ+nonw+poorind))



fit1 <- lm(mort~., data= data)

mod_back <- step(fit1, direction= 'backward')
summary(mod_back)


fit1 <- lm(mort~., data= data)
fit2 <- lm(mort ~ 1, data=data)
mod_forward <- stepAIC(fit2,direction="forward",scope=list(upper=fit1,lower=fit2))


summary(mod_forward)


###Questions 1 coding (Q4 in prismia)
##Divide in group: can you check the AIC and BIC of the forward and backward procedure? Which model will you choose for AIC and BIC?

###Questions 2 coding (Q5 in prismia)
##Divide in group: can you re-do the backward and forward procedure considering poor as outcome insetad of mortality?
##What selection procedure would you prefer?

