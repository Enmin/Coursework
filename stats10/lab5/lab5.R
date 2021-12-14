#-------------1----------------
#b
flint <-read.csv("~/Desktop/stats10/lab5/flint_2015.csv", header = TRUE)
n <- nrow(flint)
dangerous_lead_indicator <- (flint$Pb >= 15)
p_hat <- mean(dangerous_lead_indicator)
sd_sample<-sqrt(p_hat*(1-p_hat)/n)
p_hat
sd_sample
#c
p_null <- 0.10
se_null <- sqrt(p_null*(1-p_null)/n)
z_stat <- (p_hat-p_null)/se_null
se_null
z_stat
#d
p_value <- 1-pnorm(z_stat, sd=1, mean=0)
p_value
#g
prop.test(x=sum(dangerous_lead_indicator), n=n, p=0.1,alternative = "greater")
#h
prop.test(x=sum(dangerous_lead_indicator), n=n,p=0.1,alternative = "greater", conf.level = 0.99)

#---------------2--------------
#b
flint_north <- flint[flint$Region=="North",]
n_north <- nrow(flint_north)
flint_south <- flint[flint$Region == "South",]
n_south <- nrow(flint_south)
p_hat_north <- mean(flint_north$Pb>=15)
p_hat_south <-mean(flint_south$Pb>=15)
p_hat_pooled <- mean(flint$Pb >=15)
SE <- sqrt(p_hat_pooled*(1-p_hat_pooled)*(1/n_north + 1/n_south))
z_stat <- (p_hat_north-p_hat_south-0)/SE
z_stat
#c
p_value <- 2*(1-pnorm(z_stat, sd=1, mean=0))
p_value
#e
