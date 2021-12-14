
rm(list=ls())
library(foreign)
library(ggplot2)
library(boot)
library(tidyverse)
library(caret)
library(GGally)
library(scales)

## problem 1
data <- read.csv('earnings.csv')
head(data)
attach(data)

df1 <- data %>% select(education,mother_education,father_education,walk,exercise,tense,angry,weight,height)
colnames(df1) <-c("Education","Mot._education","Fat._education",
                  "Walk","Exercise","Tense","Angry","Weight","Height")
p1 <- ggcorr(df1, label = TRUE, low = "#6D9EC1", mid = "white", high = "#E46726") 
p1

## Problem 2
model <- lm(earn~height)
summary(model)
df2 <- data %>% filter(earn < 2e+05)
p2 <- ggplot(data = df2, aes(x = height, y = earn)) + geom_point(alpha = 0.5)
p2 <- p2 + geom_smooth(method = "lm", se = FALSE, color='red') 
p2 <- p2 + theme_bw() +
  scale_x_continuous(name="Height") +
  scale_y_continuous(name="Earnings")
p2

## Problem 3
p3 <- qplot(sample = earn, color=as.factor(male), shape=as.factor(male))
p3 <- p3 + theme_classic() + 
  scale_x_continuous(name = "Theoretical") +
  scale_y_continuous(name = "Sample",limits=c(0, 4e+05),breaks = c(0,1e+05,2e+05,3e+05,4e+05),
                     labels = function(x) format(x, scientific = TRUE)) +
  scale_colour_discrete(name = 'Gender',
                      breaks=c("0", "1"),
                      labels=c("Female", "Male")) +
  scale_shape_discrete(name = 'Gender',
                       breaks=c("0", "1"),
                       labels=c("Female", "Male"))
p3

# Problem 4
## forward selection
df4 <- na.omit(data)
fit1 <- lm(earn~., data= df4)
fit2 <- lm(earn ~ 1, data=df4)
mod_forward <- stepAIC(fit2,direction="forward",scope=list(upper=fit1,lower=fit2))
summary(mod_forward)

## backward selection
fit3 <- lm(earn~., data = df4)
mod_back <- step(fit3, direction= 'backward')
summary(mod_back)


beta1 <- seq(0, 1000, 1)

rss <- function(beta, beta1, data){
  resid <- df4$earn - (beta[1]+beta1*df4$height+beta[3]*df4$male+
                       beta[4]*df4$education+beta[5]*df4$tense +beta[6]*df4$age)
  return(sum(resid^2))
}

results <- data.frame(beta1 = beta1,
                      rss = sapply(beta1, rss, beta = as.numeric(mod_back$coefficients)))
results %>% ggplot(aes(beta1, rss)) + geom_line() + 
  geom_line(aes(beta1, rss))

## Problem 5
boot <- 500
coef_boot <- matrix(NA, boot, 3)
for (i in 1:boot){	
  s_boot <- sample(c(1:dim(df4)[1]),dim(df4)[1], replace=T)
  data_boot <- df4[s_boot,]
  fit3 <- lm(earn~., data = data_boot)
  mod_back <- step(fit3, direction= 'backward')
  coef_boot[i,] <- mod_back$coefficients[2:4]
}
coef_boot <- data.frame(value = c(coef_boot[,1], coef_boot[,2], coef_boot[,3]), 
                        beta = rep(c("beta_1","beta_2","beta_3"), each = 500))

p5 <- ggplot(coef_boot, aes(x = value)) + 
  geom_histogram(binwidth=300,color="black", fill="grey") + 
  facet_wrap(.~beta, ncol = 3) + 
  geom_vline(data=coef_boot, aes(xintercept=mean(value), color="red"), linetype="dashed")
p5 <- p5 + scale_x_continuous(limits = c(0, 15000)) +
  theme(legend.position="none")
p5
