test_that("erglm_model methods for erplots' generics are registered when erplots is loaded", {
  skip_if_not_installed("erplots")

  mod <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
  pred <- erplots::er_predict(mod, erglm_data[1:5, ])
  expect_s3_class(pred, "data.frame")
  expect_true(all(c("fit_resp", "ci_lower", "ci_upper") %in% names(pred)))

  sim <- erplots::er_simulate(mod, erglm_data[1:5, ], nsim = 2, seed = 1)
  expect_s3_class(sim, "data.frame")
  expect_equal(nrow(sim), 10L)

  smm <- erplots::er_summary(mod)
  expect_true(is.list(smm))
  expect_true(all(c("p_value", "coefficients", "glance") %in% names(smm)))

  expect_s3_class(smm$coefficients, "data.frame")
  expect_equal(nrow(smm$coefficients), 2L)
  expect_true(all(c("term", "estimate", "std_error", "statistic", "p_value", "conf_low", "conf_high") %in% names(smm$coefficients)))

  expect_s3_class(smm$glance, "data.frame")
  expect_equal(nrow(smm$glance), 1L)
  expect_true(all(c("n", "df_residual", "logLik", "aic", "bic", "deviance", "r_squared", "converged") %in% names(smm$glance)))
  # binomial family/link isn't the OLS case, so r_squared isn't meaningful
  expect_true(is.na(smm$glance$r_squared))
})

test_that("er_summary extracts p-values generically across dispersion parameterisations", {
  skip_if_not_installed("erplots")

  mod_gauss <- erglm_model(biomarker_change ~ aucss, erglm_data, family = gaussian())
  smm_gauss <- erplots::er_summary(mod_gauss)
  coefs <- summary(mod_gauss)$coefficients
  expect_equal(smm_gauss$p_value, unname(coefs[2, "Pr(>|t|)"]))
  # gaussian + identity link is the OLS case, so r_squared is meaningful
  expect_false(is.na(smm_gauss$glance$r_squared))

  mod_pois <- erglm_model(ae_count ~ aucss, erglm_data, family = poisson())
  smm_pois <- erplots::er_summary(mod_pois)
  coefs_pois <- summary(mod_pois)$coefficients
  expect_equal(smm_pois$p_value, unname(coefs_pois[2, "Pr(>|z|)"]))
})
