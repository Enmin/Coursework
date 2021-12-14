rm(list=ls())

library(plyr)
library(readr)
library(dplyr)

library(ISLR)
library(glmnet)

##the data
Hitters = na.omit(Hitters)
head(Hitters)

##prepare the x, trim off the 1st column
x = model.matrix(Salary~., Hitters)[,-1]
y = Hitters %>%
select(Salary) %>%
unlist() %>%
as.numeric()


###################
##ridge regression

###grid of different lambda
grid = 10^seq(10, -2, length = 100)
###ridge with different lambda
ridge_mod = glmnet(x, y, alpha = 0, lambda = grid)


##split teh data
train = Hitters %>%
sample_frac(0.5)

test = Hitters %>%
 setdiff(train)
 
x_train = model.matrix(Salary~., train)[,-1]
x_test = model.matrix(Salary~., test)[,-1]


y_train = train %>%
   select(Salary) %>%
   unlist() %>%
   as.numeric()

y_test = test %>%
   select(Salary) %>%
   unlist() %>%
   as.numeric()


##CV to choose the best lambda
set.seed(1)
## Fit ridge regression model on training data
cv.out = cv.glmnet(x_train, y_train, alpha = 0) 

## Select lamda that minimizes training MSE
bestlam = cv.out$lambda.min  

##re-fit the model with the besta lambda
out_ridge = glmnet(x, y, alpha = 0, lambda=bestlam)
predict(out_ridge, type = "coefficients", s = bestlam)[1:20,]
coef(out_ridge, s=bestlam)



######################################
##Q1: divide in group
##Perform a standard linear regression
##What are the coefficients you did not expect 
##to be shrinked by the ridge regression





###########
##The lasso
lasso_mod = glmnet(x_train, 
                   y_train, 
                   alpha = 1, 
                   lambda = grid)

plot(lasso_mod)

##CV 
set.seed(1)
# Fit lasso model on training data
cv.out = cv.glmnet(x_train, y_train, alpha = 1) 

# Select lambda that minimizes training MSE
bestlam = cv.out$lambda.min 

# Fit lasso model on full dataset
out = glmnet(x, y, alpha = 1, lambda = grid) 

# Display coefficients using lambda chosen by CV
lasso_coef = predict(out, type = "coefficients", s = bestlam)[1:20,] 
lasso_coef
lasso_mod <-  glmnet(x, y, alpha = 1)


###########
##Q2 In group: Display the output of ridge and lasso. what are the 3 coefficients with great difference between the two methods?



##useful for plot in ggplot
lasso.mod =glmnet(x,y, alpha =1)#this will give 80 values of lambda
beta=coef(lasso.mod)
plot(lasso.mod, "lambda", label = TRUE)

############
###Q3 Divide in group: 
##display in ggplot this plot obtained in R
