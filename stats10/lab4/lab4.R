#--------------------1-----------------
#a
pawnee <-read.csv("~/Desktop/stats10/lab4/pawnee.csv", header = TRUE)
head(pawnee)
dim(pawnee)
#b
set.seed(1337)
sample_index <- sample(541, size=30)
sample_pawnee <- pawnee[sample_index,]
head(sample_pawnee)
dim(sample_pawnee)
#c
mean(sample_pawnee$Arsenic)
p.hat<-mean(sample_pawnee$New_hlth_issue=="Y")
print(p.hat)
#d
#e
se <- sqrt(p.hat*(1-p.hat)/30)
z1<-qnorm(p=0.95)
z2<-qnorm(p=0.975)
z3<-qnorm(p=0.995)
p.hat+c(-1,1)*z1*se
p.hat+c(-1,1)*z2*se
p.hat+c(-1,1)*z3*se
#f
#g
mean(pawnee$New_hlth_issue=="Y")
#h
hist(pawnee$Arsenic, breaks=42,xaxt='n',prob=T, xlab="Arsenic", main="Arsenic level")
axis(side=1, at=seq(0,210,l=43), labels=seq(0,210,l=43))
boxplot(pawnee$Arsenic, ylab="Arsenic Level")

#-----------------2----------------
n <-30 # The sample size
N <-541# The population size
M <-1000 # Number of samples/repetitions# Create vectors to store the simulated proportions from each repetition.
phats <-numeric(M)# for sample proportions# Set the seed for reproduceability
set.seed(123)# Always set the seed OUTSIDE the for loop.# Now we start the loop. Let i cycle over the numbers 1 to 1000 (i.e., iterate 1000 times).
for(i in seq_len(M)){
  # The i-th iteration of the for loop represents a single repetition.# Take a simple random sample of size n from the population of size N.
  index <-sample(N,size=n)# Save the random sample in the sample_i vector.
  sample_i <-pawnee[index,]# Compute the proportion of the i-th sample of households with a new health issue.
  phats[i] <-mean(sample_i$New_hlth_issue == "Y")
}
#a
library(histogram)
hist(phats, probability = TRUE)
curve(dnorm(x,mean(phats),sd(phats)), add=TRUE)
#b
mean(phats)
sd(phats)
#c
p<-mean(pawnee$New_hlth_issue=="Y")
sd<-sqrt(p*(1-p)/30)

#---------------3------------------
#a
n<-30
N<-541
M<-1000
ahats <-numeric(M)
set.seed(123)
for(i in seq_len(M)){
 index <- sample(N, size=n)
 sample_i <- pawnee[index,]
 ahats[i] <- mean(sample_i$Arsenic)
}
#b
hist(ahats, probability = TRUE)
curve(dnorm(x,mean(ahats),sd(ahats)), add=TRUE)
#c
