
########Lecture20
## Get the county-level predictor
srrs2.fips <- srrs2$stfips*1000 + srrs2$cntyfips
cty <- read.table ("/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/lecture/R-script/lecture20/cty.dat", header=T, sep=",")
usa.fips <- 1000*cty[,"stfips"] + cty[,"ctfips"]
usa.rows <- match (unique(srrs2.fips[mn]), usa.fips)
uranium <- cty[usa.rows,"Uppm"]
u <- log (uranium)





model w/ group-level predictors
u.full <- u[county]
M2 <- lmer (y ~ x + u.full + (1 | county))
display (M2)

coef (M2)
fixef (M2)
ranef (M2)

## Plots on Figure 5
M1 <- lmer (y ~ x + (1 | county))
a.hat.M1 <- fixef(M1)[1] + ranef(M1)$county                
b.hat.M1 <- fixef(M1)[2]

a.hat.M2 <- fixef(M2)[1] + fixef(M2)[3]*u + ranef(M2)$county
b.hat.M2 <- fixef(M2)[2]

par (mfrow=c(2,4), mar=c(4,4,3,1), oma=c(1,1,2,1))
for (j in display8){
  plot (x.jitter[county==j], y[county==j], xlim=c(-.05,1.05), ylim=y.range,
    xlab="floor", ylab="log radon level", cex.lab=1.2, cex.axis=1.1,
    pch=20, mgp=c(2,.7,0), xaxt="n", yaxt="n", cex.main=1.1, main=uniq[j])
  axis (1, c(0,1), mgp=c(2,.7,0), cex.axis=1.1)
  axis (2, seq(-1,3,2), mgp=c(2,.7,0), cex.axis=1.1)
  curve (a.hat.M1[j,] + b.hat.M1*x, lwd=.5, col="gray10", add=TRUE)
  curve (a.hat.M2[j,] + b.hat.M2*x, lwd=1, col="black", add=TRUE)
}


# Plot of ests & se's vs. county uranium (Figure 12.6)
a.se.M2 <- se.coef(M2)$county

par (mar=c(5,5,4,2)+.1)
plot (u, t(a.hat.M2), cex.lab=1.2, cex.axis=1.1,
      xlab="county-level uranium measure", ylab="est. regression intercept", pch=20,
      ylim=c(0.5,2.0), yaxt="n", xaxt="n", mgp=c(3.5,1.2,0))
axis (1, seq(-1,1,.5), cex.axis=1.1, mgp=c(3.5,1.2,0))
axis (2, cex.axis=1.1, mgp=c(3.5,1.2,0))
curve (fixef(M2)["(Intercept)"] + fixef(M2)["u.full"]*x, lwd=1, col="black", add=TRUE)
for (j in 1:J){
  lines (rep(u[j],2), a.hat.M2[j,] + c(-1,1)*a.se.M2[j,], lwd=.5, col="gray10")
}



##########################
######Lecture 20##########
##########################
## Varying intercept & slopes w/ no group level predictors
M3 <- lmer (y ~ x + (1 + x | county))
display (M3)

coef (M3)
fixef (M3)
ranef (M3)

 # plots on Figure 1
a.hat.M3 <- fixef(M3)[1] + ranef(M3)$county[,1] 
b.hat.M3 <- fixef(M3)[2] + ranef(M3)$county[,2]

b.hat.unpooled.varying <- array (NA, c(J,2))
for (j in 1:J){
  lm.unpooled.varying <- lm (y ~ x, subset=(county==j))
  b.hat.unpooled.varying[j,] <- coef(lm.unpooled.varying)
}

lm.pooled <- lm (y ~ x)

par (mfrow=c(2,4), mar=c(4,4,3,1), oma=c(1,1,2,1))
for (j in display8){
  plot (x.jitter[county==j], y[county==j], xlim=c(-.05,1.05), ylim=y.range,
    xlab="floor", ylab="log radon level", cex.lab=1.2, cex.axis=1.1,
    pch=20, mgp=c(2,.7,0), xaxt="n", yaxt="n", cex.main=1.1, main=uniq[j])
  axis (1, c(0,1), mgp=c(2,.7,0), cex.axis=1.1)
  axis (2, seq(-1,3,2), mgp=c(2,.7,0), cex.axis=1.1)
  curve (coef(lm.pooled)[1] + coef(lm.pooled)[2]*x, lwd=.5, lty=2, col="black", add=TRUE)
  curve (b.hat.unpooled.varying[j,1] + b.hat.unpooled.varying[j,2]*x, lwd=.5, col="black", add=TRUE)
  curve (a.hat.M3[j] + b.hat.M3[j]*x, lwd=1, col="red", add=TRUE)
}


########################################
#####Multi-level logistic regression
########################################

## Read the data & define variables
# Data are at http://www.stat.columbia.edu/~gelman/arm/examples/election88

# Set up the data for the election88 example

