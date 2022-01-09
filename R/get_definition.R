#' Reference word definitions
#'
#'  This function will pull in the definitions of a word from the Webster Mariam Collegiate dictionsary
#'
#' @param word The desired word you need to look up
#' @param key The Webster dictionary API key
#'
#' @importFrom httr GET
#' @importFrom glue glue
#' @importFrom purrr map_df
#' @export
#' @return A list of definitions
#'
define <- function( word = 'test',
                    key = Sys.getenv('WEBSTER_KEY')) {

  baseurl <- 'https://www.dictionaryapi.com/api/v3/references/collegiate/json/'

  requrl <- glue::glue('{baseurl}{word}?key={key}')

  def <-  httr::GET(url = requrl)

  df <- httr::content(def)

  purrr::map_df(seq(df), function(x){
    uno =  data.frame(type = df[[x]]$fl)
    dos = data.frame(dataname = df[[x]]$shortdef[[1]])
    data.frame(c(uno, dos))
  })

}
