
# vpc helpers -------------------------------------------------------------

#' VPC simulations for exposure-response models
#'
#' @param object An erglm model, as returned by [erglm_model()]
#' @param nsim Number of replicates
#' @param seed RNG state
#'
#' @returns A data frame or tibble. Contains one row per observation per
#' simulated replicate (identified by the `sim_id` column), with the
#' response variable replaced by its simulated value under parameter
#' uncertainty.
#'
#' @details A thin, VPC-shaped wrapper around [simulate.erglm_model()]
#' (i.e. `simulate(object, ...)`): parameter uncertainty is reflected by
#' sampling coefficients from the model's asymptotic sampling
#' distribution and computing the expected response at those
#' coefficients; family-appropriate residual noise is then added on top
#' of that expectation to produce a full predictive draw (Bernoulli
#' draws for `binomial`, Poisson draws for `poisson`, normal draws for
#' `gaussian`, gamma draws for `Gamma`). The dispersion parameter used
#' for that noise is a single point estimate
#' (`summary(object)$dispersion`), not resampled per replicate. Other
#' `glm()` families are not currently supported and will raise an
#' error. Unlike `simulate()`, the sampled coefficients and the expected
#' response (`mu`) are dropped, and the simulated response (`val`) is
#' spliced back into the response column's original name -- this is the
#' data frame shape expected by `erplots::er_vpc_plot()` for visualising
#' the result (e.g. as a VPC-style plot comparing observed and simulated
#' response rates).
#'
#' @export
#' @examples
#' mod <- erglm_model(ae2 ~ aucss + sex, erglm_data, family = binomial())
#' sim <- erglm_vpc_sim(mod)
#' sim
#'
#' mod_pois <- erglm_model(ae_count ~ aucss + sex, erglm_data, family = poisson())
#' erglm_vpc_sim(mod_pois)
#' 
erglm_vpc_sim <- function(object, nsim = 100, seed = NULL) {
  vv <- all.vars(object$formula)
  rsp_var <- vv[1]
  predictors <- setdiff(vv, rsp_var)

  sim <- stats::simulate(object, nsim = nsim, seed = seed)
  sim[[rsp_var]] <- sim$val

  sim |>
    dplyr::rename(row_id = dat_id) |>
    dplyr::select(dplyr::all_of(c(rsp_var, predictors, "row_id", "sim_id")))
}
