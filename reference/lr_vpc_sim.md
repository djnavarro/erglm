# VPC simulations for exposure-response models

VPC simulations for exposure-response models

## Usage

``` r
lr_vpc_sim(object, nsim = 100, seed = NULL)
```

## Arguments

- object:

  An erlr model, as returned by
  [`lr_model()`](https://erlr.djnavarro.net/reference/lr_model.md)

- nsim:

  Number of replicates

- seed:

  RNG state

## Value

A data frame or tibble. Contains one row per observation per simulated
replicate (identified by the `sim_id` column), with the response
variable replaced by its simulated value under parameter uncertainty.

## Details

For each replicate, parameter uncertainty is reflected by sampling
coefficients from the model's asymptotic sampling distribution and
computing the expected response at those coefficients;
family-appropriate residual noise is then added on top of that
expectation to produce a full predictive draw (Bernoulli draws for
`binomial`, Poisson draws for `poisson`, normal draws for `gaussian`,
gamma draws for `Gamma`). The dispersion parameter used for that noise
is a single point estimate (`summary(object)$dispersion`), not resampled
per replicate. Other [`glm()`](https://rdrr.io/r/stats/glm.html)
families are not currently supported and will raise an error. To
visualise the result (e.g. as a VPC-style plot comparing observed and
simulated response rates), see
[`erplots::er_vpc_plot()`](https://rdrr.io/pkg/erplots/man/er_vpc_plot.html).

## Examples

``` r
mod <- lr_model(ae2 ~ aucss + sex, lr_data)
sim <- lr_vpc_sim(mod)
#> Using seed = 7603
sim
#> # A tibble: 30,000 × 5
#>      ae2 aucss sex    row_id sim_id
#>    <int> <dbl> <fct>   <int>  <int>
#>  1     0  673. Male        1      1
#>  2     1 2806. Female      2      1
#>  3     0    0  Female      3      1
#>  4     1 1169. Female      4      1
#>  5     0  377. Male        5      1
#>  6     0  327. Female      6      1
#>  7     0    0  Male        7      1
#>  8     0 1208. Female      8      1
#>  9     0    0  Male        9      1
#> 10     0  254. Female     10      1
#> # ℹ 29,990 more rows

mod_pois <- lr_model(ae_count ~ aucss + sex, lr_data, family = poisson())
lr_vpc_sim(mod_pois)
#> Using seed = 9053
#> # A tibble: 30,000 × 5
#>    ae_count aucss sex    row_id sim_id
#>       <int> <dbl> <fct>   <int>  <int>
#>  1        0  673. Male        1      1
#>  2        5 2806. Female      2      1
#>  3        1    0  Female      3      1
#>  4        1 1169. Female      4      1
#>  5        1  377. Male        5      1
#>  6        0  327. Female      6      1
#>  7        0    0  Male        7      1
#>  8        1 1208. Female      8      1
#>  9        1    0  Male        9      1
#> 10        1  254. Female     10      1
#> # ℹ 29,990 more rows
```
