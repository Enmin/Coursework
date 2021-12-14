rm(list=ls())
library(foreign)
library(ggplot2)
data <- read.dta('/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/lecture/lecture_4/pollution.dta')
head(data)
attach(data)
##########
###dummy variable
poorind <- ifelse(poor>14,1,0)

summary(lm(mort~so2+educ+nonw))

summary(lm(mort~so2+educ+nonw+poorind))

poorind2 <- ifelse(poor<15,1,0)

summary(lm(mort~so2+educ+nonw+poorind2))

poorindf <- as.factor(poorind)

cor_col <- ggplot(data = data, aes(x = nonw, y = mort, color=poorindf)) + geom_point()
cor_col <- cor_col + scale_x_continuous("Percent of non-white population in urbanized areas, 1960") + scale_y_continuous("Total age-adjusted mortality rate per 100,000")
cor_col <- cor_col + scale_color_discrete(name="Income", labels=c('1', '0'))
cor_col

##########
###interaction term
head(data)

housind <- ifelse(dens<4500,1,0)
housindf <- as.factor(housind)

cor_col2 <- ggplot(data = data, aes(x = dens, y = mort, color=housindf)) + geom_point()
cor_col2 <- cor_col2 + scale_x_continuous("Population per sq. mile in urbanized areas, 1960") + scale_y_continuous("Total age-adjusted mortality rate per 100,000")
cor_col2 <- cor_col2 + scale_color_discrete(name="H-facility", labels=c('1', '0'))
cor_col2

summary(lm(mort~so2+dens*hous))



###Questions 1
##In group: Can you try to use the indicator variable for the housing?  What will you get?




##########
###non-linearity
cor_nolin <- ggplot(data = data, aes(x = nonw, y = mort)) + geom_point() +
           geom_smooth(method="lm",formula= y~poly(x,1), color="red", se=FALSE) +
            geom_smooth(method="lm",formula= y~poly(x,2), color="blue", se=FALSE) +
            geom_smooth(method="lm",formula= y~poly(x,5), color="green", se=FALSE) 
cor_nolin <- cor_nolin + scale_x_continuous("Percent of non-white population in urbanized areas, 1960") + scale_y_continuous("Total age-adjusted mortality rate per 100,000")
cor_nolin <- cor_nolin + scale_color_discrete(name="Income", labels=c('1', '0'))
cor_nolin



cor_nolin2 <- ggplot(data = data, aes(x = nonw, y = mort)) + geom_point() + geom_smooth()
cor_nolin2 <- cor_nolin2 + scale_x_continuous("Percent of non-white population in urbanized areas, 1960") + scale_y_continuous("Total age-adjusted mortality rate per 100,000")
cor_nolin2 <- cor_nolin2 + scale_color_discrete(name="Income", labels=c('1', '0'))
cor_nolin2



 summary(lm(mort~so2+ poly(nonw,2) +educ))

###Questions 2
##In group: Can you transform now just the so2 covariates keeping the nonw and educ in a standard way? What will you get?

 
 
 
 
 ###############
#####diagnostics

plot(lm(mort~so2+educ+nonw))


##studentized residuals
library(MASS)
fit <- lm(mort~so2+educ+nonw)
sres <- studres(fit)
res <- resid(fit)
str(fit)

fitt <- fit$fitted.values

plot(fitt, res,   ylab="Residuals", xlab="Fitted Values")


par(mfrow=c(1,2))
plot(fitt, res,   ylab="Residuals", xlab="Fitted Values")
plot(fitt, sres,   ylab="Studentized Residuals", xlab="Fitted Values")

 
###Questions 3
##In group: Can you now perform the diagnostic check with a model that includes so2, educ, nonw and poor?
##Put the residualized standardized plot that you are obtaining with this model with the old one.



 