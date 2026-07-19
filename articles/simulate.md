# Simulation

This is the simulation article

``` r

library(erlr)
```

## Visual predictive checks

[`lr_vpc_sim()`](https://erlr.djnavarro.net/reference/lr_vpc_sim.md)
draws simulated response values that reflect both parameter uncertainty
(by resampling coefficients from the model’s asymptotic sampling
distribution) and, family-appropriately, residual noise around the
resulting expectation:

``` r

mod <- lr_model(ae2 ~ aucss + sex, lr_data)
sim <- lr_vpc_sim(mod, nsim = 20, seed = 1234)
sim
#> # A tibble: 6,000 × 5
#>      ae2 aucss sex    row_id sim_id
#>    <int> <dbl> <fct>   <int>  <int>
#>  1     0  673. Male        1      1
#>  2     1 2806. Female      2      1
#>  3     0    0  Female      3      1
#>  4     1 1169. Female      4      1
#>  5     0  377. Male        5      1
#>  6     0  327. Female      6      1
#>  7     0    0  Male        7      1
#>  8     1 1208. Female      8      1
#>  9     0    0  Male        9      1
#> 10     0  254. Female     10      1
#> # ℹ 5,990 more rows
```

The noise model is family-specific: Bernoulli draws for `binomial`,
Poisson draws for `poisson`, normal draws for `gaussian`, and gamma
draws for `Gamma`. For example, with a Poisson response:

``` r

mod_pois <- lr_model(ae_count ~ aucss + sex, lr_data, family = poisson())
sim_pois <- lr_vpc_sim(mod_pois, nsim = 20, seed = 1234)
sim_pois
#> # A tibble: 6,000 × 5
#>    ae_count aucss sex    row_id sim_id
#>       <int> <dbl> <fct>   <int>  <int>
#>  1        2  673. Male        1      1
#>  2       11 2806. Female      2      1
#>  3        0    0  Female      3      1
#>  4        0 1169. Female      4      1
#>  5        0  377. Male        5      1
#>  6        0  327. Female      6      1
#>  7        0    0  Male        7      1
#>  8        0 1208. Female      8      1
#>  9        1    0  Male        9      1
#> 10        0  254. Female     10      1
#> # ℹ 5,990 more rows
```

Other [`glm()`](https://rdrr.io/r/stats/glm.html) families aren’t
currently supported by
[`lr_vpc_sim()`](https://erlr.djnavarro.net/reference/lr_vpc_sim.md) and
will raise an informative error rather than silently falling back to an
expectation-only draw.
