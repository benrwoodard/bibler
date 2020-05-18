#' word frequency table
#'
#' This function will enable a user to return a verse by using just a book, chapter, and verse .
#'
#' @param txt is the passage you want to analyze
#'
#' @return df of words and frequencies
#'
#' @import tidyverse
#' @import tm
#'
#' @export

frq <- function(txt) {

   #Replace full stop and comma
   df<-gsub("[[:punct:]]","",txt)

   df<-gsub("([0-9]{1,2})","",df)


   #Split sentence
   words<-strsplit(df," ")

   df2 <- data.frame(table(words)) %>% arrange(desc(Freq))
   #remove top words
   sw <- stopwords()

   df3 <- df2 %>%filter(!words %in% sw & words != ' ')

   df3
  }

