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

  Other arguments passed to [`glm()`](https://rdrr.io/r/stats/glm.html).
  Note that `weights`, `subset`, and `offset` don't work reliably here –
  see Details below.

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

`weights`, `subset`, and `offset` can't currently be passed through
`...` to [`stats::glm()`](https://rdrr.io/r/stats/glm.html):
[`glm()`](https://rdrr.io/r/stats/glm.html) resolves these
non-standard-evaluation arguments via
[`match.call()`](https://rdrr.io/r/base/match.call.html), which breaks
once they've been forwarded through another function's `...` rather than
named directly in the call [`glm()`](https://rdrr.io/r/stats/glm.html)
itself sees. This reproduces with a trivial wrapper
(`function(formula, data, family, ...) glm(formula, data, family, ...)`)
and is a limitation of
[`glm()`](https://rdrr.io/r/stats/glm.html)/[`lm()`](https://rdrr.io/r/stats/lm.html)'s
NSE, not something specific to erglm's `family` generalisation – see
e.g. the "Note" in [`?lm`](https://rdrr.io/r/stats/lm.html) about
wrapping [`lm()`](https://rdrr.io/r/stats/lm.html). Attempting it
currently fails with a low-level error
(`"..1 used in an incorrect context, no ... to look in"`). Two
workarounds: fold an offset into the formula itself (e.g.
`y ~ x + offset(z)`) rather than passing `offset =`, and pre-filter
`data` yourself rather than passing `subset =`. There's no similar
formula-level workaround for `weights`; call
`stats::glm(formula, data, family, weights = ...)` directly instead,
then (if you want the `erglm_model` class for consistency, e.g. for
[`simulate()`](https://rdrr.io/r/stats/simulate.html)'s S3 dispatch) run
`class(mod) <- c("erglm_model", class(mod))` on the result – every other
erglm function works on a plain `glm` object just as well, since none of
them require the class specifically.

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
