context("NASA's Earth Observatory Natural Event Tracker (EONET)")

test_that("Basic functionality of earth_event", {
  result <- earth_event(limit = 1)
  expect_equal(length(result), 5, info = "expecting 5 elements")
  expect_true(is.data.frame(result$Events))
  expect_true(is.data.frame(result$Sources))
  expect_true(is.data.frame(result$Categories))
  expect_true(is.list(result$Geography))
  expect_true(is.data.frame(result$Meta))
})

test_that("Calling eonet_sources", {
  sources <- eonet_sources()
  expect_true(is.data.frame(sources))
  expect_equal(ncol(sources), 4, info = "expecting 4 columns")
  expect_gt(nrow(sources), 0)
  expect_true(is.character(sources$id))
  expect_true(is.character(sources$title))
  expect_true(is.character(sources$source))
  expect_true(is.character(sources$link))
})

test_that("Calling eonet_categories", {
  categories <- eonet_categories()
  expect_true(is.data.frame(categories))
  expect_equal(ncol(categories), 5, info = "expecting 5 columns")
  expect_gt(nrow(categories), 0)
  expect_true(is.numeric(categories$id))
  expect_true(is.character(categories$title))
  expect_true(is.character(categories$link))
  expect_true(is.character(categories$description))
  expect_true(is.character(categories$layers))
})
