# Getting Started

erglm provides estimation tools for exposure-response models based on
[`glm()`](https://rdrr.io/r/stats/glm.html). It’s mostly a convenience
package: the core tools are thin wrappers around
[`glm()`](https://rdrr.io/r/stats/glm.html) and its usual machinery,
tested and supported for binomial, poisson, gaussian, and gamma
families. This article is a quick tour of the main pieces; the other
articles go into more depth on each.

``` r

library(erglm)
```

## Example data

The package ships with a synthetic dataset, `erglm_data`, used
throughout the documentation. It has an exposure metric (`aucss`),
several covariates (`sex`, `age`, `weight`, `dose`, …), and response
columns for each supported family: binary (`ae1`, `ae2`), count
(`ae_count`), continuous (`biomarker_change`), and positive right-skewed
continuous (`ae_duration`):

``` r

head(erglm_data)
#>   id    sex age weight dose treatment   aucss cmaxss ae1 ae2 ae_count
#> 1  1   Male  35     79  200      Drug  673.09  97.33   0   1        1
#> 2  2 Female  22     58  200      Drug 2806.12 300.62   1   1        6
#> 3  3 Female  28     58    0   Placebo    0.00   0.00   0   0        1
#> 4  4 Female  18     57  100      Drug 1169.04 197.78   1   1        0
#> 5  5   Male  28     77  100      Drug  377.29  51.43   0   0        0
#> 6  6 Female  19     76  200      Drug  327.08  25.37   1   0        0
#>   biomarker_change ae_duration
#> 1             1.22       12.40
#> 2             4.87       13.70
#> 3            -1.83        5.26
#> 4             1.90        6.70
#> 5            -1.01        6.15
#> 6            -4.97       12.83
```

## Fitting a model

[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
fits the model – it takes the same `formula`/`data` arguments as
[`glm()`](https://rdrr.io/r/stats/glm.html), plus a `family` argument
(defaulting to [`gaussian()`](https://rdrr.io/r/stats/family.html),
matching [`glm()`](https://rdrr.io/r/stats/glm.html)’s own default):

``` r

mod <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
mod
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss      sexMale  
#>   -1.648112     0.005508    -0.312234  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  297 Residual
#> Null Deviance:       402.1 
#> Residual Deviance: 192.7     AIC: 198.7
```

## Prediction

[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
produces predictions with confidence intervals, on both the link and
response scales, as a tidy data frame:

``` r

mod |>
  erglm_predict(newdata = data.frame(aucss = seq(0, 3000, by = 500), sex = "Female"))
#>   aucss    sex  fit_link   se_link  fit_resp   ci_lower  ci_upper
#> 1     0 Female -1.648112 0.3008814 0.1613643 0.09640451 0.2576162
#> 2   500 Female  1.105879 0.2971389 0.7513601 0.62796529 0.8439953
#> 3  1000 Female  3.859871 0.5575033 0.9793641 0.94087655 0.9929843
#> 4  1500 Female  6.613862 0.8706807 0.9986602 0.99266226 0.9997566
#> 5  2000 Female  9.367854 1.1958747 0.9999146 0.99911052 0.9999918
#> 6  2500 Female 12.121845 1.5254193 0.9999946 0.99989187 0.9999997
#> 7  3000 Female 14.875836 1.8569998 0.9999997 0.99998681 1.0000000
```

## Choosing covariates

When there are several candidate covariates,
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
and
[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
automate the process of deciding which belong in the model, via stepwise
addition/elimination based on significance testing:

``` r

erglm_scm_forward(mod, candidates = c("dose", "weight", "age"), seed = 1024)
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss      sexMale  
#>   -1.648112     0.005508    -0.312234  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  297 Residual
#> Null Deviance:       402.1 
#> Residual Deviance: 192.7     AIC: 198.7
```

See the [“Stepwise covariate
modelling”](https://erglm.djnavarro.net/articles/scm.md) article for a
full treatment, including the forward/backward workflow and the audit
log
([`erglm_scm_history()`](https://erglm.djnavarro.net/reference/erglm_scm.md)).

## Simulation

[`simulate()`](https://rdrr.io/r/stats/simulate.html) generates
replicate datasets from a fitted model, capturing both parameter
uncertainty and observation-level noise:

``` r

sim <- simulate(mod, nsim = 5, seed = 2048)
head(sim)
#>   dat_id sim_id        mu val coef_(Intercept)  coef_aucss coef_sexMale   aucss
#> 1      1      1 0.8408603   0        -1.858621 0.005770135   -0.3605561  673.09
#> 2      2      1 0.9999994   1        -1.858621 0.005770135   -0.3605561 2806.12
#> 3      3      1 0.1348639   0        -1.858621 0.005770135   -0.3605561    0.00
#> 4      4      1 0.9925117   1        -1.858621 0.005770135   -0.3605561 1169.04
#> 5      5      1 0.4894609   1        -1.858621 0.005770135   -0.3605561  377.29
#> 6      6      1 0.5071682   1        -1.858621 0.005770135   -0.3605561  327.08
#>      sex
#> 1   Male
#> 2 Female
#> 3 Female
#> 4 Female
#> 5   Male
#> 6 Female
```

See the [“Simulation”](https://erglm.djnavarro.net/articles/simulate.md)
article for details, including the lower-level
[`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md)
building block.

## Working with fitted models

An object returned by
[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
is a genuine `glm` object – it has class `c("erglm_model", "glm", "lm")`
– so all of the standard `glm`/`lm` methods
([`summary()`](https://rdrr.io/r/base/summary.html),
[`predict()`](https://rdrr.io/r/stats/predict.html),
[`confint()`](https://rdrr.io/r/stats/confint.html),
[`AIC()`](https://rdrr.io/r/stats/AIC.html),
[`anova()`](https://rdrr.io/r/stats/anova.html), and so on) work on it
directly, with no erglm-specific replacement needed. See the [“Using
base R model methods”](https://erglm.djnavarro.net/articles/methods.md)
article for a worked-through tour of these.

## Where to next

- [“Modelling”](https://erglm.djnavarro.net/articles/model.md) – more on
  fitting and prediction, including the other
  [`glm()`](https://rdrr.io/r/stats/glm.html) families erglm supports.
- [“Stepwise covariate
  modelling”](https://erglm.djnavarro.net/articles/scm.md) – the
  forward/backward SCM workflow in full.
- [“Using base R model
  methods”](https://erglm.djnavarro.net/articles/methods.md) – the
  `glm`/`lm` methods that come for free.
- [“Simulation”](https://erglm.djnavarro.net/articles/simulate.md) –
  [`simulate()`](https://rdrr.io/r/stats/simulate.html) and
  [`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md).
- the companion [erplots](https://github.com/djnavarro/erplots) package,
  for visualising exposure-response models fitted with erglm.
