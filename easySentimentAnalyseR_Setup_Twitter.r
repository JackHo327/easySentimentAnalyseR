### remember twitter only allow 15 scrapes per 15 mins ###
### remember twitter only allow 15 scrapes per 15 mins ###
### remember twitter only allow 15 scrapes per 15 mins ###

# get all credential information of your twitter developer account
key <- Sys.getenv("twitter_developer_customer_key")
secret <- Sys.getenv("twitter_developer_customer_secret")
access_token <- Sys.getenv("twitter_developer_access_token")
access_token_secret <- Sys.getenv("twitter_developer_access_token_secret")

# do authentication
setup_twitter_oauth(consumer_key = key, consumer_secret = secret, access_token = access_token, access_secret = access_token_secret)
rm(key,secret,access_token,access_token_secret)
# testing your connection
# lang: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
# test <- searchTwitteR(searchString = "#r",n = 100, lang = "en")

### there was another potential way to connect to twitter, but now it seems not very practical. ###
### there was another potential way to connect to twitter, but now it seems not very practical. ###
### there was another potential way to connect to twitter, but now it seems not very practical. ###

# requestUrl <- Sys.getenv("twitter_developer_request_url")
# accessUrl <- Sys.getenv("twitter_developer_access_url")
# authUrl <- Sys.getenv("twitter_developer_authorize_url")
# authenticate <- OAuthFactory$new(consumerKey = key, consumerSecret = secret, requestURL = requestUrl, accessURL = accessUrl, authURL = authUrl)
# authenticate$handshake(cainfo = "./cacert.pem")
# got a key from twitter "xxxxxxx"
# run the "xxxxxxx" to finish the authentication
# save(authenticate,file = "./twitter_authentication.Rdata")
# registerTwitterOAuth(authenticate)