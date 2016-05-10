#' Call Asset API
#'
#' Calls NASA's Earth Imagery Assets API and returns data.frame with information
#' on time and location of images between two dates.
#' @param key Key for API authentication.
#' @param lon Longitud of coordinate position.
#' @param lat Latitud of coordinate position.
#' @param start_date Start date to search for image. In YYYY-MM-DD format.
#' @param end_date End date to search for image. In YYYY-MM-DD format. Defaults
#'   to current system date.
#'
#' @return Returns a \code{data.frame} containing the following columns:
#' \item{date}{date of the sample}
#' \item{id}{identifier of the sample or "NO RESULTS"}
#' \item{type}{type of the sample, currenlty always "Point"}
#' \item{coordinates}{latitude and longitude as a string delimited by a space}
#'
#' @examples
#'\dontrun{
#' key <- "123key"
#' img <- earth_asset(key, -100.31008, 25.66779, "2016-01-01")
#'}
#'
#' @importFrom jsonlite fromJSON
#' @export
earth_asset <- function(key, lon, lat, start_date, end_date = Sys.Date()) {

  # Validate parameters and fail fast
  if (!is.numeric(lon)) {
    stop("Lon parameter must be numeric")
  }
  if (!is.numeric(lat)) {
    stop("Lat parameter must be numeric")
  }

  tryCatch({
    start_date <- as.Date(start_date)
    end_date <- as.Date(end_date)
  },
  error = function(e) {
    stop("Date parameters must be YYYY-MM-DD")
  })

  # construct the query URL with parameters
  query <- sprintf("%s?lon=%s&lat=%s&begin=%s&api_key=%s",
                   "https://api.nasa.gov/planetary/earth/assets",
                   lon, lat, start_date, key)

  # add "end" parameter if necessary
  if (Sys.Date() != end_date) {
    query <- sprintf("%s&end=%s", query, end_date)
  }

  reply <- fromJSON(query)

  if ("error" %in% names(reply)) {
    stop(paste0("NASA API Error\n",
                "The following is the output: ", reply$error ))
  }

  coordinates <- sprintf("%s %s", lon, lat)

  # data.frame will be returned
  if (reply$count < 1) {
    data.frame("date" = "1900-01-01",
               "id" = "NO RESULTS",
               "type" = "Point",
               "coordinates" = coordinates)
  } else {
    data.frame("date" = reply$results$date,
               "id" = reply$results$id,
               "type" = "Point",
               "coordinates" = coordinates)
  }
}
