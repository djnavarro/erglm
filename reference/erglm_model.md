# Fit an exposure-response model based on `glm()`

Fit an exposure-response model based on
[`glm()`](https://rdrr.io/r/stats/glm.html)

## Usage

``` r
erglm_model(formula, data, family = stats::gaussian(), ...)
```

## Arguments

- formula:

  Model formula

- data:

  Data set

- family:

  The error distribution and link function to use, as for
  [`stats::glm()`](https://rdrr.io/r/stats/glm.html). Defaults to
  [`stats::gaussian()`](https://rdrr.io/r/stats/family.html), matching
  [`stats::glm()`](https://rdrr.io/r/stats/glm.html)'s own default.
  Tested and officially supported for
  [`binomial()`](https://rdrr.io/r/stats/family.html),
  [`poisson()`](https://rdrr.io/r/stats/family.html),
  [`gaussian()`](https://rdrr.io/r/stats/family.html), and
  [`Gamma()`](https://rdrr.io/r/stats/family.html); other
  [`glm()`](https://rdrr.io/r/stats/glm.html) families should work
  through the same generic mechanisms but are untested.

- ...:

  Other arguments passed to [`glm()`](https://rdrr.io/r/stats/glm.html)

## Value

A glm object

## Details

The returned object has class `c("erglm_model", "glm", "lm")`: it *is* a
`glm` object, with a little extra metadata attached. This means all of
the usual `glm`/`lm` methods work unchanged, without needing an
erglm-specific equivalent – e.g.
[`summary()`](https://rdrr.io/r/base/summary.html),
[`coef()`](https://rdrr.io/r/stats/coef.html),
[`vcov()`](https://rdrr.io/r/stats/vcov.html),
[`confint()`](https://rdrr.io/r/stats/confint.html),
[`predict()`](https://rdrr.io/r/stats/predict.html),
[`AIC()`](https://rdrr.io/r/stats/AIC.html),
[`BIC()`](https://rdrr.io/r/stats/AIC.html),
[`logLik()`](https://rdrr.io/r/stats/logLik.html), and
[`anova()`](https://rdrr.io/r/stats/anova.html) for comparing nested
models. See `vignette("methods", package = "erglm")` for worked examples
of these.
[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
is a separate, erglm-specific alternative to
[`predict()`](https://rdrr.io/r/stats/predict.html) that returns
confidence intervals on the response scale in a tidy data frame; the two
are complementary, not competing.

## Examples

``` r
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

# other glm() families are also supported
mod_pois <- erglm_model(ae_count ~ aucss, erglm_data, family = poisson())
mod_pois
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss  
#>   -1.003955     0.001044  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  298 Residual
#> Null Deviance:       868.8 
#> Residual Deviance: 275.6     AIC: 713.8
```
