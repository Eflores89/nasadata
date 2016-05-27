context("NASA's Earth Imagery API")

test_that("Fetching image from Earth Imagery API (metadata + raster)", {
  img <- earth_image("DEMO_KEY", -100.31008, 25.66779, "2016-01-01")

  # png image included
  expect_equal(dim(img$image_raster_data), c(512, 512, 3))

  # checking metadata structure
  expect_true(is.data.frame(img$image_metadata))
  expect_equal(ncol(img$image_metadata), 4)
  expect_true(is.character(img$image_metadata$Date))
  expect_true(is.character(img$image_metadata$URL))
  expect_true(is.numeric(img$image_metadata$CloudScore))
  expect_true(is.character(img$image_metadata$ID))
})

test_that("Fetching image from Earth Imagery API (metadata only)", {
  img <- earth_image("DEMO_KEY", -100.31008, 25.66779, "2016-01-01",
                     meta_only = TRUE)

  # png image not included
  expect_null(img$image_raster_data)

  # checking metadata structure
  expect_true(is.data.frame(img$image_metadata))
  expect_equal(ncol(img$image_metadata), 4)
  expect_true(is.character(img$image_metadata$Date))
  expect_true(is.character(img$image_metadata$URL))
  expect_true(is.numeric(img$image_metadata$CloudScore))
  expect_true(is.character(img$image_metadata$ID))
})
