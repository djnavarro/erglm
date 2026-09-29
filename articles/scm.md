# Stepwise covariate modelling

Once you can fit a single exposure-response model, the next practical
question is usually *which covariates belong in the model*. When there
are several candidates, testing every combination by hand is tedious and
easy to get wrong.
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
and
[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
automate this with **stepwise covariate modelling** (SCM): a
forward-addition step that greedily adds the most helpful covariates, a
backward-elimination step that prunes terms that no longer earn their
place, and a complete history of every model considered along the way
that serves as an audit log for the procedure.

``` r

library(erglm)
```

## The building blocks

At the lowest level, covariate modelling is just adding or removing a
single term from a fitted model. Two exported helpers do exactly that,
[`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)
and
[`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md),
each taking a one-sided formula naming the term and returning a refitted
model:

``` r

base_mod <- erglm_model(
  formula = ae1 ~ aucss, 
  data = erglm_data, 
  family = binomial()
)

erglm_add_term(base_mod, ~ sex)
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss      sexMale  
#>    -1.64811      0.00551     -0.31223  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  297 Residual
#> Null Deviance:       402 
#> Residual Deviance: 193   AIC: 199
```

The stepwise functions are built on top of these: they repeatedly
propose add/remove moves, compare each candidate against the current
model by significance testing
([`anova()`](https://rdrr.io/r/stats/anova.html)), and keep the best
one. You rarely need to call
[`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)/[`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)
directly, but it’s worth knowing they’re what the automated search is
doing under the hood.

## Setting up the search

Two ingredients are needed to drive an SCM run: a **base model** to
start from, and a character vector of **candidate covariates** to
consider. Unlike some covariate-modelling frameworks, candidates here
don’t need to be tied to a particular structural parameter – they’re
just term names that could be added to (or removed from) the right-hand
side of the model formula:

``` r

candidates <- c("sex", "dose", "weight", "age")
```

## Forward addition

Every candidate not already in the model is added in turn and compared
against the current model; the term with the smallest $`p`$-value is
retained, provided that $`p`$-value is below `threshold`. The step
repeats until no remaining candidate clears the bar:

``` r

fwd_mod <- base_mod |> 
  erglm_scm_forward(candidates, threshold = 0.01, seed = 3425)

summary(fwd_mod)
#> 
#> Call:
#> stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#>             Estimate Std. Error z value Pr(>|z|)    
#> (Intercept) -1.79138    0.25560   -7.01  2.4e-12 ***
#> aucss        0.00550    0.00067    8.21  2.3e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 402.13  on 299  degrees of freedom
#> Residual deviance: 193.41  on 298  degrees of freedom
#> AIC: 197.4
#> 
#> Number of Fisher Scoring iterations: 7
```

None of the four candidates clear the default $`0.01`$ threshold here –
inspecting the history shows why:

``` r

fwd_mod_log <- erglm_scm_history(fwd_mod)
fwd_mod_log[, c("term_tested", "term_p_value", "model_updated")]
#>   term_tested term_p_value model_updated
#> 1        <NA>           NA            NA
#> 2        ~sex      0.39063             0
#> 3     ~weight      0.06218             0
#> 4        ~age      0.17665             0
#> 5       ~dose      0.70247             0
```

`sex` does have a genuine (if modest) effect on `ae1` in the
data-generating process behind `erglm_data`, but once `aucss` is already
in the model that effect isn’t strong enough, at this sample size, to
clear a $`0.01`$ threshold – so the search correctly leaves it out
rather than adding a covariate that doesn’t earn its place.

## Backward elimination

Backward elimination works in reverse: each term currently in the model
is dropped in turn, and the term with the *largest* $`p`$-value is
removed if that $`p`$-value exceeds `threshold`. To see it doing real
work, start from a saturated model that already contains every
candidate:

``` r

full_mod <- erglm_model(
  formula = ae1 ~ aucss + sex + dose + weight + age, 
  data = erglm_data, 
  family = binomial()
)

bwd_mod <- full_mod |> 
  erglm_scm_backward(candidates, threshold = 0.001, seed = 9821)

summary(bwd_mod)
#> 
#> Call:
#> stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#>             Estimate Std. Error z value Pr(>|z|)    
#> (Intercept) -1.79138    0.25560   -7.01  2.4e-12 ***
#> aucss        0.00550    0.00067    8.21  2.3e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 402.13  on 299  degrees of freedom
#> Residual deviance: 193.41  on 298  degrees of freedom
#> AIC: 197.4
#> 
#> Number of Fisher Scoring iterations: 7
```

All four candidates are pruned, leaving only `aucss` – matching what
forward addition already told us: none of `sex`, `dose`, `weight`, or
`age` earns a place in the model at these thresholds. The full audit log
shows the iteration-by-iteration elimination:

``` r

bwd_mod_log <- erglm_scm_history(bwd_mod)
bwd_mod_log[, c("iteration", "term_tested", "term_p_value", "model_updated")]
#>    iteration term_tested term_p_value model_updated
#> 1          0        <NA>           NA            NA
#> 2          1        ~sex      0.86307             1
#> 3          1       ~dose      0.84535             0
#> 4          1        ~age      0.12318             0
#> 5          1     ~weight      0.07129             0
#> 6          2     ~weight      0.04418             0
#> 7          2        ~age      0.12348             0
#> 8          2       ~dose      0.85135             1
#> 9          3        ~age      0.11832             1
#> 10         3     ~weight      0.04309             0
#> 11         4     ~weight      0.06218             1
```

Each iteration removes the single worst-performing term
(`model_updated == 1`); the next iteration re-tests everything still in
the model, since removing one term can change the others’ apparent
significance.

**Why the thresholds differ.** It’s standard practice to make forward
addition more permissive than backward elimination – $`0.01`$ to add but
$`0.001`$ to retain. A term added on the looser forward criterion must
then survive the stricter backward criterion, which guards against terms
that only looked useful in the presence of others. Keeping the backward
threshold at or below the forward threshold also prevents the procedure
from cycling (adding and removing the same term forever).

**Reproducibility.** Within each step, candidate terms are tested in a
random order, so results can depend on the state of the random number
generator; passing a `seed` makes a run reproducible. If `seed` is
omitted, a random one is chosen and reported via a message.

## Selecting by AIC or BIC

By default, each step selects a term using the $`p`$-value approach
described above. Pass `criterion = "aic"` or `criterion = "bic"` to
select instead by strict improvement in an information criterion: a term
is added (forward) or removed (backward) only if doing so strictly
decreases AIC/BIC relative to the current model, and the candidate
producing the largest improvement wins. `threshold` is ignored when
`criterion` isn’t `"p-value"`, and `term_p_value` is left `NA` in the
history, since the significance test plays no role in selection.

Because AIC is more permissive than the default $`p`$-value threshold,
forward addition with `criterion = "aic"` finds covariates worth adding
where the $`p`$-value search above found none:

``` r

aic_mod <- base_mod |> 
  erglm_scm_forward(candidates, criterion = "aic", seed = 3425)

summary(aic_mod)
#> 
#> Call:
#> stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#>              Estimate Std. Error z value Pr(>|z|)    
#> (Intercept)  2.350560   1.744632    1.35    0.178    
#> aucss        0.005595   0.000689    8.12  4.7e-16 ***
#> weight      -0.038716   0.019575   -1.98    0.048 *  
#> age         -0.059916   0.038717   -1.55    0.122    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 402.13  on 299  degrees of freedom
#> Residual deviance: 187.49  on 296  degrees of freedom
#> AIC: 195.5
#> 
#> Number of Fisher Scoring iterations: 7
```

``` r

aic_mod_log <- erglm_scm_history(aic_mod)
aic_mod_log[, c("term_tested", "criterion", "term_p_value", "model_aic", "model_updated")]
#>    term_tested criterion term_p_value model_aic model_updated
#> 1         <NA>      <NA>           NA     197.4            NA
#> 2         ~sex       aic           NA     198.7             0
#> 3      ~weight       aic           NA     195.9             1
#> 4         ~age       aic           NA     197.6             0
#> 5        ~dose       aic           NA     199.3             0
#> 6         ~age       aic           NA     195.5             1
#> 7         ~sex       aic           NA     197.9             0
#> 8        ~dose       aic           NA     197.8             0
#> 9         ~sex       aic           NA     197.5             0
#> 10       ~dose       aic           NA     197.5             0
```

The history’s `criterion` column records which selection rule drove each
step (`NA` for the base-model row), and `term_p_value` is `NA`
throughout since it isn’t used here. `model_aic` and `model_bic` are
always populated regardless of `criterion`, so a search driven by one
criterion can still be audited against the other.

The same `criterion` argument works for
[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md):

``` r

bic_mod <- full_mod |> 
  erglm_scm_backward(candidates, criterion = "bic", seed = 9821)

summary(bic_mod)
#> 
#> Call:
#> stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#>             Estimate Std. Error z value Pr(>|z|)    
#> (Intercept) -1.79138    0.25560   -7.01  2.4e-12 ***
#> aucss        0.00550    0.00067    8.21  2.3e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 402.13  on 299  degrees of freedom
#> Residual deviance: 193.41  on 298  degrees of freedom
#> AIC: 197.4
#> 
#> Number of Fisher Scoring iterations: 7
```

## Forward addition piped to backward elimination

The typical workflow is a **forward-backward** run: forward addition to
build the model up, immediately followed by backward elimination to
prune it. Both functions take a fitted model as their first argument and
return a fitted model, so they compose naturally with the pipe:

``` r

final_mod <- base_mod |>
  erglm_scm_forward(candidates, threshold = 0.01, seed = 3425) |>
  erglm_scm_backward(candidates, threshold = 0.001, seed = 9821)

summary(final_mod)
#> 
#> Call:
#> stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#>             Estimate Std. Error z value Pr(>|z|)    
#> (Intercept) -1.79138    0.25560   -7.01  2.4e-12 ***
#> aucss        0.00550    0.00067    8.21  2.3e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for binomial family taken to be 1)
#> 
#>     Null deviance: 402.13  on 299  degrees of freedom
#> Residual deviance: 193.41  on 298  degrees of freedom
#> AIC: 197.4
#> 
#> Number of Fisher Scoring iterations: 7
```

Since forward addition already found nothing worth adding, backward
elimination has nothing left to prune, and the pipeline settles on the
base model. `final_mod` is an ordinary fitted model object, so all the
usual methods apply –
[`summary()`](https://rdrr.io/r/base/summary.html),
[`confint()`](https://rdrr.io/r/stats/confint.html),
[`predict()`](https://rdrr.io/r/stats/predict.html), and so on all
behave normally.

## Other `glm()` families

Nothing about the SCM interface changes across
[`glm()`](https://rdrr.io/r/stats/glm.html) families. The same
candidates, applied to the Poisson-distributed `ae_count` response, tell
an analogous story – `sex` has a borderline effect (visible in the
full-model summary as $`p \approx 0.07`$) that still doesn’t clear the
default forward threshold:

``` r

base_pois <- erglm_model(
  formula = ae_count ~ aucss, 
  data = erglm_data, 
  family = poisson()
)

fwd_pois <- base_pois |> 
  erglm_scm_forward(candidates, threshold = 0.01, seed = 3425)

summary(fwd_pois)
#> 
#> Call:
#> stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#>              Estimate Std. Error z value Pr(>|z|)    
#> (Intercept) -1.00e+00   9.59e-02   -10.5   <2e-16 ***
#> aucss        1.04e-03   4.22e-05    24.8   <2e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for poisson family taken to be 1)
#> 
#>     Null deviance: 868.78  on 299  degrees of freedom
#> Residual deviance: 275.61  on 298  degrees of freedom
#> AIC: 713.8
#> 
#> Number of Fisher Scoring iterations: 5
```

Internally,
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
pick a likelihood-ratio chi-squared test for families with known
dispersion (`binomial`, `poisson`, as used above) and an F-test for
families with an estimated dispersion parameter (`gaussian`, `Gamma`),
matching [`stats::anova()`](https://rdrr.io/r/stats/anova.html)’s own
`test` argument – set the `test` argument explicitly to override this.

## Notes and caveats

- **Selection criterion.** The default is $`p`$-value selection
  (`criterion = "p-value"`); pass `criterion = "aic"` or
  `criterion = "bic"` to select by information criterion instead. The
  history records `model_aic` and `model_bic` for every candidate
  regardless of which criterion is active, so you can always audit the
  search against the criteria you didn’t use to drive it.
- **Threshold choice.** The forward and backward thresholds are the main
  levers you control. Stricter thresholds yield sparser models.
- **Greediness.** Stepwise search is greedy and isn’t guaranteed to find
  the globally best subset of covariates – and, as this article’s
  example shows, it may correctly find that *no* candidate covariates
  belong in the model at a given sample size and threshold. The audit
  log is valuable precisely because it makes the path the search took
  transparent and reproducible.
