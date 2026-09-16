# Using base R model methods

``` r

library(erglm)
```

An object returned by
[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
is a genuine `glm` object – it has class
`c("erglm_model", "glm", "lm")`, and the `erglm_model` class only adds a
little extra metadata on top. This means none of the standard R methods
for working with fitted models are erglm-specific: they’re the same ones
you’d use for a plain [`glm()`](https://rdrr.io/r/stats/glm.html) fit,
and they work here without any modification. This article is a short
reference for the ones that come up most often when working with
exposure-response models.

``` r

mod <- erglm_model(ae1 ~ aucss + dose + sex, erglm_data, family = binomial())
```

## Model summary

[`summary()`](https://rdrr.io/r/base/summary.html) gives the usual
coefficient table, standard errors, and dispersion information:

``` r

summary(mod)
#> 
#> Call:
#> stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#>               Estimate Std. Error z value Pr(>|z|)    
#> (Intercept) -1.6827031  0.3205633  -5.249 1.53e-07 ***
#> aucss        0.0052806  0.0009409   5.612 2.00e-08 ***
#> dose         0.0010573  0.0031778   0.333    0.739    
#> sexMale     -0.3053683  0.3656515  -0.835    0.404    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 402.13  on 299  degrees of freedom
#> Residual deviance: 192.56  on 296  degrees of freedom
#> AIC: 200.56
#> 
#> Number of Fisher Scoring iterations: 7
```

## Coefficients and the variance-covariance matrix

The fitted coefficients and their variance-covariance matrix are
available via [`coef()`](https://rdrr.io/r/stats/coef.html) and
[`vcov()`](https://rdrr.io/r/stats/vcov.html), exactly as for any `glm`:

``` r

coef(mod)
#>  (Intercept)        aucss         dose      sexMale 
#> -1.682703108  0.005280590  0.001057316 -0.305368299
```

``` r

vcov(mod)
#>               (Intercept)         aucss          dose       sexMale
#> (Intercept)  1.027608e-01 -4.300767e-05 -3.378202e-04 -5.997505e-02
#> aucss       -4.300767e-05  8.853364e-07 -2.126617e-06 -2.736543e-05
#> dose        -3.378202e-04 -2.126617e-06  1.009860e-05  6.150646e-05
#> sexMale     -5.997505e-02 -2.736543e-05  6.150646e-05  1.337010e-01
```

Confidence intervals for individual coefficients can be obtained from
[`confint()`](https://rdrr.io/r/stats/confint.html) (profile-likelihood
based, so slightly slower but generally preferred over a Wald interval
for `glm` models):

``` r

confint(mod)
#> Waiting for profiling to be done...
#>                    2.5 %       97.5 %
#> (Intercept) -2.348177240 -1.084757101
#> aucss        0.003626947  0.007337455
#> dose        -0.005392874  0.007172194
#> sexMale     -1.031425155  0.409529436
```

## Predictions

Base R’s [`predict()`](https://rdrr.io/r/stats/predict.html) works
directly on an erglm model. By default it returns predictions on the
link scale; use `type = "response"` for the response scale:

``` r

predict(mod, newdata = erglm_data[1:5, ], type = "response")
#>         1         2         3         4         5 
#> 0.8554138 0.9999984 0.1567379 0.9900114 0.5274632
```

[`predict()`](https://rdrr.io/r/stats/predict.html) can also return
standard errors (`se.fit = TRUE`), which is the basis for erglm’s own
\[erglm_predict()\] – that function is a thin, opinionated wrapper that
back-transforms the link-scale standard errors into a confidence
interval on the response scale and returns everything as a tidy data
frame bound to `newdata`:

``` r

erglm_predict(mod, newdata = erglm_data[1:5, ])
#> # A tibble: 5 × 18
#>      id sex      age weight  dose treatment aucss cmaxss   ae1   ae2 ae_count
#>   <int> <fct>  <int>  <dbl> <dbl> <fct>     <dbl>  <dbl> <dbl> <dbl>    <int>
#> 1     1 Male      35     79   200 Drug       673.   97.3     0     1        1
#> 2     2 Female    22     58   200 Drug      2806.  301.      1     1        6
#> 3     3 Female    28     58     0 Placebo      0     0       0     0        1
#> 4     4 Female    18     57   100 Drug      1169.  198.      1     1        0
#> 5     5 Male      28     77   100 Drug       377.   51.4     0     0        0
#> # ℹ 7 more variables: biomarker_change <dbl>, ae_duration <dbl>,
#> #   fit_link <dbl>, se_link <dbl>, fit_resp <dbl>, ci_lower <dbl>,
#> #   ci_upper <dbl>
```

Use whichever is more convenient:
[`predict()`](https://rdrr.io/r/stats/predict.html) for a quick point
estimate, or
[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
when you want interval bounds without computing them by hand.

## Model comparison

[`AIC()`](https://rdrr.io/r/stats/AIC.html),
[`BIC()`](https://rdrr.io/r/stats/AIC.html), and
[`logLik()`](https://rdrr.io/r/stats/logLik.html) all work as usual,
which is convenient for comparing candidate models outside of erglm’s
own stepwise covariate modelling
([`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)):

``` r

mod_no_sex <- erglm_model(ae1 ~ aucss + dose, erglm_data, family = binomial())

AIC(mod, mod_no_sex)
#>            df      AIC
#> mod         4 200.5607
#> mod_no_sex  3 199.2614
BIC(mod, mod_no_sex)
#>            df      BIC
#> mod         4 215.3758
#> mod_no_sex  3 210.3728
```

For nested models, [`anova()`](https://rdrr.io/r/stats/anova.html) gives
a likelihood-ratio (or F, for families with estimated dispersion) test
directly – this is exactly the machinery
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
use internally, exposed here for one-off comparisons:

``` r

anova(mod_no_sex, mod, test = "Chisq")
#> Analysis of Deviance Table
#> 
#> Model 1: ae1 ~ aucss + dose
#> Model 2: ae1 ~ aucss + dose + sex
#>   Resid. Df Resid. Dev Df Deviance Pr(>Chi)
#> 1       297     193.26                     
#> 2       296     192.56  1   0.7007   0.4025
```

## A note on diagnostic plots

Base R’s `plot.lm()` diagnostic plots (`plot(mod, which = 1:4)`) also
work, though some panels (e.g. leverage) are more informative for
continuous responses than for binary ones. erglm deliberately doesn’t
provide its own diagnostic plotting – see the companion
[erplots](https://github.com/djnavarro/erplots) package for
exposure-response-specific visualisations.
