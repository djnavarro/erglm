test_that("lr_vpc_sim works", {
  mod <- lr_model(ae1 ~ aucss + sex, lr_data)
  expect_no_error(lr_vpc_sim(mod, nsim = 2))
  sim <- lr_vpc_sim(mod, nsim = 2)
  expect_s3_class(sim, "data.frame")
  expect_named(sim, c("ae1", "aucss", "sex", "row_id", "sim_id"))
  expect_equal(nrow(sim), nrow(lr_data) * 2)
})

test_that("lr_vpc_sim draws binary 0/1 values for binomial models", {
  mod <- lr_model(ae1 ~ aucss + sex, lr_data)
  sim <- lr_vpc_sim(mod, nsim = 5, seed = 111)
  expect_true(all(sim$ae1 %in% c(0, 1)))
})

test_that("lr_vpc_sim draws non-negative integers for poisson models", {
  mod <- lr_model(ae_count ~ aucss + sex, lr_data, family = poisson())
  sim <- lr_vpc_sim(mod, nsim = 5, seed = 111)
  expect_true(all(sim$ae_count >= 0))
  expect_equal(sim$ae_count, round(sim$ae_count))
})

test_that("lr_vpc_sim draws real-valued (possibly negative) values for gaussian models", {
  mod <- lr_model(biomarker_change ~ aucss, lr_data, family = gaussian())
  sim <- lr_vpc_sim(mod, nsim = 20, seed = 111)
  expect_true(any(sim$biomarker_change < 0))
})

test_that("lr_vpc_sim draws strictly positive values for Gamma models", {
  mod <- lr_model(ae_duration ~ aucss + dose, lr_data, family = Gamma(link = "log"))
  sim <- lr_vpc_sim(mod, nsim = 5, seed = 111)
  expect_true(all(sim$ae_duration > 0))
})

test_that("lr_vpc_sim errors informatively for unsupported families", {
  mod <- lr_model(ae_count ~ aucss, lr_data, family = quasipoisson())
  expect_error(lr_vpc_sim(mod, nsim = 2, seed = 111), "quasipoisson")
})
