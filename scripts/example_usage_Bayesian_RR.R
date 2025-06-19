# example usage for Bayesian parameterization of the 
# randomized response design
# using brms

# this script simulates a randomized response/crosswise model
# and then fits the model to recover the true latent trait

library(brms)
library(dplyr)
library(RRreg)
library(rr)

# confusion matrix
# we assume that the random variable has a probability of 0.25
# which equals first 3 months of the year if using crosswise
# design
P <- getPW("Warner",.25)

# load custom brms family

source("scripts/brms_sens_reg_basic.R")

# assume N = 800
N <- 800
# theta = true latent value we can't observe
# we'll fit one covariate X that predicts theta
X <- runif(N)
X_coef <- 1.5
theta <- plogis(X * X_coef)


obs_response <- as.numeric((P[2,1] * (1 - theta) + P[2,2]*theta)>runif(N))

out_data <- tibble(y = obs_response,
                   X=X)

# estimate model with brms
# remove backend='cmdstanr' if you don't have cmdstanr 
# installed (will use rstan instead)
# uses default priors, inspect these with get_prior()

est_mod_brms <- brm(y ~ X,
                    family=family_sens_reg,
                    stanvars=all_stanvars,
                    data=out_data,
                    chains=1,
                    cores=1,
                    iter=1000,
                    backend = "cmdstanr")

# see covariate effect

summary(est_mod_brms)

# use marginal effect to convert back to probability

library(marginaleffects)

avg_slopes(est_mod_brms, variables="X")

# pretty close to .3
# note that the confusion matrix adds random noise

# get estimate of theta (latent probability)

mu_trans <- posterior_epred(est_mod_brms) %>% apply(1,median)

summary(mu_trans)
mean(theta)

# pretty close

