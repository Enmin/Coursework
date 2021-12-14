rm(list=ls())

library (tree)

load('/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/lecture/R-script/lecture17/dataPOOL.rda')

ls()
class(data_pool)
vote <- data_pool[,1]
#vote1 <- vote[!is.na(vote)]
vote_bin <- ifelse(vote==0,"Clinton","Bush")

head(data_pool)
class(data_pool)

data_df <- data.frame(data_pool, vote_bin)
head(data_df)
data_com <- data_df[complete.cases(data_df), ]
dim(data_com)
#data_com$vote2=ifelse(data_com$vote ==0,"No","Yes")
data_com$vote <- NULL
head(data_com)
tree_pool <- tree(vote_bin~., data=data_com)

summary(tree_pool)

plot(tree_pool)
text(tree_pool)
tree_pool



set.seed (2)
 train=sample (1:nrow(data_com), 590)
 pooltest <- data_com[-train,]
 vote_test <- data_com$vote_bin[-train]
 tree.pool <- tree(vote_bin~., data_com ,subset =train )
 tree.pred <- predict(tree.pool, pooltest, type ="class")
 table(tree.pred, vote_test)
(85+257)/590

#####Q7 Can you do better than this? How? Q in Prismia

####Divide in group: Q8 Increase the sample size ofthe training set of 1000, how much
## is percentage of the correct predictions in this case?

set.seed (3)
cv.pool <- cv.tree(tree_pool ,FUN=prune.misclass )
cv.pool

prune.pool <- prune.misclass(tree_pool, best=5)
 plot(prune.pool)
 text(prune.pool,pretty =0)
 tree.pred=predict(prune.pool, pooltest, type="class")
 table(tree.pred, vote_test)
(115+255)/590







