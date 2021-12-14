###Principal component analysis

##load the data
wine <- read.table("http://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data", sep=",")

## give the name to the variable 
colnames(wine) <- c("Cvs","Alcohol","Malic acid","Ash","Alcalinity of ash", "Magnesium", "Total phenols", "Flavanoids", "Nonflavanoid phenols", "Proanthocyanins", "Color intensity", "Hue", "OD280/OD315 of diluted wines", "Proline")


## scale teh variable
wine_s <- scale(wine[,-1])

check <- colMeans(wine_s)
check

## graphical representation
wineClasses <- factor(wine$Cvs)
pairs(wine[,-1], col = wineClasses, upper.panel = NULL, pch = 16, cex = 0.5)
legend("topright", bty = "n", legend = c("Cv1","Cv2","Cv3"), pch = 16, col = c("black","red","green"),xpd = T, cex = 2, y.intersp = 0.5)



## PCA
winePCA <- prcomp(wine_s)
plot(winePCA$x[,1:2], col = wineClasses)
screeplot(winePCA)

## graphical visualization 2  
if (!requireNamespace("BiocManager", quietly = TRUE))
     install.packages("BiocManager")
BiocManager::install("pcaMethods")     
library(pcaMethods)
     
winePCAmethods <- pca(wine[,-1], scale = "uv", center = T, nPcs = 2, method = "svd")
slplot(winePCAmethods, scoresLoadings = c(T,T), scol = wineClasses)

##############################
########Boston Housing########
###############################




##Divide in Group: Open the data Boston Housing Perform the PCA for Boston Housing. Do the screeplot
##Q4: How many components will you retain?




##let's see the component

str(bostonPCA)
bostonPCA$rotation
plot(bostonPCA$rotation[,1:2])
plot(bostonPCA$rotation[,1:3])

##understand the number and the component
p=dim(bostonPCA$rotation)[1]
label <- colnames(boston_housing1)
data_plot <- data.frame(Row =rep(1:p, times= 3), Col = rep(x=c('1', '2', '3'), each=p), Y= matrix(c(bostonPCA$rotation[,1:3]), p*3, 1))
head(data_plot)

##divide in group
##can you think about a way to plot all the important components together?


##divide in group
##Try to change the color and to write the x axis
