
library('shiny')
library('twitteR')
library('RSentiment')

# Carregando variaveis de ambiente
readRenviron('.Renviron')

# Autenticacao ao Twitter
consumer_key <- Sys.getenv('CONSUMER_KEY')
consumer_secret_key <- Sys.getenv('CONSUMER_SECRET_KEY')
api_key <- Sys.getenv('API_KEY')
api_secret_key <- Sys.getenv('API_SECRET_KEY')
setup_twitter_oauth(consumer_key, consumer_secret_key, api_key, api_secret_key)


ui <- fluidPage(
        title = "Twitter Analysis",
        textInput("username", "Twitter Account", placeholder = "Username"),
        actionButton("search", "Search"),
        fluidRow(
          column(12, tableOutput('tweets_table'))
        )
)

server <- function(input, output) {
  data <- eventReactive(input$search,{
    input$username
  })
  
  output$tweets_table <- renderTable({
    
    # Coletando tweets do usuario informado
    user_timeline <- userTimeline(data(), n=10)
    df_tw <- twListToDF(user_timeline)
    
    # Calculando sentimento e score do tweet
    sentiment_score <- calculate_score(df_tw$text)
    sentiment <- calculate_sentiment(df_tw$text)
    df_sentiment_analisys <- data.frame(sentiment = sentiment$sentiment, sentiment_score)
    
    # Adicionando as colunas sentiment e sentiment_score ao data frame existente
    df <- cbind(tweet = df_tw$text, df_sentiment_analisys)
  })
}

shinyApp(ui, server)