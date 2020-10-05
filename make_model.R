library(tidyverse)
library(lubridate)
library(plumber)
library(SnowballC)
library(tm)
library(httr)
hook <- "https://hooks.slack.com/services/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"
# Chatbot for guiding customers to required documentation

# Methdology
# 1. Convert training questions into document term matrix (sparse matrix with 1s and 0s)
# 2. Match the matrix of each training question with its corresponding answer to form a training matrix
# 3. Train Support Vector Machines model with the training matrix
# 4. Propose a testing question
# 5. Convert the testing question into document term matrix (sparse matrix with 1s and 0s)
# 6. Merge the testing DTM with training DTM, with testing DTM 1s for all terms and training DTM 0s for all terms
# 7. Predict the answer with the trained SVM model

# read data
data = read.csv("C:/Users/bmr057/Documents/Chatbot/Chatquestions.csv", stringsAsFactors = FALSE)

# 1. Convert training questions into document term matrix (sparse matrix with 1s and 0s)
#clean the text
corpus = VCorpus(VectorSource(data$Question))
corpus = tm_map(corpus, content_transformer(tolower))
corpus = tm_map(corpus, removeNumbers)
corpus = tm_map(corpus, removePunctuation)

# corpus = tm_map(corpus, removeWords, stopwords())
corpus = tm_map(corpus, stemDocument)
corpus = tm_map(corpus, stripWhitespace)

# convert to DTM
dtm = DocumentTermMatrix(corpus)

# convert to dataframe
dataset = as.data.frame(as.matrix(dtm))


# 2. Match the matrix of each training question with its corresponding answer to form a training matrix
data_train = cbind(data['Answers'], dataset)

# 3. Train SVM model with the training matrix, specify type
library("e1071")
svmfit = svm(Answers ~., data_train, kernel = "linear",  type = "C", cost = 100, scale = FALSE)

# 4. Propose a testing quesiton and build the prediction function
pred = function(x){
  
  # 5. Convert the testing question into document term matrix (sparse matrix with 1s and 0s)
  #clean the text
  corpus = VCorpus(VectorSource(x))
  corpus = tm_map(corpus, content_transformer(tolower))
  corpus = tm_map(corpus, removeNumbers)
  corpus = tm_map(corpus, removePunctuation)
  
  # corpus = tm_map(corpus, removeWords, stopwords())
  corpus = tm_map(corpus, stemDocument)
  corpus = tm_map(corpus, stripWhitespace)
  
  # convert to DTM
  dtm = DocumentTermMatrix(corpus)
  
  # convert to dataframe
  data_test = as.data.frame(as.matrix(dtm))
  
  # 6. Merge the testing DTM with training DTM, with testing DTM 1s for all terms and training DTM 0s for all terms
  add_data = dataset[1,]
  add_data[add_data == 1] = 0
  data_test=cbind(data_test,add_data)
  
  # 7. Predict the answer with the trained SVM model
  p = predict(svmfit, data_test)
  answer = as.character(p)
  body = list(text=paste("Answer: ", answer))
  POST(hook, encode = "json", body = body)
}

# Predict
pred("can i use a barcode scanner for stocktake")

# run the plumber api to get responses
#rapi <- plumber::plumb("api.R")  # Where 'api.R' is the location of the code file shown above 
#rapi$run(port=8000)
