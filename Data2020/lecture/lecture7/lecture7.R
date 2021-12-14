rm(list=ls())
library(foreign)
library(ggplot2)
library(boot)
library(tidyverse)
library(caret)


#####load the data
data <- read.dta('/Users/roberta/Desktop/pollution.dta')
head(data)
attach(data)
cor(data$poor, data$mort)


####################Bootstrap
####################two methods
####################1 method, with cycle for

###the sample size of our data is really small, let's try to reproduce it with 500


boot <- 500
mean_boot <- matrix(NA, boot, 1)

for (i in 1:boot){	
	s_boot <- sample(c(1:dim(data)[1]),dim(data)[1], replace=T)
	data_boot <- data[s_boot,]
	mean_boot[i,] <- mean(data_boot$poor) 	
}

hist(mean_boot) #you can also do by ggplot
mean(data$poor)

###Questions 1: Q4 in prismia
##Divide in group: can you bootstrapped 1000 sample with method 1 the correlation between poor and mort?
##check the mean and sd of your bootstrapped samples


####2 method, with the function boot 
 
fc <- function(d, i){
	d2 <- data[i,]
	return(cor(d2$mort, d2$poor))
}
bootcorr <- boot(data, fc, R=500)
bootcorr
summary(bootcorr)
plot(bootcorr)
###t is the bootstrap samples and t_0 your original statistics

mean(bootcorr$t)
sd(bootcoor$t)
hist(bootcorr$t)
#####you can plot in ggplot as well

###Questions 2: Q6
##Divide in group: can you bootstrapped 1000 sample with method 2 the mean of the poor variable?
##check the mean and sd of your bootstrapped samples


####################Cross-validation
####################80% for the training and 20 % for the test set
training.samples <- data$mort %>%
  createDataPartition(p = 0.8, list = FALSE)
train.data  <- data[training.samples, ]
test.data <- data[-training.samples, ]
# Build the model
model <- lm(mort~so2+educ+nonw, data = train.data)
# Make predictions and compute the R2, RMSE (root mean square error, obs - fitted) and MAE (average absolute difference between actual-pred)
predictions <- model %>% predict(test.data)
data.frame( R2 = R2(predictions, test.data$mort),
            RMSE = RMSE(predictions, test.data$mort),
            MAE = MAE(predictions, test.data$mort))

###Questions 3: Q7 in prismia
##Divide in group: Do the same cross validation with 
##80% for training and 20% for the test, including in the 
##model the variable poor. What model do you prefer in term 
##of prediction? 


            
####################Leave one out cross validation - LOOCV
#This method works as follow:
# 1.	Leave out one data point and build the model on the rest of the data set
# 2. Test the model against the data point that is left out at step 1 and record the test error associated with the prediction
# 3.	Repeat the process for all data points
# 4.	Compute the overall prediction error by taking the average of all these test error estimates recorded at step 2.

train.control <- trainControl(method = "LOOCV")
# Train the model
model <- train(mort~so2+educ+nonw, data = data, method = "lm",
               trControl = train.control)
# Summarize the results
print(model)         


#However, the process is repeated as many times as there are data points, resulting to a higher execution time when n is extremely large.
#Additionally, we test the model performance against one data point at each iteration. This might result to higher variation in the prediction error, if some data points are outliers. So, we need a good ratio of testing data points, a solution provided by the k-fold cross-validation method.
###Questions 4: Q 8 in prismia
##Divide in group: Do the LOOCV for the mdoel that contains the poverty as predictors. What model do you prefer in term of prediction? 


####################k-fold cross-validation
#The k-fold cross-validation method evaluates the model performance on different subset of the training data and then calculate the average prediction error rate. The algorithm is as follow:
#	1.	Randomly split the data set into k-subsets (or k-fold) (for example 5 subsets)
#	2.	Reserve one subset and train the model on all other subsets
#	3.	Test the model on the reserved subset and record the prediction error
#	4.	Repeat this process until each of the k subsets has served as the test set.
#	5.	Compute the average of the k recorded errors. This is called the cross-validation error serving as the performance metric for the model.
#K-fold cross-validation (CV) is a robust method for estimating the accuracy of a model.
#The most obvious advantage of k-fold CV compared to LOOCV is computational. A less obvious but potentially more important advantage of k-fold CV is that it often gives more accurate estimates of the test error rate than does LOOCV (James et al. 2014).
#Typical question, is how to choose right value of k?
#Lower value of K is more biased and hence undesirable. On the other hand, higher value of K is less biased, but can suffer from large variability. It is not hard to see that a smaller value of k (say k = 2) always takes us towards validation set approach, whereas a higher value of k (say k = number of data points) leads us to LOOCV approach.
#In practice, one typically performs k-fold cross-validation using k = 5 or k = 10, as these values have been shown empirically to yield test error rate estimates that suffer neither from excessively high bias nor from very high variance.
#The following example uses 10-fold cross validation to estimate the prediction error. Make sure to set seed for reproducibility.


train.control <- trainControl(method = "cv", number = 10)
# Train the model
model <- train(mort~so2+educ+nonw, data = data, method = "lm",
               trControl = train.control)
# Summarize the results
print(model)


###Questions 5
##Divide in group: Do the k-fold cross-validation for the model that contains the poverty as covariate. What model do you prefer in term of prediction? 



#if you want to repeat and perform a Repeated K-fold cross-validation, use repeat
#train.control <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
#model <- train(mort~so2+educ+nonw, data = data, method = "lm", trControl = train.control)
#print(model)




