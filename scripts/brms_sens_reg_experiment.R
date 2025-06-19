# define brms sensitive regression model

stan_funs <- '
  real sens_reg_lpmf(int y, real mu, real bias, matrix P, int T) {
  
    // generalized RR model from van der Hout and van der Heijden (2002)
    // also see R package RRreg
    
    real out;
    // need to impose a constraint on bias where it cannot be larger than mu
    real bias_trans = mu * bias;
    
    if(T==1) {
    
      // treatment distribution (crosswise model)
      
      if(y==1) {
      
        out = P[2,1] * (1 - mu) + P[2,2] * mu;
      
      } else if(y==0) {
      
       out = P[1,1]*(1-mu) + P[1,2]*mu;
      
      }

    } else if (T==0) {
    
      // control = direct question
    
      if(y==1) {
      
        out = mu - bias_trans;
      
      } else if(y==0) {
      
        out = (1 - mu) + bias_trans;
      
      }
    
    }
    
    return log(out); 

  }
  
  int sens_reg_rng(real mu, real bias, matrix P, int T) {
  
    real bias_trans = mu*bias;
  
    if(T==1) {
    
      return bernoulli_rng(P[2,1] * (1 - mu) + P[2,2] * mu);
      
    } else {
    
      return bernoulli_rng(mu - bias_trans);
    
    }

  }'

# define custom family

family_sens_reg <- custom_family("sens_reg",
                                 dpars=c("mu","bias"),
                                 links=c("logit","logit"),
                                 type="int",
                                 lb=c(NA,NA),
                                 ub=c(NA,NA),
                                 vars=c("P","vint1[n]"))

# define log-likelihood

log_lik_sens_reg <- function(i, prep) {
  mu <- brms::get_dpar(prep, "mu", i = i)
  y <- prep$data$Y[i]
  treatment <- prep$data$vint1[i]
  bias <- brms::get_dpar(prep, "bias", i = i)
  
  bias_trans <- bias*mu
  
  if(treatment==1) {
    
    if(y==1) {
      
      return(log(P[2,1] * (1 - mu) + P[2,2] * mu))
      
    } else {
      
      return(log(P[1,1]*(1-mu) + P[1,2]*mu))
      
    }
    
  } else {
    
    if(y==1) {
      
      return(log(mu - bias_trans))
      
    } else {
      
      return(log((1 - mu) + bias_trans))
      
    }
    
  }
  
  
}

# define posterior predictions

posterior_predict_sens_reg <- function(i, prep, ...) {
  
  mu <- brms::get_dpar(prep, "mu", i = i)
  bias <- brms::get_dpar(prep, "bias", i = i)
  y <- prep$data$Y[i]
  treatment <- prep$data$vint1[i]
  
  bias_trans <- mu*bias
  
  if(treatment==1) {
    
    out <- rbinom(n=length(mu),size=1,prob=P[2,1] * (1 - mu) + P[2,2] * mu)
    
  } else {
    
    out <- rbinom(n=length(mu),size=1,prob=mu - bias_trans)
    
  }
  
  return(out)
  
}

# define posterior expectation (equal to latent variable pi)

posterior_epred_sens_reg <- function(prep,...) {
  
  mu <- brms::get_dpar(prep, "mu")
  bias <- brms::get_dpar(prep, "bias")
  
  mu
  
}

posterior_epred_bias_sens_reg <- function(prep,...) {
  
  mu <- brms::get_dpar(prep, "mu")
  bias <- brms::get_dpar(prep, "bias")
  
  bias*mu
  
}

all_stanvars <- stanvar(x=P,block = "data") + 
  stanvar(scode=stan_funs,block="functions")

