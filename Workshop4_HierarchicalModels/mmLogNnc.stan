data {                                                                         // observed variables 
  int<lower=1> N;                                                              // Number of observations
  vector[N] y;                                                                 // Response variable
  vector[N] age;                                                               // Tree age
  int<lower=0> nprov;                                                          // Number of provenances
  int<lower=0, upper=nprov> prov[N];                                           // Provenances
}

parameters {                                                                   // unobserved variables
  real beta_age;
  real beta_age2;
  real<lower=0> alpha;
  vector[nprov] z_prov;
  real<lower=0> sigma_y;
  real<lower=0> sigma_prov;
}

model{
  beta_age ~ normal(0,1);
  beta_age2 ~ normal(0,1);
  alpha ~ lognormal(0,1);
  z_prov ~ normal(0, 1);
  sigma_y ~ exponential(1);
  sigma_prov ~ exponential(1);
  y ~ lognormal(log(exp(log(alpha) + z_prov[prov]*sigma_prov) + beta_age*age + beta_age2*square(age)), sigma_y);
}

generated quantities {
  vector[N] y_rep;
  for(i in 1:N)  y_rep[i] = lognormal_rng(log(exp(log(alpha) + z_prov[prov][i]*sigma_prov) + beta_age*age[i] + beta_age2*square(age)[i]), sigma_y);
}

