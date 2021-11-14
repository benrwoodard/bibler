#' Get a list of available books
#'
#' This will pull a list of all available books in a particular version
#'
#' @param bibleid Identifies the Bible version (required)
#' @param chapters Boolean indicating if an array of chapter summaries should be included in the results. Defaults to false.
#' @param sections Boolean indicating if an array of chapter summaries and an array of sections should be included in the results. Defaults to false.
#' @param debug Used to help debug the query
#' @param apikey API.bible api key. Sign up here https://scripture.api.bible/signup
#'
#' @import dplyr
#' @import tibble
#' @import tidyr
#' @importFrom magrittr %>%
#' @importFrom httr RETRY
#' @importFrom httr add_headers
#' @importFrom httr verbose
#' @export
books <- function(bibleid = Sys.getenv('MAIN_BIBLEID'),
                  chapters = FALSE,
                  sections = FALSE,
                  debug = FALSE,
                  apikey = Sys.getenv('BIBLER_APIKEY')) {

  if(is.null(bibleid)){
    stop("Please provide a bibleid value")
  }

  vars <- tibble::tibble(`include-chapters` = chapters,
                         `include-chapters-and-sections` = sections)


  #Turn the list into a string to create the query
  prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
  #remove the extra parts of the string and replace it with the query parameter breaks
  query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

  baseurl <- sprintf('https://api.scripture.api.bible/v1/bibles/%s/books',
                     bibleid)

  req_url <- glue::glue('{baseurl}?{query_param}')

  #debug the api call?
  debug_call <- NULL
  if (debug) {
    debug_call <- httr::verbose(data_out = TRUE, data_in = TRUE, info = TRUE)
  }

  req <- httr::RETRY("GET",
                     url = req_url,
                     encode = "json",
                     debug_call,
                     httr::add_headers(
                       `api-key` = apikey
                     ))
  #check status
  httr::stop_for_status(req, task = httr::content(req)$message)

  tibble::as_tibble(do.call(rbind, httr::content(req)$data)) %>%
    dplyr::mutate(across(.cols = everything(), as.character))
}
