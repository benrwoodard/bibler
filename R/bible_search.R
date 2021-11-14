#' Search the Bible
#'
#' This will return results based on your specific search query
#'
#' @param bibleid Identifies the Bible version (required)
#' @param query Search keywords or passage reference. Supported wildcards are * and ?.The * wildcard matches any character sequence (e.g. searching for "wo*d" finds text such as "word", "world", and "worshipped"). The ? wildcard matches any matches any single character (e.g. searching for "l?ve" finds text such as "live" and "love").
#' @param limit Integer limit for how many matching results to return. Default is 10.
#' @param offset Offset for search results. Used to paginate results
#' @param sort Sort order of results. Supported values are relevance (default), canonical and reverse-canonical
#' @param range One or more, comma separated, passage ids (book, chapter, verse) which the search will be limited to. (i.e. gen.1,gen.5 or gen-num or gen.1.1-gen.3.5)
#' @param fuzziness Sets the fuzziness of a search to account for misspellings. Values can be 0, 1, 2, or AUTO. Defaults to AUTO which varies depending on the
#' @param apikey API.bible api key. Sign up here https://scripture.api.bible/signup
#'
#' @param debug Used to help debug the query
#'
#' @import dplyr
#' @import tibble
#' @import tidyr
#' @importFrom magrittr %>%
#' @importFrom httr RETRY
#' @importFrom httr add_headers
#' @importFrom httr verbose
#' @importFrom utils URLencode
#' @importFrom purrr map_chr
#' @export
bible_search <- function(bibleid = Sys.getenv('MAIN_BIBLEID'),
                         query = NULL,
                         limit = 10,
                         offset = NULL,
                         sort = 'relevance',
                         range = NULL,
                         fuzziness = 'AUTO',
                         debug = FALSE,
                         apikey = Sys.getenv('BIBLER_APIKEY')) {

  if(is.null(bibleid)){
    stop("Please provide a bibleid value")
  }
  #remove spaces from the list of range items
  if(!is.na(paste(range,collapse=","))) {
    range_str <- paste(range,collapse=",")
  }
  query <-  URLencode(query)

  vars <- tibble::tibble(query,
                         limit,
                         offset,
                         sort,
                         range,
                         fuzziness)


  #Turn the list into a string to create the query
  prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
  #remove the extra parts of the string and replace it with the query parameter breaks
  query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

  baseurl <- sprintf('https://api.scripture.api.bible/v1/bibles/%s/search',
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

  res <- httr::content(req)$data


  refs <- purrr::map_chr(res$verses, function(x){
    unlist(x$id)
  })
  text <- purrr::map_chr(res$verses, function(x){
    unlist(x$text) %>% trimws()
  })

  if(res$total > limit) {
  message(glue::glue('You search results are ready now. Your request limited to the results to {limit}.\nThere are {res$total} results available.'))
  }
  return(tibble::tibble(refs, text) %>%
           dplyr::rename(reference = 1,
                         verse = 2))
}
