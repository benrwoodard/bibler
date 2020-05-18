#' enables a search function
#'
#' This function will enable me to search a phrase or word and return
#' the number of verses along with a quick reference.
#'
#' @param searchphrase the pharase you want to seach
#' @param translation either kjv or asv at this time
#' @param testament_filter chooce from either OT or NT or both (default)
#' @param ignorecase Setting this to TRUE (defualt) will ignore whether the letters are upper or lwoer case
#'
#' @import tidyverse
#' @export


search <- function(searchphrase = NA, translation = 'kjv', testament_filter = c('OT', 'NT'), ignorecase = TRUE) {

  load("~/Documents/bibler/data/bible.rda")

  bible %>%
    filter(testament %in% testament_filter) %>%
    filter(grepl(searchphrase,kjv, ignore.case = ignorecase) | grepl(searchphrase, asv , ignore.case = ignorecase) ) %>%
    mutate(ref = paste0(book, ' ', chapter, '.', verse )) %>%
    select(ref, verse = all_of(translation), testament)
}
