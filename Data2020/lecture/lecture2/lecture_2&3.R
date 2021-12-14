#################################
##########Les 2##################
#################################
rm(list=ls())

library(tidyverse)
library(dslabs)
data(heights)

#########
###see what you have
ls()
heights

##############
###see the dimension of the object
###and what you have at the beginning
dim(heights)
###Question:What is the dimension of this data matrix


head(heights)



##########
###how many female and male
table(heights$sex)

###also for height
table(heights$height)

###transform in binary
library(dslabs)
data(heights)
tab <- table(heights$height)
sum(tab==1)

mean(heights$height)
median(heights$height)
var(heights$height)
sd(heights$height)

###Questions 1
###Technically the height can be considered ordinal, which of the following is true:
###A It is more effective to consider heights to be numerical given the number of unique values we observe and even more we can potentially observe.
#B t is actually preferable to consider heights ordinal since on a computer there are only a finite number of possibilities
#C This is actually a categorical variable: tall, medium or short.


###Question 2
#Divide in Group:
#What proportion of the data is between 69 and 72 inches (taller than 69 but shorter or equal to 72)? Hint: a logical operator and mean.





################
##plot: start with the basics
library(ggplot2)

p<- ggplot(data=heights, aes(x=sex, y=height)) + 
  geom_bar(stat="identity")
p


p<- ggplot(data=heights, aes(x=sex, y=height, colour=sex)) + 
  geom_bar(stat="identity", fill='white')
p


p1<- ggplot(data=heights, aes(x=sex, y=height, colour=sex)) + 
  geom_bar(stat="identity")+theme_minimal()
p1 <- p1+ labs(x='', colour = "Ciao")
p1


p2<- ggplot(data=heights, aes(x=sex, y=height, colour=sex)) + 
  geom_bar(stat="identity")+theme_minimal()
p2 <- p2+ labs(x='', colour = "Gender")
p2


##divide in group: trasnform the name of Y with Capital letter

#################################
##########Les 3##################
#################################

#Suppose we can't make a plot and want to compare the distributions side by side. We can't just list all the numbers. Instead we will look at the percentiles. Create a five row table showing female_percentiles and male_percentiles with the 10th, 30th, 50th, ..., 90th percentiles for each sex. Then create a data frame with these two as columns.


library(dslabs)
data(heights)
male <- heights$height[heights$sex=="Male"]
male_percentiles <- quantile(male, seq(0.1, 0.9, 0.2))

#####Question 1
####divide in groups, can you do for female?
data.frame(female_percentiles, male_percentiles) 

#####Question 2
#####In which percentiles there is the maximum differences between the gender? 

####return to presentation

####Let's see the boxplot
p <- ggplot(heights, aes(x=sex, y=height)) + geom_boxplot()
p
# Rotate the box plot
p + coord_flip()
# Notched box plot
ggplot(heights, aes(x=sex, y=height)) + 
  geom_boxplot(notch=TRUE)

###Question 3
###divide in group, can you compute the median and see if it corresponds to the boxplots? What is the median in total? For the male? And for the female?


####return to presentation

head(heights)
ggplot(heights, aes(height)) + stat_ecdf(geom = "step")
ggplot(heights, aes(height)) + stat_ecdf(geom = "step")+
labs(title="Empirical Cumulative \n Density Function",
     y = "F(height)", x="Height in inch")+
theme_classic()


##Question 4
#Divide in group: Suppose all you know about the data is the average and the standard deviation. Use the normal approximation to estimate the proportion you just calculated.

data(heights)
x <- heights$height[heights$sex=="Male"]

avg <- mean(x)
stdev <- sd(x)
pnorm(71, avg, stdev) - pnorm(69, avg, stdev)

####qqplot
###is the distribution normal?
p <- seq(0.05, 0.95, 0.05)

sample_quantiles <- quantile(x, p, na.rm=TRUE)
theoretical_quantiles <- qnorm(p, mean = mean(x,na.rm=TRUE), sd = sd(x, na.rm=TRUE))

qplot(theoretical_quantiles, sample_quantiles) + geom_abline()




ggplot(heights, aes(x=height)) + geom_histogram(binwidth=.5)

##Question 5
##In group: adjust the bin to have a nice histogram

###let's do the curve
ggplot(heights, aes(x=height)) + geom_density(alpha=.3)

##Question 6
##Perform two different curves for sex, hint: use fill in the aes parameter





