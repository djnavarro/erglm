# erglm

Provides estimation tools for exposure-response models based on
[`glm()`](https://rdrr.io/r/stats/glm.html). It is mostly intended as a
convenience package: the core tools are wrappers around
[`glm()`](https://rdrr.io/r/stats/glm.html), tested and supported for
binomial, poisson, gaussian, and gamma families. For plotting
exposure-response models (including those fitted with erglm), see the
companion package [erplots](https://erplots.djnavarro.net), which
supplies a model-agnostic mini-language for building exposure-response
plots. For an analogous approach to time-to-event models see
[ertte](https://ertte.djnavarro.net), and for Emax regression models see
[emaxnls](https://emaxnls.djnavarro.net).

## Installation

You can install the latest CRAN release of erglm with this:

``` r

install.packages("erglm")
```

Alternatively you can install the development version of erglm like so:

``` r

pak::pak("djnavarro/erglm")
```

## Models

``` r

library(erglm)

head(erglm_data)
#>   id    sex age weight dose treatment    aucss  cmaxss ae1 ae2 ae_count
#> 1  1   Male  35     79  200      Drug  673.091  97.328   0   1        1
#> 2  2 Female  22     58  200      Drug 2806.115 300.615   1   1        6
#> 3  3 Female  28     58    0   Placebo    0.000   0.000   0   0        1
#> 4  4 Female  18     57  100      Drug 1169.045 197.783   1   1        0
#> 5  5   Male  28     77  100      Drug  377.288  51.429   0   0        0
#> 6  6 Female  19     76  200      Drug  327.079  25.373   1   0        0
#>   biomarker_change ae_duration
#> 1         1.216895   12.402338
#> 2         4.867072   13.697841
#> 3        -1.832830    5.262023
#> 4         1.900170    6.699422
#> 5        -1.009179    6.152825
#> 6        -4.972753   12.829726

mod <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
mod
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss  
#>   -1.791383     0.005497  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  298 Residual
#> Null Deviance:       402.1 
#> Residual Deviance: 193.4     AIC: 197.4
```

## Stepwise covariate modelling

``` r

mod1 <- erglm_model(ae1 ~ aucss + sex + dose, erglm_data, family = binomial())
mod2 <- erglm_scm_backward(mod1, candidates = c("sex", "dose"))
erglm_scm_history(mod2)
#>   iteration attempt       step criterion action term_tested
#> 1         0       0 base model      <NA>   <NA>        <NA>
#> 2         1       1   backward   p-value remove       ~dose
#> 3         1       2   backward   p-value remove        ~sex
#> 4         2       3   backward   p-value remove        ~sex
#>               model_tested model_converged term_p_value model_aic model_bic
#> 1 ae1 ~ aucss + sex + dose            TRUE           NA  200.5607  215.3758
#> 2        ae1 ~ aucss + sex            TRUE    0.7405587  198.6704  209.7817
#> 3       ae1 ~ aucss + dose            TRUE    0.4025483  199.2614  210.3728
#> 4              ae1 ~ aucss            TRUE    0.3906316  197.4073  204.8149
#>   model_updated
#> 1            NA
#> 2             1
#> 3             0
#> 4             1
```

## Simulation

``` r

mod <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
sim <- simulate(mod, nsim = 5, seed = 1234)
head(sim)
#>   dat_id sim_id        mu val coef_(Intercept)  coef_aucss coef_sexMale
#> 1      1      1 0.8940486   1        -2.092199 0.006010499    0.1793657
#> 2      2      1 0.9999996   1        -2.092199 0.006010499    0.1793657
#> 3      3      1 0.1098574   0        -2.092199 0.006010499    0.1793657
#> 4      4      1 0.9928562   1        -2.092199 0.006010499    0.1793657
#> 5      5      1 0.5877947   1        -2.092199 0.006010499    0.1793657
#> 6      6      1 0.4684692   1        -2.092199 0.006010499    0.1793657
#>      aucss    sex
#> 1  673.091   Male
#> 2 2806.115 Female
#> 3    0.000 Female
#> 4 1169.045 Female
#> 5  377.288   Male
#> 6  327.079 Female
```

To visualise the simulations against the observed data (e.g. as a
VPC-style plot) see erplots’ `er_vpc()` mini-grammar – specifically
[`erplots::er_vpc_add_simulated()`](https://erplots.djnavarro.net/reference/er_vpc_add_simulated.html),
which can build its own simulated replicates directly from a fitted
`erglm_model` (`er_vpc_add_simulated(model = mod)`).
