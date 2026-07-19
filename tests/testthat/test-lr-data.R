test_that("lr_data is correctly formed", {
  lr_data2 <- .make_lr_data(seed = 2407L)
  expect_equal(lr_data, lr_data2)
})

test_that("lr_data has response columns suitable for each supported family", {
  expect_true(all(lr_data$ae1 %in% c(0, 1)))
  expect_true(all(lr_data$ae2 %in% c(0, 1)))
  expect_true(is.integer(lr_data$ae_count))
  expect_true(all(lr_data$ae_count >= 0))
  expect_true(is.numeric(lr_data$biomarker_change))
  expect_true(any(lr_data$biomarker_change < 0)) # can be negative
  expect_true(is.numeric(lr_data$ae_duration))
  expect_true(all(lr_data$ae_duration > 0)) # strictly positive
})

