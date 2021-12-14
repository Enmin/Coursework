rm(list=ls())

setwd('/Users/devito.roberta/Desktop/class')

attach(ability.cov)


names(ability.cov)


ability.cov$cov



##################
#####without rotation

#with one factor
mod1=factanal(covmat=ability.cov, factors=1, rotation="none")
mod1

#divide in group now perform a factor analysis with two factor, Q in prismia




########plot with varimax
Lort=loadings(factanal(covmat=ability.cov, factors=2, rotation="varimax"))
L
dev.new(width=30, height=30)
eqscplot(Lort, xlim=c(-1,1),ylim=c(-1,1), pch=19)
abline(h=0,v=0)
abline(a=0, b=(0.939/0.627), lty="dashed")
abline(a=0, b=(-0.118/1.123), lty="dashed")
identify(Lort[,1], Lort[,2],labels=dimnames(Lort)[[1]], cex=4)

library(GPArotation)
L_obli = oblimin(L, Tmat=diag(ncol(L)), gam=0, normalize=FALSE, eps=1e-5, maxit=1000)$loadings

dev.new(width=30, height=30)
eqscplot(L_obli, xlim=c(-1,1),ylim=c(-1,1), pch=19)
abline(a=0, b=(0.939/0.627), lty="dashed")
 abline(a=0, b=(-0.118/1.123), lty="dashed")
identify(Lort[,1], Lort[,2],labels=dimnames(Lort)[[1]], cex=4)

##############################
########Boston Housing########
###############################
