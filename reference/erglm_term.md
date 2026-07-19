# Add or remove a covariate term from an exposure-response model

Add or remove a single covariate term from an existing erglm model,
returning a new fitted model object.

## Usage

``` r
erglm_add_term(mod, term, quiet = FALSE)

erglm_remove_term(mod, term, quiet = FALSE)
```

## Arguments

- mod:

  An erglm model object, as returned by
  [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)

- term:

  A one-sided formula naming the term to add/remove, e.g. `~ sex`

- quiet:

  If `TRUE`, suppress the warning issued when the term can't be
  added/removed (because it's already in the model / isn't in the model,
  respectively)

## Value

An erglm model object. If the term can't be added/removed (see `quiet`),
the original `mod` is returned unchanged.

## Details

These functions are not typically called directly; they underpin
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
and
[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md).
Named and shaped to match the companion `emaxnls` package's
`emax_add_term()`/`emax_remove_term()`, which serve the same purpose for
`emaxnls`/`emaxlogistic` models – with one structural difference:
`emaxnls`'s terms are two-sided formulas naming a structural parameter
(e.g. `E0 ~ AGE`), since covariates there attach to a specific Emax
parameter, whereas erglm's terms are plain one-sided
[`glm()`](https://rdrr.io/r/stats/glm.html) formula terms (e.g.
`~ sex`), since erglm has no equivalent parameter-level structure to
attach covariates to.

## Examples

``` r
mod <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
mod2 <- erglm_add_term(mod, ~ sex)
mod3 <- erglm_remove_term(mod2, ~ sex)
```
