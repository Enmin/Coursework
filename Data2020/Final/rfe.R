ls(list())

#install.packages("factoextra")
library(devtools)
library(tidyverse)
library(haven)
library(dplyr)
library(assertive)
library(factoextra)
library(tree)
library (ISLR)
library (MASS)
library(mlbench)
library(caret)
library(e1071)
set.seed (1)

getwd()
setwd("D:/2021 spring/DATA2020/Final")
data <- read_dta("FF_wave5_2020v2.dta")

colnames(data)

#select variables
vars <- c("p5i1a", "p5i1b", "p5i1c", "p5i1d", "p5i1e", "p5i1f", "p5i1g", "p5i1h","p5i1i", "p5i1j", 
          "p5i2a", "p5i2b", "p5i2c", "p5i2e", "p5i3", "p5i4", "p5i5", "p5i6", "p5i7", "p5i8", "p5i23", 
          "p5i24", "p5i25", "p5i29", "t5b1h", "t5b1aa", "t5b1r", "m5e9_5", "t5b2c", "t5b1aa", "t5b3a",
          "t5b3b", "t5b3c", "t5b3d", "t5b3e", "t5b3f", "t5b3g", "t5b3h", "t5b3i", "t5b3j", 
          "t5b3k", "t5b3l", "k5g2e",
          #father features
          "p5i31d", "p5i31b" ,"p5i31a", "p5i31c", "p5i31e","p5i31f", "p5i31g", "p5i31h",
          "p5i31i", "p5i31j" ,"p5i32a", "p5i32c", "p5i33a", "p5i33b", "p5i34",  "p5i37",
          "k5a2c", "k5a2d", "k5a2e", "k5a2f", "k5a2f", "k5a3b", "k5a3c", "k5a3d", "k5a3e", "k5a3f",
          "k5b1a", "k5c0","k5d1a", "k5d1b", "k5d1e", "k5d1f", "k5d1g", "k5e1b", "k5e1c", "k5e2a", "k5e2d",
          "k5g2b", "k5g2g", "k5g2k"
          #therapy
         # "t5c7g", "t5c7i", "t5c7m"
)

df <- data[vars]


dim(df) 
head(df)

#check data type
glimpse(df)


#remove the strings here
df[] <- lapply(df, function(x) as.numeric(x))
df <- data.frame(df)
dim(df)
head(df)

names(df)[names(df) == "k5g2e"] <- "lonely"

#convert negative number to NA
df[df < 0] <- NA
df <- na.omit(df)
dim(df)

df1 <- df

df1$lonely[df1$lonely >0] <- 1
#df1 <- lapply(df1, function(x) as.factor(x))
#df1 <- data.frame(df1)

train = sample (1: nrow(df1), nrow(df1)*2/3)
df_train <- df1[train,]
head(df_train)
class(df_train$lonely)


#train rf with random search parameters
control <- trainControl(method="repeatedcv", repeats = 3, number=3, search = 'random')
seed <- 7
metric <- "Accuracy"
set.seed(seed)
rf_default <- train(as.factor(lonely)~., data=df_train, method="rf",
                    tuneLength = 15, metric=metric, trControl=control)

print(rf_default)
plot(rf_default, main="Accuracy with different mtry",
     ylab="accuracy", xlab='mtry')

pred <- predict(rf_default, newdata = df1[-train,][, colnames(df)!='lonely'])
label <- df1[-train, ]$lonely
sum(pred == label)/dim(df1[-train,])[1]


#feature selection
set.seed(10)

x <- df_train[, colnames(df)!='lonely']
y <- df_train$lonely




subsets <- c(1,10, 20,40,60, 65, 70, 75, 80)

ctrl <- rfeControl(functions = rfFuncs,
                   method = "repeatedcv",
                   repeats = 5,
                   verbose = F)

lmProfile <- rfe(x, as.factor(y),
                 sizes = subsets,
                 rfeControl = ctrl)

print(lmProfile)
predictors(lmProfile)
plot(lmProfile, type = c('g','o'))
lmProfile$fit



# Print the results visually
ggplot(data = lmProfile, metric = "Accuracy") + theme_bw()
ggplot(data = lmProfile, metric = "Kappa") + theme_bw()


result_rfe1 <- lmProfile

varimp_data <- data.frame(feature = row.names(varImp(result_rfe1))[1:15],
                          importance = varImp(result_rfe1)[1:15, 1])

ggplot(data = varimp_data, 
       aes(x = reorder(feature, -importance), y = importance, fill = feature)) +
  geom_bar(stat="identity") + labs(x = "Features", y = "Variable Importance") + 
  geom_text(aes(label = round(importance, 2)), vjust=1.6, color="white", size=4) + 
  theme_bw() + theme(legend.position = "none")

x_test <- df1[-train,][, colnames(df)!='lonely']
y_test <- df1[-train,]$lonely

postResample(predict(result_rfe1, x_test), as.factor(y_test))


##useful links
##random forest tuning method: https://machinelearningmastery.com/tune-machine-learning-algorithms-in-r/
#best tuning method: random select
##tuning parameters ntree, Mtry


##rfe: https://machinelearningmastery.com/feature-selection-with-the-caret-r-package/

