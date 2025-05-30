library(shiny)
library(httr)
library(jsonlite)
library(commonmark)
library(dplyr)
library(ggplot2)
library(tm)
library(wordcloud)
library(RColorBrewer)

# Enable error logging
options(shiny.trace = TRUE)
options(shiny.fullstacktrace = TRUE)

# RAG Chatbot API endpoint
CHAT_API_URL <- "https://ucla-clubs-rag-api-980752141572.us-central1.run.app/ask"
KNN_API_URL <- "https://ucla-clubs-knn-980752141572.us-central1.run.app/predict_clubs"

# Load dataset from local file with error handling
ucla_data <- tryCatch({
  read.csv("data/ucla_orgs_cleaned.csv", stringsAsFactors = FALSE)
}, error = function(e) {
  print(paste("Error loading data:", e))
  return(NULL)
})

# Print data loading status
print(paste("Data loaded:", !is.null(ucla_data)))
if (!is.null(ucla_data)) {
  print(paste("Number of rows:", nrow(ucla_data)))
}

# Prepare overall word frequency data once
overall_word_freq <- local({
  docs <- VCorpus(VectorSource(ucla_data$description)) %>%
    tm_map(content_transformer(tolower)) %>%
    tm_map(removePunctuation) %>%
    tm_map(removeNumbers) %>%
    tm_map(removeWords, stopwords("english"))
  mat <- as.matrix(TermDocumentMatrix(docs))
  freqs <- rowSums(mat)
  data.frame(
    word = names(freqs),
    freq = freqs,
    stringsAsFactors = FALSE
  ) %>%
    filter(freq >= 2) %>%
    arrange(desc(freq))
})

