
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
#' @details For each replicate, parameter uncertainty is reflected by
#' sampling coefficients from the model's asymptotic sampling
#' distribution and computing the expected response at those
#' coefficients; family-appropriate residual noise is then added on top
#' of that expectation to produce a full predictive draw (Bernoulli
#' draws for `binomial`, Poisson draws for `poisson`, normal draws for
#' `gaussian`, gamma draws for `Gamma`). The dispersion parameter used
#' for that noise is a single point estimate
#' (`summary(object)$dispersion`), not resampled per replicate. Other
#' `glm()` families are not currently supported and will raise an
#' error. To visualise the result (e.g. as a VPC-style plot comparing
#' observed and simulated response rates), see `erplots::er_vpc_plot()`.
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
  ff <- object$formula
  vv <- all.vars(ff)
  rsp_var <- vv[1]
  dd <- object$data[, vv]
  family_name <- stats::family(object)$family
  dispersion <- summary(object)$dispersion
  sim <- .erglm_simulate_draws(object, newdata = dd, nsim = nsim, seed = seed)
  sim[[rsp_var]] <- .erglm_draw_response(family_name, fit = sim$fit_resp, dispersion = dispersion)
  sim$fit_resp <- NULL
  return(sim)
}
