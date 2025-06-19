# define brms sensitive regression model

stan_funs <- '
  real sens_reg_lpmf(int y, real mu, matrix P) {
  
    // generalized RR model from van der Hout and van der Heijden (2002)
    // also see R package RRreg
    
    real out;
      
      if(y==1) {
      
        out = P[2,1] * (1 - mu) + P[2,2] * mu;
      
      } else if(y==0) {
      
       out = P[1,1]*(1-mu) + P[1,2]*mu;
      
      }
    
    return log(out); 

  }
  
  int sens_reg_rng(real mu, matrix P) {
  
  
      return bernoulli_rng(P[2,1] * (1 - mu) + P[2,2] * mu);

  }'

# define custom family

family_sens_reg <- custom_family("sens_reg",
                                 dpars=c("mu"),
                                 links=c("logit"),
                                 type="int",
                                 lb=c(NA),
                                 ub=c(NA),
                                 vars=c("P"))

# define log-likelihood

log_lik_sens_reg <- function(i, prep) {
  
  mu <- brms::get_dpar(prep, "mu", i = i)
  y <- prep$data$Y[i]
  treatment <- prep$data$vint1[i]
  
    if(y==1) {
      
      return(log(P[2,1] * (1 - mu) + P[2,2] * mu))
      
    } else {
      
      return(log(P[1,1]*(1-mu) + P[1,2]*mu))
      
    }
  
}

# define posterior predictions

posterior_predict_sens_reg <- function(i, prep, ...) {
  
  mu <- brms::get_dpar(prep, "mu", i = i)
  y <- prep$data$Y[i]
    
    out <- rbinom(n=length(mu),size=1,prob=P[2,1] * (1 - mu) + P[2,2] * mu)
  
  return(out)
  
}

# define posterior expectation (equal to latent variable pi)

posterior_epred_sens_reg <- function(prep,...) {
  
  mu <- brms::get_dpar(prep, "mu")
  mu
  
}

all_stanvars <- stanvar(x=P,block = "data") + 
  stanvar(scode=stan_funs,block="functions")
