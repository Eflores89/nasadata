#' Trace a satellite route
#'
#' Calls NASA's Earth Imagery Assets API and returns data.frame with information on time and location between two dates to "trace" a satellites path.
#' @param key Key for API authentication.
#' @param lon Longitud of coordinate position.
#' @param lat Latitud of coordinate position.
#' @param start_date Start date to search for image. In YYYY-MM-DD format.
#' @param end_date End date to search for image. In YYYY-MM-DD format. Defaults to current system date.
#'
#' @export
earth_asset <- function(key, lon, lat, start_date, end_date = Sys.Date()){
  h <- "https://api.nasa.gov/planetary/earth/assets?"

  # https://api.nasa.gov/planetary/earth/assets?lon=100.75&lat=1.5&begin=2014-02-01&api_key=DEMO_KEY
  query <- paste0(h,
                  "lon=", lon, "&",
                  "")
  s <- jsonlite::fromJSON(query)


}









#' Trace a satellite route
#'
#' Calls NASA's Earth Imagery Assets API and returns data.frame with information on time and location between two dates to "trace" a satellites path.
#' @param key Key for API authentication.
#'
#' @export
trace_sat <- function(key, lon1, lon2, lat1, lat2, date1, date2, cloud_score = TRUE, plot = FALSE, meta_only = FALSE)
{
  # Validate a few things
  if(!is.numeric(lon)){
    stop("Lon parameter must be numeric")
  }
  if(!is.numeric(lat)){
    stop("Lat parameter must be numeric")
  }

  # ojo con el "true"
  h <- "https://api.nasa.gov/planetary/earth/imagery?"
  query <- paste0(h,
                  "lon=", lon, "&",
                  "lat=", lat, "&",
                  "date=", date, "&",
                  "cloud_score=", cloud_score, "&",
                  "api_key=", key)
  s <- jsonlite::fromJSON(query)

  if(is.null(s$cloud_score)){
    s$cloud_score <- "NA"
  }

  image_data <- data.frame("Date" = s$date,
                           "URL" = s$url,
                           "CloudScore" = s$cloud_score,
                           "ID" = s$id)
  if(!meta_only){
    z <- tempfile()
    download.file(s$url, z, mode = "wb")
    image <- png::readPNG(z)
    file.remove(z)
  }

  l <- list(image_data)
  if(plot){
    rasterImage(image,0,0,1,1)
  }
  return(l)
}


