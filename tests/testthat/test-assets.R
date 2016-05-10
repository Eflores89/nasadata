context("NASA's Earth Imagery Assets API")

test_that("Basic functionality of earth_asset with DEMO_KEY", {
  img <- earth_asset("DEMO_KEY", -100.31008, 25.66779, "2016-01-01")
  expect_true(is.list(img))
  expect_equal(as.character(img$type), rep("Point" , 8))
})
