# Link and inverse-link functions for a fitted model

Every [`glm()`](https://rdrr.io/r/stats/glm.html) family already carries
its link and inverse-link functions (`stats::family(mod)$linkfun` /
`stats::family(mod)$linkinv`), but many users don't realise these are
available for the taking. `erglm_link()` and `erglm_invlink()` are thin,
discoverable wrappers around them: `erglm_link()` maps the response
scale to the linear predictor scale, and `erglm_invlink()` maps the
linear predictor scale back to the response scale.

## Usage

``` r
erglm_link(mod)

erglm_invlink(mod)
```

## Arguments

- mod:

  A fitted model, typically an `erglm_model`/`glm` object.

## Value

A function of one numeric-vector argument.

## Examples

``` r
mod <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
erglm_link(mod)(0.5)
#> [1] 0
erglm_invlink(mod)(0)
#> [1] 0.5
erglm_link(mod)(erglm_invlink(mod)(-2:2))
#> [1] -2 -1  0  1  2
```
