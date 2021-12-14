rm(list=ls())
library(foreign)
library(ggplot2)
library(boot)
library(tidyverse)
library(factoextra)
library(RColorBrewer)
library(psych)


color <- brewer.pal(n = 8, name = "Set3")

data <- read.delim('data-final.csv',stringsAsFactors = FALSE)
df <- data[,1:50]
df <- df %>% 
  mutate_all(as.numeric) %>%  
  na.omit()

# scale the variable
df_s <- scale(df)

## PCA
PCA1 <- prcomp(df_s)
eigs <- PCA1$sdev^2
value <- eigs/sum(eigs)
value >= 0.10

# less is better because we want to reduce the dimensionality as much as we can
# I would only keep the first two components 
# because PCA less than 10% would be excluded

# barplot
pca_names <- colnames(PCA1$rotation)
df_pca_10 <- data_frame("pca" = pca_names[1:10], "value" = value[1:10])

p1 <- ggplot(df_pca_10, aes(x = reorder(pca, -value), y= value)) +
  geom_bar(stat="identity")
p1

p <- dim(PCA1$rotation)[1]
label <- colnames(df)
data_plot <- data.frame(Row =rep(1:p, times= 2), Col = rep(x=c('1', '2'), each=p), Y= matrix(c(PCA1$rotation[,1:2]), p*2, 1))
head(data_plot)

p2 <- ggplot(data_plot, aes(Col, Row)) + geom_tile(aes(fill=Y))
p2 <- p2 + scale_fill_gradient2(low="purple", mid = "white", high="blue")
p2 <- p2 + scale_y_discrete('',limits=label[1:p]) + theme_bw()
p2

# In the plot, you could see that if the color is dark purple, 
it means the loadings in the principle component(PC) is very high.
For example, the PC1 is really high in OPN5 and OPN8, and also PC2 is really high in CSN3 and CSN4.
Each component would explain the covariate in different dimensions. 

##### (b)
mod1 = factanal(df, factors=5, rotation="none")
mod1
mod2 = factanal(df, factors=5, rotation='varimax')
mod2
Lort_df=loadings(mod2)

# from the summary of the result, each factor explains part of the covariates and 
# it seems that the 5 factors are sufficient to explain all the covariate in the dataset.
# Thus, I would keep the five factors and would not add new factors.

p=dim(Lort_df)[1]
label <- colnames(df)
data_plot <- data.frame(Row =rep(1:p, times= 5), Col = rep(x=c('1', '2',"3","4","5"), each=p), Y= matrix(c(Lort_df[,1:5]), p*5, 1))
head(data_plot)

p3 <- ggplot(data_plot, aes(Col, Row)) + geom_tile(aes(fill=Y))
p3 <- p3 + scale_fill_gradient2(low=color[5], mid = "white", high=color[3])
p3 <- p3 + scale_y_discrete('',limits=label[1:p]) + 
  theme_bw()+
  scale_x_discrete(name="Factors")
p3


# the answer of factor analysis is not unique, the model could explain the variables by using fewer factors


## c
n <- 1000
samples <- 50
prop_var <- matrix(NA, n, 5)

for (i in 1:n){	
  s_boot <- sample(c(1:dim(df)[1]), samples, replace = TRUE)
  data_boot <- df[s_boot,]
  mod3 = factanal(data_boot, factors=5, rotation='none')
  x <- mod3$loadings
  vx <- colSums(x^2)
  temp <- vx/nrow(x)
  prop_var[i,] <- temp
}


