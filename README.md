
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bibler

<!-- badges: start -->
<!-- badges: end -->

The goal of the bibler package is to enable the analyst to use and
improve their skills while enhancing their Bible Study time.

## Installation

bibler is not on CRAN yet but you can download the development version
from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("benrwoodard/bibler")
```

## Authentication

The bibler package relies on the
[API.Bible](https://scripture.api.bible/) project. I honestly do not
know much about it other than what I have read on [the welcome
page](https://docs.api.bible/). I went through several different
iterations in the development of the package and finally settled on this
API because of the simplicity and solid documentation.

**Current Process** In order to pull any data from the API you will need
to signup for an account.

1.  Register as a Developer

The first step to get access to API.Bible is to register as a developer.
Fill out and submit the form at <https://scripture.api.bible/signup>.

Once you submit the form, you will receive an email with a link to
verify your email address. You will be able to sign in to your account
after verifying your email. If you don’t see the email, be sure to check
your spam folder.

2.  Create your App

Once you have an account, create your app by going to
<https://scripture.api.bible/admin/applications/new>. You should be
taken there automatically the first time you login to your account.
After submitting your application, you must wait for it to be approved.

When you create an app, you are also applying for an API key. Give as
much information as possible to make it more likely your app will be
approved."

3.  Add the API Key

Once you have been approved you can go into your account and copy the
API key. You can either use this in very function as an argument,
`apikey =`, or add it to the .Renviron\* file (recommended). Once added
to the .Renviron file using the variable name `BIBLER_APIKEY` you need
to **restart your R session**.

Now you are ready to being pulling data from the API.

\*For more information about the .Renviron file, [go
here](http://www.dartistics.com/renviron.html).

## Examples

Here are some basic functions you an use to get started:

1.  Pull a list of all available bibles

``` r
library(bibler)

bibles_list <- bibles(language = 'eng', name = 'king james')

bibles_list
#> # A tibble: 2 × 14
#>   id       dblId   relatedDbl name      nameLocal  abbreviation abbreviationLoc…
#>   <chr>    <chr>   <chr>      <chr>     <chr>      <chr>        <chr>           
#> 1 de4e12a… de4e12… NULL       King Jam… King Jame… engKJV       KJV             
#> 2 de4e12a… de4e12… NULL       King Jam… King Jame… engKJV       KJV             
#> # … with 7 more variables: description <chr>, descriptionLocal <chr>,
#> #   language <chr>, countries <chr>, type <chr>, updatedAt <chr>,
#> #   audioBibles <chr>
```

This result will show you all the different translations with the phrase
‘king james’ in the `name`. I recommend copying the id of your main
version and adding that to the .Renviron file for quicker function
calls. The package is developed to reference the API key and main Bible
Id using the .Renviron file. Add `MAIN_BIBLEID` as a variable in the
file and restart the R session.

2.  Search to find a word or phrase you have been looking for.

``` r
bible_search(query = 'moses held')
#> You search results are ready now. Your request limited to the results to 10.
#> There are 11 results available.
#> # A tibble: 10 × 2
#>    reference verse                                                              
#>    <chr>     <chr>                                                              
#>  1 EXO.34.8  And Moses made haste, and bowed his head toward the earth, and wor…
#>  2 EXO.17.11 And it came to pass, when Moses held up his hand, that Israel prev…
#>  3 LEV.8.20  And he cut the ram into pieces; and Moses burnt the head, and the …
#>  4 LEV.10.3  Then Moses said unto Aaron, This is it  that the  LORD  spake, say…
#>  5 LEV.8.9   And he put the mitre upon his head; also upon the mitre, even  upo…
#>  6 DEU.27.9  ¶ And Moses and the priests the Levites spake unto all Israel, say…
#>  7 ACT.26.22 Having therefore obtained help of God, I continue unto this day, w…
#>  8 1CH.22.13 Then shalt thou prosper, if thou takest heed to fulfil the statute…
#>  9 JOS.1.14  Your wives, your little ones, and your cattle, shall remain in the…
#> 10 2CH.33.8  Neither will I any more remove the foot of Israel from out of the …
```
