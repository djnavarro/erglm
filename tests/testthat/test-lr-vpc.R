test_that("lr_vpc_sim works", {
  mod <- lr_model(ae1 ~ aucss + sex, lr_data)
  expect_no_error(lr_vpc_sim(mod, nsim = 2))
  sim <- lr_vpc_sim(mod, nsim = 2)
  expect_s3_class(sim, "data.frame")
  expect_named(sim, c("ae1", "aucss", "sex", "row_id", "sim_id"))
  expect_equal(nrow(sim), nrow(lr_data) * 2)
})
