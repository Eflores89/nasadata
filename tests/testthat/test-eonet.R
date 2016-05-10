context("NASA's Earth Observatory Natural Event Tracker (EONET)")

test_that("Basic functionality of earth_event", {
  result <- earth_event(limit = 1)
  expect_equal(length(result), 5)
  expect_true(is.data.frame(result$Events))
  expect_true(is.data.frame(result$Sources))
  expect_true(is.data.frame(result$Categories))
  expect_true(is.list(result$Geography))
  expect_true(is.data.frame(result$Meta))
})
