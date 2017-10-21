# this simple sentiment AnalyseR is based on bag-of-words(BoW)


# load all necessary libraries
source("./load_libs.r")


# set up the connection to your Twitter dev account
source("./easySentimentAnalyseR_Setup_Twitter.r")


# load functions
source("./funcs.r")


# load potentially necessary dictionaries
source("./load_dictionaries.r")


search_str = "the-topic_you_wanna_search"
num_twts = num_of_tweets # the number of tweets you wanna search
lang = "en" # lang: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes


# pay attention to the rate limiting 
# see --> (https://developer.twitter.com/en/docs/basics/rate-limiting)
# ?searchTwitteR to see other potential args
your_tweets <- searchTwitter(searchString = search_str, n = num_twts, lang = lang, since = "2017-10-20", until = "2017-10-21")


# fetch all the texts
tweets_list <- sapply(your_tweets, function(x){
      x$getText() %>% 
            str_replace_all(pattern = "http(s)?.*",replacement = " ") %>% # clear urls beforehand
            str_replace_all(pattern = "^RT|@([a-zA-Z0-9:]*\\s+){1}", replacement = "") # clear @users
})


# create copy of your corpus
# cleaning process should be decided based on your actual searching condition
copy_tweets_corpus <-  VCorpus(VectorSource(tweets_list)) %>%
      tm_map(str_to_lower) %>% # turn all characters to lower case
      tm_map(removeNumbers) %>% # remove numbers
      tm_map(removePunctuation) %>% 
      tm_map(function(x) {
            removeWords(x, c(stopwords,str_replace_all(str_to_lower(search_str), "^#", ""))) %>% # remove stop words and the searching word
             str_replace_all(pattern = "[^a-zA-Z\\s'-]",replacement = "")
      }) %>% 
      tm_map(PlainTextDocument) 


# clean corpus based your actual searching condition
tweets_corpus <-  VCorpus(VectorSource(tweets_list)) %>% # generate a volatile corpus (you can try "Permanent" one or "Simple" one)
      tm_map(str_to_lower) %>% # turn all characters to lower case
      tm_map(removeNumbers) %>% # remove numbers
      tm_map(removePunctuation) %>% # remove puncuations
      tm_map(function(x) {
            removeWords(x, c(stopwords,str_replace_all(str_to_lower(search_str), "^#", ""))) %>% # remove stop words and the searching word
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


# tweets_dtm <- TermDocumentMatrix(tweets_corpus)
# tweets_dtm_matrix <- as.matrix(tweets_dtm)
# v <- sort(rowSums(tweets_dtm_matrix),decreasing=TRUE)
# tweets_dtm_dt <- data.table(word = names(v),freq=v)
# head(tweets_dtm_dt, 10)
# set.seed(1234)
# wordcloud(words = tweets_dtm_dt$word, freq = tweets_dtm_dt$freq, colors = brewer.pal(n = 5, name = "Dark2"), rot.per = .3, min.freq = 2, scale = c(4,1), random.color =  F, max.words = 50, random.order = F)


# save the codes above, draw word cloud with func: wordcloud() directly
set.seed(123) # set a seed to keep the word cloud reproducible
wordcloud(tweets_corpus, colors = brewer.pal(n = 5, name = "Dark2"), rot.per = .3, min.freq = 2, scale = c(4,1), random.color =  F, max.words = 50, random.order = F)


# create term doc matrix
tweets_dtm <- TermDocumentMatrix(x = tweets_corpus) # generate term doc matrix
tweets_dtm<- tweets_dtm %>% removeSparseTerms(sparse=0.94) # remove highly sparse terms, the %>% was avoided in order to tune results conveniently


set.seed(123)
# cluster words - based on hierarchical clustering
tweets_hclust <-  tweets_dtm %>% 
      scale() %>% # scale the matrix
      dist(method = "euclidean") %>% # calculate the distances among terms based on "euclidean" distance
      hclust(method = "average")


# visualize hierarchical clustering results
par(mar=c(9,4,4,2))
draw_dendrogram(hclust = tweets_hclust, num_cluster = 3, main_title = "Word Clusters", border_type = 8, border_lin_type = 5, border_line_width = 2)


# calculate sentiment scores based on J.Breen approach (https://jeffreybreen.wordpress.com/2011/07/04/twitter-text-mining-r-slides/)
scores <- calclulate_score(tweets_corpus,pos,neg)

global.score <- round(sum(scores$pos.score)/(sum(scores$pos.score)+sum(scores$neg.score)),digits = 2)

df <- data.table(search_str = search_str, data = Sys.Date(), score = global.score)

df

# measure the sentiment score with another dictionary -- nrc dictionary
# turn your corpus into character vector
tweet_char_vec <- sapply(tweets_corpus, '[', "content") %>% unlist %>% as.character() %>% paste(collapse = ' ')

tweet_sent <- get_nrc_sentiment(tweet_char_vec)
