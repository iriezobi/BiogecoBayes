data {                                                                         // observed variables 
  int<lower=1> N;                                                              // Number of observations
  vector[N] y;                                                                 // Response variable
  vector[N] age;                                                               // Tree age
  int<lower=0> nprov;                                                          // Number of provenances
  int<lower=0> nblock;                                                         // Number of blocks
  int<lower=0, upper=nprov> prov[N];                                           // Provenances
  int<lower=0, upper=nblock> bloc[N];                                          // Blocks
}



parameters {                                                                   // unobserved variables
  real beta_age;
  real beta_age2;
  real alpha;
    
//Priors
  vector[nprov] alpha_prov;
  vector[nblock] alpha_block;
  real<lower=0> sigma_y;
  
//Hyperpriors
  real<lower=0> sigma_alpha_prov;
  real<lower=0> sigma_alpha_block;
  
}


model{
  real mu[N];

//Priors
  beta_age ~ lognormal(0,1);
  beta_age2 ~ normal(0,1);
  alpha ~ lognormal(0,1);
  alpha_prov ~ normal(0, sigma_alpha_prov);
  alpha_block ~ normal(0, sigma_alpha_block);
  sigma_y ~ exponential(1);
  
//Hyperpriors
  sigma_alpha_prov ~ exponential(1);
  sigma_alpha_block ~ exponential(1);


// Likelihood
  for (i in 1:N){
  mu[i] = alpha + alpha_prov[prov[i]] + alpha_block[bloc[i]] + beta_age * age[i] + beta_age2 * age[i] * age[i];
  }
  y ~ lognormal(mu, sigma_y);
}

generated quantities {
  vector[N] y_rep;

  for(i in 1:N)  y_rep[i] = lognormal_rng(alpha + alpha_prov[prov[i]] + alpha_block[bloc[i]] + beta_age * age[i] + beta_age2 * age[i] * age[i], sigma_y);
}

