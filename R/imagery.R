#' Fetches image from Earth Imagery API
#'
#' Calls NASA's Earth Imagery API and returns list with identification
#' information and image.
#'
#' @param key API Key for authentication.
#' @param lon Longitude of coordinate position.
#' @param lat Latitude of coordinate position.
#' @param date In YYYY-MM-DD format. The API wil return the image that is
#'   closest to this date.
#' @param cloud_score Gives a score of percentage of cloud cover, via algorithm
#'   (see official documentation). Defaults to TRUE.
#' @param plot If TRUE will plot the image via generic plot function.
#' @param meta_only If TRUE will only download the meta data for the image.
#'
#' @return Returns a \code{list} of two elements:
#' \item{image_metadata}{This contains a \code{data.frame}}
#' \item{image_raster_data}{This contains an \code{array} representing a raster}
#'
#' @examples
#'\dontrun{
#' key <- "123key"
#' img <- earth_image(key, -100.31008, 25.66779, "2016-01-01")
#'}
#'
#' @importFrom png readPNG
#' @importFrom jsonlite fromJSON
#' @importFrom utils download.file
#' @importFrom graphics plot.new
#' @importFrom graphics rasterImage
#' @export
earth_image <- function(key, lon, lat, date, cloud_score = TRUE, plot = FALSE,
                        meta_only = FALSE)
{
  # Validate parameters and fail fast
  if (!is.numeric(lon)) {
    stop("Lon parameter must be numeric")
  }
  if (!is.numeric(lat)) {
    stop("Lat parameter must be numeric")
  }

  tryCatch({
    date <- as.Date(date)
  },
  error = function(e){
    stop("Date parameter must be YYYY-MM-DD")
  })

  # Change R boolean value to NASA boolean value
  cloud_score <- switch(as.character(cloud_score),
    "TRUE" = "True",
    "FALSE" = "False",
    stop("Parameter cloud_score must be TRUE or FALSE")
  )

  # construct the query URL with parameters
  query <- sprintf("%s?lon=%s&lat=%s&date=%s&cloud_score=%s&api_key=%s",
                   "https://api.nasa.gov/planetary/earth/imagery",
                   lon, lat, date, cloud_score, key)

  # Download json object...
  s <- fromJSON(query)

  if ("error" %in% names(s)) {
    stop(paste0("NASA API Error\n",
                "The following is the output: ", s$error , "\n",
                "You can use earth_asset to review availability for location"))
  }

  # filling default value for missing cloud_score result element
  if (is.null(s$cloud_score)) {
    s$cloud_score <- "NA"
  }

  image_metadata <- data.frame("Date" = s$date,
                               "URL" = s$url,
                               "CloudScore" = s$cloud_score,
                               "ID" = s$id,
                               stringsAsFactors = FALSE)

  if (meta_only) {
    image_raster_data <- NULL
  } else {
    # TODO: this could be implemented without using tempfile
    z <- tempfile()
    suppressMessages(download.file(s$url, z, mode = "wb", quiet = TRUE))
    image_raster_data <- readPNG(z)
    file.remove(z)
  }

  if (plot) {
    plot_earth_image(image_raster_data)
  }

  # this list will be returned
  list("image_metadata" = image_metadata,
       "image_raster_data" = image_raster_data)
}

#' Plots the image to device
#'
#' To avoid S4 Classes and methods, this small wrapper simply plots an image
#' from NASA. If the purpose is to this interactively on one image, set the
#' parameter \code{plot = TRUE} in \code{earth_image}.
#'
#' @param image_raster_data image downloaded using earth_image.
#' @return nothing
#'
#' @seealso earth_image
#'
#' @examples
#'\dontrun{
#' key <- "123key"
#' img <- earth_image(key, -100.31008, 25.66779, "2016-01-01")
#' plot_earth_image(img$image_png)
#'}
#'
#' @importFrom graphics plot.new
#' @importFrom graphics rasterImage
#' @export
plot_earth_image <- function(image_raster_data) {
  plot.new()
  rasterImage(image_raster_data, 0, 0, 1, 1)
}
