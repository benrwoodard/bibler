#' Get a list of available verses
#'
#' This will pull a list of all available verses
#'
#' @param bibleid Id of Bible whose Verses to fetch
#' @param chapterid Id of the Book whose Verses to fetch
#' @param debug Used to help debug the query
#' @param apikey API.bible api key. Sign up here https://scripture.api.bible/signup
#'
#' @import dplyr
#' @import tibble
#' @importFrom glue glue
#' @importFrom purrr discard
#' @importFrom magrittr %>%
#' @importFrom httr RETRY
#' @importFrom httr add_headers
#' @importFrom httr verbose
#' @export
verses <- function(bibleid = Sys.getenv('MAIN_BIBLEID'),
                   chapterid = NULL,
                   debug = FALSE,
                   apikey = Sys.getenv('BIBLER_APIKEY')) {


  baseurl <- 'https://api.scripture.api.bible/v1/bibles'

  req_url <- glue::glue('{baseurl}/{bibleid}/chapters/{chapterid}/verses')

  #debug setup
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

  res1 <- httr::content(req)$data

  res2 <- tibble::as_tibble(do.call(rbind, res1))
  res2 %>%
    dplyr::mutate(across(.cols = everything(), as.character))
}
