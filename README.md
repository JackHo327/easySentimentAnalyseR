# easySentimentAnalyseR

[`easySentimentAnalyseR`](https://github.com/JackHo327/easySentimentAnalyseR) contains a series of [bag-of-words](https://en.wikipedia.org/wiki/Bag-of-words_model)-based (BoW-based) text mining templates in r. These templates can be used to do quick and simple sentiment analysis from several popular social networks, such as [Twitter](https://www.twitter.com), [Facebook](https://www.facebook.com), [LinkedIn](https://www.linkedin.com), [Google+](https://plus.google.com) and [Tumblr](https://www.tumblr.com).

:rocket:*Under the current development condition and plan, scripts for Twitter will be 1stly provided to do such simple and quick sentiment analysis.*:rocket:

Let's see a demo with the template I wrote for twitter.

## Register Twitter Dev Account

Based on my understanding, if you want to fetch the tweets from Twitter and have an overalll good experience, you'd better (should/have to) register its corresponding dev account through [Twitter Apps portal](https://apps.twitter.com/).

1. To do that, you must have a valid twitter normal user account, phone number or email address.
1. Then, you could log on its [app portal](https://apps.twitter.com/).
1. Next, you need to create a Twitter application.
1. Then, you should go to the `Keys and Access Token` panel and record all your information corresponding to your current application.
     4.1 **Customer Key**
     4.2 **Customer Secret**
     4.3 **Access Token**
     4.4 **Access Token Secret**
Here, I put a good video below, and it can help you register such an account, or, you could read its official [instructions](https://developer.twitter.com/en/docs/basics/getting-started).

<p align="center"><iframe width="560" height="315" src="https://www.youtube.com/embed/CVz1MjqTXMg" frameborder="0" allowfullscreen></iframe></p>

## Authentication

After you have your own account and application, then you need to use such information to replace the variable slots in `easySentimentAnalyseR_Setup_Twitter.r`.

```r
# get all credential information of your twitter developer account
# highly recommend you to store them into your OS's environment list

key <- Sys.getenv("twitter_developer_customer_key")
secret <- Sys.getenv("twitter_developer_customer_secret")
access_token <- Sys.getenv("twitter_developer_access_token")
access_token_secret <- Sys.getenv("twitter_developer_access_token_secret")
```

And then, do the authentication:

```r
# do authentication
setup_twitter_oauth(consumer_key = key, 
                        consumer_secret = secret, 
                        access_token = access_token, 
                        access_secret = access_token_secret)
```

When you see something like below:

```r
[1] "Using direct authentication"
```

it means you've successfully authenticated.

## Search Twitter

Open the `easySentimentAnalyseR_BoW_Twitter.r`, and set your own `search_str`, `num_twts` and other parameters (see `?searchTwitter`), for axample:

```r
search_str = "the_topic_you_wanna_search"
num_twts = num_of_tweets # the number of tweets you wanna search
lang = "en" # lang: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
```

## Start Analyzing Corpus

As a template, this script has already set up a general workflow for you. Thus, I think the good thing is that it can just let you focus more on the analysis part, especially when you are not a programmer but you also want to do some simple and quick sentiment analysis on a certatin topic.

If that is your requirement or goal, now the real analysis part should start officially. Based on the different context and scenario, users may need to adjust the general cleaning process by using their customized stopword list or importing other elements such as named entity, pos and so forth. Although I barely see named entity, pos and other elements are involved in BoW way, it could at least be a certain experience of trail and error. Just feel free to try to implement your thoughts.

```r
# create copy of your corpus
# cleaning process should be decided based on your actual searching condition
copy_tweets_corpus <-  VCorpus(VectorSource(tweets_list)) %>%
      tm_map(str_to_lower) %>% # turn all characters to lower case
      tm_map(removeNumbers) %>% # remove numbers
      tm_map(removePunctuation) %>% 
      tm_map(function(x) {
            removeWords(x, c(stopwords,str_replace_all(str_to_lower(search_str), "^#", ""),"RT")) %>% # remove stop words and the searching word
             str_replace_all(pattern = "[^a-zA-Z\\s'-]",replacement = "")
      }) %>% 
      tm_map(PlainTextDocument) 


# clean corpus based your actual searching condition
tweets_corpus <-  VCorpus(VectorSource(tweets_list)) %>% # generate a volatile corpus (you can try "Permanent" one or "Simple" one)
      tm_map(str_to_lower) %>% # turn all characters to lower case
      tm_map(removeNumbers) %>% # remove numbers
      tm_map(removePunctuation) %>% # remove puncuations
      tm_map(function(x) {
            removeWords(x, c(stopwords,str_replace_all(str_to_lower(search_str), "^#", ""),"RT")) %>% # remove stop words and the searching word
             str_replace_all(pattern = "[^a-zA-Z\\s'-]",replacement = "")
      }) %>% 
      tm_map(stemDocument) %>% # do stemming, sometimes it will bring confused results, used it based on you actual requirement
      tm_map(function(x){
            tmp <- strsplit(x = x, split = " ")[[1]]
            tmp <- tmp[tmp!=""]
            paste(stemCompletion(tmp, dictionary = copy_tweets_corpus),collapse = ' ')
      }) %>%
      tm_map(stripWhitespace) %>% # clean extra white spaces 
      tm_map(PlainTextDocument) # turn the corppus into plain text doc
```

## Generate Word Clouds and Calculate Sentiment Scores

After cleaning the corpus, then you are able to generate a word cloud and calculate the sentiment scores of the searching topic by changing several parameters.

Here is an example that I posted on [RPubs](http://rpubs.com/JackHo/easySentimentAnalyseR) for testing purpose.

## System Info

Also, here is some information related to my own system

```r
> sessionInfo()
R version 3.3.3 (2017-03-06)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows >= 8 x64 (build 9200)

locale:
[1] LC_COLLATE=English_United States.1252  LC_CTYPE=English_United States.1252   
[3] LC_MONETARY=English_United States.1252 LC_NUMERIC=C                          
[5] LC_TIME=English_United States.1252    

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] ggplot2_2.2.1          data.table_1.10.4-2    rJava_0.9-9            openNLP_0.2-6         
 [5] qdap_2.2.8             qdapTools_1.3.3        qdapRegex_0.7.2        qdapDictionaries_1.0.6
 [9] dendextend_1.5.2       SnowballC_0.5.1        tmcn_0.2-8             wordcloud_2.5         
[13] RColorBrewer_1.1-2     stringr_1.2.0          magrittr_1.5           httr_1.3.1            
[17] twitteR_1.1.9          XML_3.98-1.9           tm_0.7-1               NLP_0.1-11            
[21] RevoUtilsMath_10.0.0   RevoUtils_10.0.3       RevoMods_11.0.0        MicrosoftML_1.3.0     
[25] mrsdeploy_1.1.0        RevoScaleR_9.1.0       lattice_0.20-35        rpart_4.1-11          
[29] curl_2.7               jsonlite_1.5          

loaded via a namespace (and not attached):
 [1] viridis_0.4.0          gender_0.5.1           bit64_0.9-7            viridisLite_0.2.0     
 [5] foreach_1.4.3          gtools_3.5.0           assertthat_0.2.0       stats4_3.3.3          
 [9] xlsxjars_0.6.1         mrupdate_1.0.1         yaml_2.1.14            robustbase_0.92-7     
[13] slam_0.1-40            glue_1.1.1             chron_2.3-51           colorspace_1.3-2      
[17] plyr_1.8.4             pkgconfig_2.0.1        mvtnorm_1.0-6          scales_0.5.0          
[21] gdata_2.18.0           whisker_0.3-2          openssl_0.9.7          tibble_1.3.4          
[25] reports_0.1.4          nnet_7.3-12            lazyeval_0.2.0         mclust_5.3            
[29] MASS_7.3-47            class_7.3-14           tools_3.3.3            CompatibilityAPI_1.1.0
[33] trimcluster_0.1-2      xlsx_0.5.7             kernlab_0.9-25         munsell_0.4.3         
[37] plotrix_3.6-6          cluster_2.0.6          fpc_2.1-10             bindrcpp_0.2          
[41] rlang_0.1.2            grid_3.3.3             RCurl_1.95-4.8         iterators_1.0.8       
[45] rjson_0.2.15           igraph_1.1.2           labeling_0.3           bitops_1.0-6          
[49] venneuler_1.1-0        gtable_0.2.0           codetools_0.2-15       flexmix_2.3-14        
[53] DBI_0.7                reshape2_1.4.2         R6_2.2.2               gridExtra_2.3         
[57] prabclus_2.2-6         dplyr_0.7.4            bit_1.1-12             openNLPdata_1.5.3-3   
[61] bindr_0.1              modeltools_0.2-21      stringi_1.1.5          parallel_3.3.3        
[65] Rcpp_0.12.13           DEoptimR_1.0-8         diptest_0.75-7 
```
