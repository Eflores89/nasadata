#' Calls EONET webservice
#'
#' Calls NASA's Earth Observatory Natural Event Tracker (EONET) webservice and returns a data.frame with individual event or events.
#'
#' @details
#'
#' @param status Accepts 1 or 0 (open or closed). Defaults to "all", which includes both.
#' @param sources Accepts character id strings from EONET sources (see \code{eonet_sources})
#' @param category_id bla
#' @param limit vla
#' @param days jks
#' @param LimitType lvo
#' @param TrySimplify lasn
#'
#' @importFrom dplyr inner_join
#' @importFrom jsonlite fromJSON
#'
#' @export
earth_event <- function(status = "all",
                        sources = "all",
                        category_id = "all",
                        limit = 10,
                        days = 20,
                        LimitType = "limit",
                        TrySimplify = TRUE)
  {
  # http://eonet.sci.gsfc.nasa.gov/api/v2.1/events?source=InciWeb&limit=12&days=20&status=open

  h <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/events?"
  # Limits
  if(LimitType == "limit"){
    limit <- paste0("limit=",limit)
  }else{
    if(LimitType == "days"){
      limit <- paste0("days=",days)
    }else{
      if(LimitType == "all"){
        limit <- paste0("limit=",limit,"&days=",days)
      }else{
        #fail
        stop("LimitType is not recognizable. Set to: limit, days or all")
      }
    }
  }
  # - Start creating series
    # status ----
  if(status=="all"){
    s <- paste0(h, limit)
  }else{
    if(status == 1){
      s <- paste0(h, limit, "status=open")
    }else{
      if(status == 0){
        s <- paste0(h, limit, "status=open")
      }else{
        #fail
        stop("Status is not 1 (open) or 0 (closed)")
      }
    }
  }
    # sources ----
  if(sources=="all"){
    s <- s
  }else{
    s <- paste0(s, "source=", sources)
  }
    # categories ----
  if(category_id=="all"){
    s <- s
  }else{
    # Use Category API...

    s <- paste0(s, "categories=", category_id)
  }

  # event
  e <- jsonlite::fromJSON("http://eonet.sci.gsfc.nasa.gov/api/v2.1/events?limit=10")
  events <- e$events
  events <- data.frame("event_id" = events$id,
                       "event_title"  = events$title,
                       "event_description" = events$description,
                       "event_link" = events$link)

  # category ----
  categories <- as.data.frame(t(sapply(X = e$events$categories, FUN = "[")))
    # Replacing names
      nn <- paste0("category_",names(categories))
      names(categories) <- nn
  categories$event_id <- events$event_id

  # geometry -----
  if(TrySimplify){
    if(length(categories[,1])==length(unique(events$event_id))){
      obj <- inner_join(events, categories, by = c("event_id"))
    }else{
      obj <- list("Events" = events,
                  "Categories" = categories)
    }
  }

  return(obj)
 }
#' Calls EONET category webservice
#'
#' Calls NASA's Earth Imagery API and returns data.frame with information on time
#'
#'
#' @export
eonet_categories <- function( limit = 10)
{
  categories <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/categories"
  e <- jsonlite::fromJSON(categories)
  df <- e$categories



  h <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/events?"
  limit = 10





}
#' Calls EONET sources webservice
#'
#' Calls NASA's Earth Imagery API and returns data.frame with information on time
#'
#'
#' @export
eonet_sources <- function( limit = 10)
{
  categories <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/categories"
  e <- jsonlite::fromJSON(categories)
  df <- e$categories



  h <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/events?"
  limit = 10





}
