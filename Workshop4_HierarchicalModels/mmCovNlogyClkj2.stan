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
  real<lower=0> sigma_y;

  vector[nblock] alpha_block;                                                  // block intercepts
  real<lower=0> sigma_block;                                                   // sd among intercepts of the blocks 

  vector[nprov] alpha_prov;                                                    // prov intercepts
  vector[nprov] beta_prov;                                                     // prov slopes (with age)
  corr_matrix[2] R_prov;                                                       // correlation matrix R                               
  vector<lower=0>[2] sigma_prov;                                               // sd among intercepts and slopes of the provenances

}

transformed parameters {
  vector[2] v_prov[nprov];                                                     // vector of provenance intercepts and slopes (that have to covary)
  cov_matrix[2] S_prov;                                                        // covariance matrix S
  
  for(j in 1:nprov) v_prov[j] = [alpha_prov[j], beta_prov[j]]';
  S_prov = quad_form_diag(R_prov, sigma_prov);
  
  // Stan's manual:  "The function quad_form_diag is defined so that quad_form_diag(R_prov, sigma_prov) is equivalent to diag_matrix(sigma_prov) * R_prov * diag_matrix(sigma_prov), 
  // where diag_matrix(sigma_prov) returns the matrix with sigma_prov on the diagonal and zeroes off diagonal; the version using quad_form_diag should be faster."
}

model{
  real mu[N];

//Priors
  target += multi_normal_lpdf(v_prov|rep_vector(0, 2), S_prov);                //  two-dimensional Gaussian distribution with mean 0 and covariance matrix S. 
  
  alpha ~ normal(0,1);
  beta_age ~ normal(0,1);
  beta_age2 ~ normal(0,1);
  
  alpha_block ~ normal(0, sigma_block);
  sigma_block ~ exponential(1);
  sigma_y ~ exponential(1);
  sigma_prov ~ exponential(1);
  
  R_prov ~ lkj_corr(2);

// Linear model
  for (i in 1:N){
  mu[i] = alpha  + alpha_block[bloc[i]] + alpha_prov[prov[i]] + beta_prov[prov[i]] * age[i] + beta_age * age[i] + beta_age2*square(age)[i];
  }  
  
// Likelihood
  y ~ normal(mu, sigma_y);
}

generated quantities {
  vector[N] y_rep;

  for(i in 1:N)  y_rep[i] = normal_rng(alpha  + alpha_block[bloc[i]] + alpha_prov[prov[i]] + beta_prov[prov[i]] * age[i] + beta_age * age[i] + beta_age2*square(age)[i], sigma_y);
}