# Load in data for region indicators
# Use "state", an R data file (type ?state from the R command window for info)
#
# Regions:  1=northeast, 2=south, 3=north central, 4=west, 5=d.c.
# We have to insert d.c. (it is the 9th "state" in alphabetical order)

library ("arm")
data (state)                  # "state" is an R data file
state.abbr <- c (state.abb[1:8], "DC", state.abb[9:50])
dc <- 9
not.dc <- c(1:8,10:51)
region <- c(3,4,4,3,4,4,1,1,5,3,3,4,4,2,2,2,2,3,3,1,1,1,2,2,3,2,4,2,4,1,1,4,1,3,2,2,3,4,1,1,3,2,3,3,4,1,3,4,1,2,4)

# Load in data from the CBS polls in 1988
# Data are at http://www.stat.columbia.edu/~gelman/arm/examples/election88
library (foreign)
polls <- read.dta ("/Users/devito.roberta/Google Drive_brown/tutto/teaching/DS2020_2021/lecture/R-script/lecture20/polls.dta")
attach.all (polls)

# Select just the data from the last survey (#9158)
table (survey)                # look at the survey id's
ok <- survey==9158            # define the condition
polls.subset <- polls[ok,]    # select the subset of interest
attach.all (polls.subset)     # attach the subset
write.table (polls.subset, "/Users/devito.roberta/Google Drive/tutto/classDS2020/dataset/polls.subset.dat")

print (polls.subset[1:5,])

# define other data summaries
y <- bush                  # 1 if support bush, 0 if support dukakis
n <- length(y)             # of survey respondents
n.age <- max(age)          # of age categories
n.edu <- max(edu)          # of education categories
n.state <- max(state)      # of states
n.region <- max(region)    # of regions

# compute unweighted and weighted averages for the U.S.
ok <- !is.na(y)                                    # remove the undecideds
cat ("national mean of raw data:", round (mean(y[ok]==1), 3), "\n")
cat ("national weighted mean of raw data:",
     round (sum((weight*y)[ok])/sum(weight[ok]), 3), "\n")

# compute weighted averages for the states
raw.weighted <- rep (NA, n.state)
names (raw.weighted) <- state.abbr
for (i in 1:n.state){
  ok <- !is.na(y) & state==i
  raw.weighted[i] <- sum ((weight*y)[ok])/sum(weight[ok])
}

# load in 1988 election data as a validation check
election88 <- read.dta ("/Users/devito.roberta/Google Drive/tutto/classDS2020/dataset/election88.dta")
outcome <- election88$electionresult

# load in 1988 census data
census <- read.dta ("/Users/devito.roberta/Google Drive/tutto/classDS2020/dataset/census88.dta")

# also include a measure of previous vote as a state-level predictor
presvote <- read.dta ("/Users/devito.roberta/Google Drive/tutto/classDS2020/dataset/presvote.dta")
attach (presvote)
v.prev <- presvote$g76_84pr
not.dc <- c(1:8,10:51)
candidate.effects <- read.table ("/Users/devito.roberta/Google Drive/tutto/classDS2020/dataset/candidate_effects.dat", header=T)
v.prev[not.dc] <- v.prev[not.dc] +
 (candidate.effects$X76 + candidate.effects$X80 + candidate.effects$X84)/3
# Data are at http://www.stat.columbia.edu/~gelman/arm/examples/election88


## Multilevel logistic regression
M1 <- lmer (y ~ black + female + (1 | state), family=binomial(link="logit"))
display (M1)
 
## A fuller model

 # set up the predictors
age.edu <- n.edu*(age-1) + edu
region.full <- region[state]
v.prev.full <- v.prev[state]

 # fit the model
M2 <- lmer (y ~ black + female + black:female + v.prev.full + (1 | age) + 
  (1 | edu) + (1 | age.edu) + (1 | state) + (1 | region.full), family=binomial(link="logit"))
display (M2)

### Fit the model in Bugs
data <- list ("n", "n.age", "n.edu", "n.state", "n.region",
 "y", "female", "black", "age", "edu", "state", "region", "v.prev")
inits <- function () {list(
  b.0=rnorm(1), b.female=rnorm(1), b.black=rnorm(1), b.female.black=rnorm(1),
  a.age=rnorm(n.age), a.edu=rnorm(n.edu),
  a.age.edu=array (rnorm(n.age*n.edu), c(n.age,n.edu)),
  a.state=rnorm(n.state), a.region=rnorm(n.region),
  sigma.age=runif(1), sigma.edu=runif(1), sigma.age.edu=runif(1),
  sigma.state=runif(1), sigma.region=runif(1))
}

params <- c ("b.0", "b.female", "b.black", "b.female.black",
   "a.age", "a.edu", "a.age.edu", "a.state", "a.region",
   "sigma.age", "sigma.edu", "sigma.age.edu", "sigma.state", "sigma.region")
 
attach.bugs (/Users/devito.roberta/Google Drive/tutto/classDS2020/dataset/M2.bugs)
