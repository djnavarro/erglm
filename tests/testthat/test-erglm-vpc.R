test_that("erglm_vpc_sim works", {
  mod <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
  expect_no_error(erglm_vpc_sim(mod, nsim = 2))
  sim <- erglm_vpc_sim(mod, nsim = 2)
  expect_s3_class(sim, "data.frame")
  expect_named(sim, c("ae1", "aucss", "sex", "row_id", "sim_id"))
  expect_equal(nrow(sim), nrow(erglm_data) * 2)
})

test_that("erglm_vpc_sim draws binary 0/1 values for binomial models", {
  mod <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
  sim <- erglm_vpc_sim(mod, nsim = 5, seed = 111)
  expect_true(all(sim$ae1 %in% c(0, 1)))
})

test_that("erglm_vpc_sim draws non-negative integers for poisson models", {
  mod <- erglm_model(ae_count ~ aucss + sex, erglm_data, family = poisson())
  sim <- erglm_vpc_sim(mod, nsim = 5, seed = 111)
  expect_true(all(sim$ae_count >= 0))
  expect_equal(sim$ae_count, round(sim$ae_count))
})

test_that("erglm_vpc_sim draws real-valued (possibly negative) values for gaussian models", {
  mod <- erglm_model(biomarker_change ~ aucss, erglm_data, family = gaussian())
  sim <- erglm_vpc_sim(mod, nsim = 20, seed = 111)
  expect_true(any(sim$biomarker_change < 0))
})

test_that("erglm_vpc_sim draws strictly positive values for Gamma models", {
  mod <- erglm_model(ae_duration ~ aucss + dose, erglm_data, family = Gamma(link = "log"))
  sim <- erglm_vpc_sim(mod, nsim = 5, seed = 111)
  expect_true(all(sim$ae_duration > 0))
})

test_that("erglm_vpc_sim errors informatively for unsupported families", {
  mod <- erglm_model(ae_count ~ aucss, erglm_data, family = quasipoisson())
  expect_error(erglm_vpc_sim(mod, nsim = 2, seed = 111), "quasipoisson")
})
