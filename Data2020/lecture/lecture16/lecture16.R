
library(tree)
#library (rpart)
library (ISLR)
library (MASS)
set.seed (1)
 
train = sample (1: nrow(Boston), nrow(Boston)/2)
Bos_train <- Boston[train,]
head(Boston)
head(Bos_train)
class(Bos_train$medv)
tree.boston =tree(medv~., data=Bos_train)
summary (tree.boston )

##cross-validation
plot(tree.boston )
text(tree.boston ,pretty =0)

##prune the tree
prune.boston =prune.tree(tree.boston ,best =5)
plot(prune.boston )
text(prune.boston ,pretty =0)

##prediction
yhat=predict (tree.boston ,newdata =Boston [-train ,])
boston.test=Boston [-train ,'medv']
plot(yhat, boston.test)
abline(0,1)
mean((yhat -boston.test)^2)


##Divide in group: increase the training sample size with 450 units, what would you discover? will you improve the prediction error or not?