server <- function(input, output, session) {
  
  # —————— Chatbot Logic ——————
  chat_error <- reactiveVal("")
  history <- reactiveVal(
    data.frame(
      author    = "bot",
      content   = "Hi! I'm the UCLA Club Chatbot. Ask me about any club opportunities you're interested in!",
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      stringsAsFactors = FALSE
    )
  )
  
  output$chat_ui <- renderUI({
    msgs <- history()
    tagList(
      lapply(seq_len(nrow(msgs)), function(i) {
        tags$div(
          class = paste("chat-message", msgs$author[i]),
          tags$div(class = "bubble", HTML(msgs$content[i])),
          tags$div(class = "timestamp", msgs$timestamp[i])
        )
      })
    )
  })
  
  observeEvent(input$go_chat, {
    req(input$q_chat)
    chat_error("")
    
    # append user question
    hist <- history()
    hist <- rbind(hist, data.frame(
      author    = "user",
      content   = input$q_chat,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      stringsAsFactors = FALSE
    ))
    history(hist)  # Update immediately with user message
    
    # call RAG API
    res <- tryCatch(
      POST(
        CHAT_API_URL,
        body = list(question = input$q_chat),
        encode = "json",
        add_headers("Content-Type" = "application/json")
      ),
      error = function(e) NULL
    )
    
    bot_msg <- if (is.null(res)) {
      "❌ Cannot connect to API."
    } else if (res$status_code != 200) {
      paste0("❌ Error: HTTP ", res$status_code)
    } else {
      out <- tryCatch(
        fromJSON(rawToChar(res$content)),
        error = function(e) NULL
      )
      if (!is.null(out$answer)) {
        md <- gsub(
          "(https?://[^[:space:]]+)",
          "[\\1](\\1)",
          out$answer,
          perl = TRUE
        )
        html <- commonmark::markdown_html(md)
        gsub(
          '<a href="([^"]+)">([^<]+)</a>',
          '<a href="\\1" target="_blank">\\2</a>',
          html,
          perl = TRUE
        )
      } else {
        "Sorry, I couldn't process that request. Please try again."
      }
    }
    
    # append bot reply
    hist <- rbind(hist, data.frame(
      author    = "bot",
      content   = bot_msg,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      stringsAsFactors = FALSE
    ))
    history(hist)
    updateTextInput(session, "q_chat", value = "")
  })
  
  # —————— KNN Model Logic ——————
  observeEvent(input$knn_search, {
    req(input$knn_query)
    
    # Call KNN API
    res <- tryCatch(
      POST(
        KNN_API_URL,
        body = list(
          query = input$knn_query,
          top = input$knn_top
        ),
        encode = "json",
        add_headers("Content-Type" = "application/json")
      ),
      error = function(e) NULL
    )
    
    output$knn_results <- renderUI({
      if (is.null(res)) {
        div(class = "knn-result", 
          style = "color: red;",
          "Error: Could not connect to the KNN service."
        )
      } else if (res$status_code != 200) {
        div(class = "knn-result", 
          style = "color: red;",
          paste0("Error: HTTP ", res$status_code)
        )
      } else {
        # Parse JSON response
        result <- fromJSON(rawToChar(res$content))
        clubs <- result[["predict clubs"]]  # Access the list using [[ ]] notation
        
        if (is.null(clubs) || length(clubs) == 0) {
          div(class = "knn-result",
            "No similar clubs found."
          )
        } else {
          # Create results UI
          tagList(
            h4("Similar Clubs Found:", style = "margin-top: 20px;"),
            lapply(1:nrow(clubs), function(i) {
              club <- clubs[i,]  # Access each row of the data frame
              div(class = "knn-result",
                div(class = "similarity",
                  paste0(round(as.numeric(club$similarity) * 100, 1), "% Match")
                ),
                div(class = "club-name",
                  tags$a(
                    href = club$detail_url,
                    target = "_blank",
                    club$name
                  )
                ),
                div(class = "club-category",
                  club$category
                )
              )
            })
          )
        }
      }
    })
  })
  
  # —————— Visualization Logic ——————
  selected_data <- reactive({
    if (is.null(input$selected_categories) || length(input$selected_categories) == 0) {
      ucla_data  # Return all data if nothing is selected
    } else {
      filter(ucla_data, category %in% input$selected_categories)
    }
  })
  
  # Calculate word frequencies based on selected data
  word_freq <- reactive({
    descs <- selected_data()$description
    req(length(descs) > 0)
    docs <- VCorpus(VectorSource(descs)) %>%
      tm_map(content_transformer(tolower)) %>%
      tm_map(removePunctuation) %>%
      tm_map(removeNumbers) %>%
      tm_map(removeWords, stopwords("english"))
    mat <- as.matrix(TermDocumentMatrix(docs))
    freqs <- rowSums(mat)
    data.frame(
      word = names(freqs),
      freq = freqs,
      stringsAsFactors = FALSE
    ) %>%
      filter(freq >= 2) %>%
      arrange(desc(freq))
  })
  
  # 1) Clubs per category
  output$category_count_bar <- renderPlot({
    df <- selected_data() %>% 
      count(category) %>% 
      arrange(desc(n)) %>%
      head(30)
    
    ggplot(df, aes(x = reorder(category, -n), y = n)) +
      geom_col(fill = "#2774AE") +
      labs(x = NULL, y = "Number of Clubs") +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
        plot.background = element_rect(fill = "white", color = NA),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank()
      )
  })
  
  # 2) Top-10 word bar
  output$top10_bar <- renderPlot({
    df <- word_freq() %>% head(15)
    ggplot(df, aes(x = reorder(word, freq), y = freq)) +
      geom_col(fill = "#FFB81C") +
      coord_flip() +
      labs(x = NULL, y = "Frequency") +
      theme_minimal() +
      theme(
        plot.background = element_rect(fill = "white", color = NA),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.y = element_text(size = 14)  # Increased text size for y-axis labels
      )
  })
  
  # 3) Word cloud - Dynamic based on selection
  output$desc_wordcloud <- renderPlot({
    df <- word_freq()
    set.seed(123)  # For consistent layout
    
    # Set margins to give more space
    par(mar = c(0,0,0,0))
    
    wordcloud(
      words = df$word,
      freq = df$freq,
      scale = c(4, 0.8),     # Adjusted scale for better size distribution
      min.freq = 8,          # Increased minimum frequency to show fewer but more significant words
      max.words = 80,        # Reduced max words to prevent overcrowding
      random.order = FALSE,
      rot.per = 0.2,         # Reduced rotation percentage for better readability
      colors = brewer.pal(8, "Blues")[3:8],
      padding = 0.8          # Added more padding between words
    )
  })
}
