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
  vector[nprov] alpha_prov;
  vector[nblock] alpha_block;
  real<lower=0> sigma_y;
}


model{
  real mu[N];
  
  //Priors
  beta_age ~ normal(0, 10);
  beta_age2 ~ normal(0, 10);
  alpha_prov ~ normal(0, 10);
  alpha_block ~ normal(0, 10);
  sigma_y ~ exponential(1);
  
  // Likelihood
  for (i in 1:N){
    mu[i] = alpha_prov[prov[i]] + alpha_block[bloc[i]] + beta_age * age[i] + beta_age2*square(age)[i];
  }
  y ~ normal(mu, sigma_y);
}

generated quantities {
  vector[N] y_rep;
  
  for(i in 1:N)  y_rep[i] = normal_rng(alpha_prov[prov[i]] + alpha_block[bloc[i]] + beta_age * age[i] + beta_age2*square(age)[i], sigma_y);
}
