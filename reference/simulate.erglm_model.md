# Simulate responses from an exposure-response model

Generates simulated response datasets from a fitted erglm model,
propagating uncertainty in the parameter estimates. Useful for
simulation-based confidence bands, predictive checks, or bootstrapping
downstream analyses. Implements the standard
[`stats::simulate()`](https://rdrr.io/r/stats/simulate.html) generic, so
it is called as `simulate(object, ...)` rather than through an
erglm-specific function name.

## Usage

``` r
# S3 method for class 'erglm_model'
simulate(object, nsim = 1, seed = NULL, ...)
```

## Arguments

- object:

  An erglm model, as returned by
  [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)

- nsim:

  Number of replicates

- seed:

  Used to set the RNG seed. If `NULL`, a random seed is chosen and
  reported.

- ...:

  Ignored

## Value

A tibble with one row per observation per simulated replicate,
containing:

- `dat_id`, `sim_id`: identifiers for the original observation and the
  simulation replicate

- `mu`: the expected response (response scale) at the sampled parameter
  vector

- `val`: the simulated response value (`mu` plus family-appropriate
  noise)

- one `coef_*` column per model coefficient (e.g.
  `` coef_`(Intercept)` ``, `coef_aucss`), giving the sampled parameter
  values used for that replicate – prefixed to avoid colliding with
  predictor columns of the same name

- the model's predictor columns (not including the response)

## Details

Samples new parameter values from the multivariate normal distribution
implied by the model's variance-covariance matrix (via
[`mvtnorm::rmvnorm()`](https://rdrr.io/pkg/mvtnorm/man/Mvnorm.html)),
evaluates the expected response at each sampled parameter vector using
[`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md),
then draws a simulated response at each prediction using
family-appropriate residual noise (the same `.erglm_draw_response()`
mechanism used by
[`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md):
Bernoulli draws for `binomial`, Poisson draws for `poisson`, normal
draws for `gaussian`, gamma draws for `Gamma`). The dispersion parameter
used for that noise is a single point estimate
(`summary(object)$dispersion`), not resampled per replicate. Other
[`glm()`](https://rdrr.io/r/stats/glm.html) families are not currently
supported and will raise an informative error.

[`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md)
is a thin wrapper around this method: it calls
[`simulate()`](https://rdrr.io/r/stats/simulate.html) internally, then
drops the sampled coefficients and `mu` and splices the simulated
response (`val`) back into the response column's original name, to
produce a VPC-ready data set. Use
[`simulate()`](https://rdrr.io/r/stats/simulate.html) directly when you
want the full simulation detail (sampled parameters, expected and
simulated response, one row per observation per replicate); use
[`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md)
when you just want a VPC-shaped data set.

## Examples

``` r
mod <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
simulate(mod, nsim = 5, seed = 963)
#> # A tibble: 1,500 × 9
#>    dat_id sim_id    mu   val `coef_(Intercept)` coef_aucss coef_sexMale aucss
#>     <int>  <int> <dbl> <int>              <dbl>      <dbl>        <dbl> <dbl>
#>  1      1      1 0.896     1              -1.77    0.00618       -0.238  673.
#>  2      2      1 1.000     1              -1.77    0.00618       -0.238 2806.
#>  3      3      1 0.146     0              -1.77    0.00618       -0.238    0 
#>  4      4      1 0.996     1              -1.77    0.00618       -0.238 1169.
#>  5      5      1 0.581     1              -1.77    0.00618       -0.238  377.
#>  6      6      1 0.563     1              -1.77    0.00618       -0.238  327.
#>  7      7      1 0.119     0              -1.77    0.00618       -0.238    0 
#>  8      8      1 0.997     1              -1.77    0.00618       -0.238 1208.
#>  9      9      1 0.119     0              -1.77    0.00618       -0.238    0 
#> 10     10      1 0.450     1              -1.77    0.00618       -0.238  254.
#> # ℹ 1,490 more rows
#> # ℹ 1 more variable: sex <fct>
```
