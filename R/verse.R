#' Get a verse
#'
#' This will pull a verse
#'
#' @param bibleid Id of Bible whose Chapters to fetch
#' @param verseid Id of the verse to fetch
#' @param contenttype Content type to be returned in the content property. Supported values are html (default), json (beta), and text (beta)
#' @param includenotes Include footnotes in content
#' @param includetitles Include section titles in content
#' @param includechapternumbers Include chapter numbers in content
#' @param includeversenumbers Include verse numbers in content.
#' @param includeversespans Include spans that wrap verse numbers and verse text for bible content.
#' @param parallels Comma delimited list of bibleIds to include
#' @param useorgid Use the supplied id(s) to match the verseOrgId instead of the verseId
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
#'
#' @export
verse <- function(bibleid = Sys.getenv('MAIN_BIBLEID'),
                  verseid = NULL,
                  contenttype = 'text',
                  includenotes = FALSE,
                  includetitles = TRUE,
                  includechapternumbers = FALSE,
                  includeversenumbers = TRUE,
                  includeversespans = FALSE,
                  parallels = c('55212e3cf5d04d49-01','3aefb10641485092-01'),
                  useorgid = FALSE,
                  debug = FALSE,
                  apikey = Sys.getenv('BIBLER_APIKEY')) {

  if(is.null(bibleid)){
    stop("Please provide a bibleid value")
  }

  #remove spaces from the list of parallel items
  if(!is.na(paste(parallels,collapse=","))) {
    parallel_str <- paste(parallels,collapse=",")
  }

  vars <- tibble::tibble(`content-type` = contenttype,
                         `include-notes` = includenotes,
                         `include-titles` = includetitles,
                         `include-chapter-numbers` = includechapternumbers,
                         `include-verse-numbers` = includeversenumbers,
                         `include-verse-spans` = includeversespans,
                         `parallels` = parallel_str,
                         `use-org-id` = useorgid)


  #Turn the list into a string to create the query
  prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
  #remove the extra parts of the string and replace it with the query parameter breaks
  query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

  baseurl <- sprintf('https://api.scripture.api.bible/v1/bibles/%s/verses',
                     bibleid)


  req_url <- glue::glue('{baseurl}/{verseid}?{query_param}')

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

  res <- httr::content(req)$data

  if(is.null(parallels)) {
   return(c(reference = res$reference,
           passage = res$content))
  } else {
    biblenames <- map_chr(res$parallels, function(x){
      bibles(ids = x$bibleId)$name
    })
    pars <- map_chr(res$parallels, function(x){
      unlist(x$content) %>% trimws()
    })

    return(tibble::tibble(biblenames, pars) %>%
             dplyr::rename(bible = 1,
                   verse = 2))
  }
}
