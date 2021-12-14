rm(list=ls())
library(foreign)
library(ggplot2)
library(tidyverse)
library(haven)
library(MASS)

library(dplyr)
library(ISLR)
library(glmnet)
library(arm)
library(coefplot)
library(factoextra)
library(caret)
library(RColorBrewer)
library(corrplot)
library(neuralnet)

color <- brewer.pal(n = 8, name = "Set3")
vars <- c("p5i1a", "p5i1b", "p5i1c", "p5i1d", "p5i1e", "p5i1f", "p5i1g", "p5i1h","p5i1i", "p5i1j", 
          "p5i2a", "p5i2b", "p5i2c", "p5i2e", "p5i3", "p5i4", "p5i5", "p5i6", "p5i7", "p5i8", "p5i23", 
          "p5i24", "p5i25", "p5i29", "t5b1h", "t5b1r", "m5e9_5", "t5b2c", "t5b1aa", "t5b3a",
          "t5b3b", "t5b3c", "t5b3d", "t5b3e", "t5b3f", "t5b3g", "t5b3h", "t5b3i", "t5b3j", 
          "t5b3k", "t5b3l", "k5g2e",
          #father features
          "p5i31d", "p5i31b" ,"p5i31a", "p5i31c", "p5i31e","p5i31f", "p5i31g", "p5i31h",
          "p5i31i", "p5i31j" ,"p5i32a", "p5i32c", "p5i33a", "p5i33b", "p5i34",  "p5i37",
          "k5a2c", "k5a2d", "k5a2e", "k5a2f", "k5a3b", "k5a3c", "k5a3d", "k5a3e", "k5a3f",
          "k5b1a", "k5c0","k5d1a", "k5d1b", "k5d1e", "k5d1f", "k5d1g", "k5e1b", "k5e1c", "k5e2a", "k5e2d",
          "k5g2b", "k5g2g", "k5g2k"
)
data = read_dta('/home/enminz/Graduate/Data-2020/Final/FFdata/wave5/FF_wave5_2020v2_Stata/FF_wave5_2020v2.dta', col_select = vars)

data[data<0] <- NA
df <- data.matrix(data) %>% na.omit()
df_x_before_scale <- df[, colnames(df)!='k5g2e']
fa_model <- factanal(df_x_before_scale, factors=5, rotation='varimax')
y <- df[, 'k5g2e']
y[y>0] <- 1
df_x <- df[, colnames(df)!='k5g2e']
df_x <- scale(df_x)
dataPCA <- prcomp(df_x)
p1 <- fviz_eig(dataPCA)
df_PCA_x <- dataPCA$x[, 1:80]
var <- get_pca_var(dataPCA)
#corrplot(var$contrib, is.corr=FALSE)
fviz_contrib(dataPCA, choice = "var", axes = 1, top = 10, fill = color[3], color = color[3])
fviz_contrib(dataPCA, choice = "var", axes = 2, top = 10, fill = color[3], color = color[3])
fviz_contrib(dataPCA, choice = "var", axes = 3, top = 10, fill = color[3], color = color[3])

df_train <- cbind(df_x, y)



train.control_kcv <- trainControl(method = "cv", number = 10)
# Train the model
model_kcv <- train(as.factor(y)~., data = df_train, method = "glm", trControl = train.control_kcv, family='binomial')
# Summarize the results
print("K-fold CV")
print(model_kcv)


rf_model <- train(as.factor(y)~., data=df_train, method="rf", 
                    tuneLength = 15, metric="Accuracy", trControl=train.control_kcv)
print(rf_model)
plot(rf_model)

set.seed(2)
NN = neuralnet(as.factor(y) ~. , df_train, hidden = 3 , linear.output = T )
plot(NN)
