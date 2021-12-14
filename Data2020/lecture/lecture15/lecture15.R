
################
####Cluster
###############
rm(list=ls())
library(ggplot2)
library(cluster) 
library(factoextra)

df <- USArrests
head(df)
df <- na.omit(df)
df <- scale(df)

###distance
distance <- get_dist(df)
fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))



###two clusters
k2 <- kmeans(df, centers = 2, nstart = 25)
fviz_cluster(k2, data = df)

##in group perform kmenas cluster with 3, 4 groups and 5 groups. Discuss what you found and plot the results with a title
k3 <- kmeans(df, centers = 3, nstart = 25)
k4 <- kmeans(df, centers = 4, nstart = 25)
k5 <- kmeans(df, centers = 5, nstart = 25)

p1 <- fviz_cluster(k2, geom = "point", data = df) + ggtitle("k = 2")
p2 <- fviz_cluster(k3, geom = "point", data = df) + ggtitle("k = 3")
p3 <- fviz_cluster(k4, geom = "point", data = df) + ggtitle("k = 4")
p4 <- fviz_cluster(k5, geom = "point", data = df) + ggtitle("k = 5")

library(gridExtra)
grid.arrange(p1, p2, p3, p4, nrow = 2)


##number of cluster with ELbow
wss <- function(k) {
   kmeans(df, k, nstart = 10 )$tot.withinss
 }


#set.seed(123)
fviz_nbclust(df, kmeans, method = "wss")

##number of cluster with gap method
#set.seed(123)
gap_stat <- clusGap(df, FUN = kmeans, nstart = 25,
                     K.max = 10, B = 50)


fviz_gap_stat(gap_stat)

###############
####4 clusters
final <- kmeans(df, 4, nstart = 25)
fviz_cluster(final, data = df)

##another data set: order that
library(tidyverse)
library(dslabs)
#data("mnist_27")
#mnist_27$train %>% qplot(x_1, x_2, data = .)

#data("movielens")
#top <- movielens %>%
#  group_by(movieId) %>%
#  summarize(n=n(), title = first(title)) %>%
#  top_n(50, n) %>%
#  pull(movieId)


#x <- movielens %>% 
#  filter(movieId %in% top) %>%
#  group_by(userId) %>%
#  filter(n() >= 25) %>%
#  ungroup() %>% 
#  select(title, userId, rating) %>%
#  spread(userId, rating)

#row_names <- str_remove(x$title, ": Episode") %>% str_trunc(20)
#x <- x[,-1] %>% as.matrix()
#x <- sweep(x, 2, colMeans(x, na.rm = TRUE))
#x <- sweep(x, 1, rowMeans(x, na.rm = TRUE))
#rownames(x) <- row_names

#perform the distance and the Hierarchical clustering
#d <- dist(x)
#h <- hclust(d)
#plot(h, cex = 0.65, main = "", xlab = "")
#groups <- cutree(h, k = 10)

##see what movies is in each cluster
#names(groups)[groups==4]

#install.packages("mice")
# library(mice)

#df_x <- data.frame(x)
#imputed_Data <- mice(df_x)
#df_com <- complete(imputed_Data)
#save(df_com, file='df_com.rda')

#rownames(df_com) <- rownames(df_x)
#colnames(df_com) <- colnames(df_x)
#save(df_com, file='/Users/devito.roberta/Desktop/df_com.rda')

load('/Users/roberta/Desktop/lecture15/df_com.rda')
dim(df_x)
#In group perform the distance. How many clusters will you retain?
distance_x <- get_dist(df_com)
fviz_dist(distance_x, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))


fviz_nbclust(df_com, kmeans, method = "wss")
gap_stat <- clusGap(df_com, FUN = kmeans, nstart = 25,
                    K.max = 10, B = 50)


fviz_gap_stat(gap_stat)

k2_com <- kmeans(df_com, centers = 2, nstart = 50)
fviz_cluster(k2_com, data = df_com)


d <- dist(df_com)
h <- hclust(d)
plot(h, cex = 0.65, main = "", xlab = "")

groups <- cutree(h, k = 10)

##see what movies is in each cluster
names(groups)[groups==4]

