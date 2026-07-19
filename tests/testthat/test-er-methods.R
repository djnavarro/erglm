test_that("erlr_glm methods for erplots' generics are registered when erplots is loaded", {
  skip_if_not_installed("erplots")

  mod <- lr_model(ae1 ~ aucss, lr_data)
  pred <- erplots::er_predict(mod, lr_data[1:5, ])
  expect_s3_class(pred, "data.frame")
  expect_true(all(c("fit_resp", "ci_lower", "ci_upper") %in% names(pred)))

  sim <- erplots::er_simulate(mod, lr_data[1:5, ], nsim = 2, seed = 1)
  expect_s3_class(sim, "data.frame")
  expect_equal(nrow(sim), 10L)

  smm <- erplots::er_summary(mod)
  expect_true(is.list(smm))
  expect_true("p_value" %in% names(smm))
})
