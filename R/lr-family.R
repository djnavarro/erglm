
# Family-dispatch helpers shared across SCM (R/lr-scm.R) and VPC
# (R/lr-vpc.R). Officially tested/supported for binomial, poisson,
# gaussian, and Gamma; other glm() families work through the same
# generic mechanisms elsewhere in the package (lr_predict(),
# lr_simulator()) but are not covered by these two helpers.

.lr_supported_vpc_families <- c("binomial", "poisson", "gaussian", "Gamma")

# Picks the appropriate `stats::anova(..., test = )` flavour for a given
# glm family: a likelihood-ratio chi-squared test is appropriate for
# families with known dispersion (binomial, poisson); an F-test is the
# standard choice for families with an estimated dispersion parameter
# (gaussian, Gamma, inverse.gaussian, quasi*).
.lr_default_test <- function(family_name) {
  if (family_name %in% c("binomial", "poisson")) return("Chisq")
  "F"
}

.lr_resolve_test <- function(test, family_name) {
  test <- match.arg(test, c("auto", "Chisq", "F"))
  if (test == "auto") return(.lr_default_test(family_name))
  test
}

# Draws a simulated response value for each element of `fit` (the
# expected response under some sampled parameter vector), incorporating
# family-appropriate residual/dispersion noise. `dispersion` is a single
# point estimate (e.g. from `summary(model)$dispersion`) applied to every
# draw -- parameter uncertainty is already reflected in `fit` varying
# across replicates, but dispersion uncertainty itself is not resampled.
.lr_draw_response <- function(family_name, fit, dispersion) {
  n <- length(fit)
  switch(
    family_name,
    binomial = stats::rbinom(n, size = 1, prob = fit),
    poisson = stats::rpois(n, lambda = fit),
    gaussian = stats::rnorm(n, mean = fit, sd = sqrt(dispersion)),
    Gamma = stats::rgamma(n, shape = 1 / dispersion, rate = 1 / (dispersion * fit)),
    rlang::abort(
      paste0(
        "lr_vpc_sim() does not support family \"", family_name, "\". ",
        "Supported families are: ",
        paste(.lr_supported_vpc_families, collapse = ", "), "."
      )
    )
  )
}
