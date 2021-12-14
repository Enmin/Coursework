rm(list=ls())
library(foreign)
library(ggplot2)
data <- read.dta('/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/lecture/lecture_4/pollution.dta')
head(data)
attach(data)



################
###correlation test
cor(mort, nonw)
cor.test(mort, nonw)
cor.test(mort, nonw, method="spearman")



###Questions 1
##Divide in group: can you check the pearson correlation between mortality and the three air pollutants (hc,nox, so2)?
##What is the significant one? and the higher?


###Question 2
###Which variables will you use in the regression model?



#################
###cor plot
cor <- ggplot(data = data, aes(x = nonw, y = mort)) + geom_point(color='blue')
cor


fit <- lm(mort~nonw)
summary(fit)
predicted <- predict(fit)
mean(mort)


#################
###cor plot with regression line
cor1 <- ggplot(data = data, aes(x = nonw, y = mort)) + geom_point(color='blue')
cor1 <- cor1 + geom_smooth(method = "lm", se = FALSE, color='red') 
#pdf("/Users/devito.roberta/Google Drive/tutto/classDS2020/lecture_4/fig/cor1.pdf", width=8, height=6)
cor1
#dev.off()



#################
###cor plot with regression line and error term
cor2 <- ggplot(data = data, aes(x = nonw, y = mort)) + geom_point(color='blue') 
cor2 <- cor2 + geom_smooth(method = "lm", se = FALSE,color='red') + geom_segment(aes(xend = nonw, yend = predicted), alpha = .2) 
cor2


###Question 3
###Divide in groups: can you do the same with so2 as covariates and mort as outcome?
###What is the beat for so2? What does it mean? Is it significant?

