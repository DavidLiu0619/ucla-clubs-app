library(shiny)

# Read data from local file
ucla_data <- read.csv("data/ucla_orgs_cleaned.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  # Custom UCLA styling
  tags$head(
    tags$style(HTML("
      :root { 
        --ucla-blue: #2774AE;
        --ucla-gold: #FFD100;
        --light-gray: #f8f9fa;
      }
      body { 
        font-family: 'Segoe UI', sans-serif;
        background-color: var(--light-gray);
        min-height: 100vh;
        position: relative;
        padding-bottom: 60px;
      }
      .main-header {
        background-color: var(--ucla-blue);
        color: white;
        padding: 20px;
        margin-bottom: 20px;
        text-align: center;
        border-bottom: 4px solid var(--ucla-gold);
      }
      .main-header h1 {
        margin: 0;
        font-size: 2.5em;
      }
      .main-header p {
        margin: 10px 0 0 0;
        opacity: 0.9;
      }
      .sidebar {
        background: white;
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .content-panel {
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .chat-container { 
        height: 500px;
        overflow-y: auto;
        padding: 15px;
        background: white;
        border-radius: 8px;
        border: 1px solid #ddd;
        margin-bottom: 15px;
      }
      .chat-message {
        margin-bottom: 16px;
        clear: both;
      }
      .chat-message.user .bubble {
        float: right;
        background: var(--ucla-blue);
        color: white;
      }
      .chat-message.bot .bubble {
        float: left;
        background: var(--light-gray);
        color: #333;
      }
      .bubble {
        display: inline-block;
        padding: 10px 14px;
        border-radius: 20px;
        max-width: 75%;
      }
      .timestamp {
        display: block;
        font-size: 0.75em;
        color: #666;
        margin-top: 4px;
        clear: both;
      }
      #go_chat {
        background-color: var(--ucla-blue);
        border-color: var(--ucla-blue);
        color: white;
      }
      #go_chat:hover {
        background-color: #1b5584;
        border-color: #1b5584;
      }
      .plot-container {
        background: white;
        padding: 15px;
        border-radius: 8px;
        margin-bottom: 20px;
      }
      .plot-title {
        color: var(--ucla-blue);
        text-align: center;
        margin-bottom: 15px;
      }
      .footer {
        position: fixed;
        bottom: 0;
        left: 0;
        width: 100%;
        background: var(--ucla-blue);
        color: white;
        text-align: center;
        padding: 15px;
        font-size: 0.9em;
        border-top: 2px solid var(--ucla-gold);
      }
      .footer .social-links {
        margin-top: 10px;
        display: block;
      }
      .footer .github-icon,
      .footer .linkedin-icon {
        font-size: 1.2em;
        transition: transform 0.2s ease;
        margin: 0 10px;
      }
      .footer .github-icon:hover,
      .footer .linkedin-icon:hover {
        transform: scale(1.2);
      }
      .footer a {
        color: var(--ucla-gold);
        text-decoration: none;
        display: inline-flex;
        align-items: center;
      }
      .footer a:hover {
        text-decoration: none;
        opacity: 0.9;
      }
      .knn-section {
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin-bottom: 20px;
      }
      .knn-result {
        margin: 10px 0;
        padding: 15px;
        border: 1px solid #eee;
        border-radius: 8px;
        transition: all 0.3s ease;
      }
      .knn-result:hover {
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      }
      .knn-result .club-name {
        color: var(--ucla-blue);
        font-weight: bold;
        margin-bottom: 5px;
      }
      .knn-result .club-category {
        color: #666;
        font-size: 0.9em;
      }
      .knn-result .similarity {
        color: var(--ucla-blue);
        font-weight: bold;
        float: right;
      }
      .knn-input {
        margin-bottom: 20px;
      }
    "))
  ),
  
  # Include Font Awesome for GitHub icon
  tags$head(tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css")),
  
  # Main Header
  div(class = "main-header",
    h1("UCLA Clubs Explorer"),
    p("Discover and Learn About Student Organizations at UCLA")
  ),
  
  # Main Layout
  fluidRow(
    # Data Exploration Sidebar
    column(3,
      div(class = "sidebar",
        h3("Data Exploration", style = "color: var(--ucla-blue)"),
        selectInput(
          inputId = "selected_categories",
          label = "Filter by Categories:",
          choices = sort(unique(ucla_data$category)),
          selected = NULL,
          multiple = TRUE
        ),
        helpText("Select categories to filter the visualizations, or leave empty to see overall statistics."),
        
        # Add KNN Search Section
        hr(),
        h3("Similar Clubs Finder", style = "color: var(--ucla-blue)"),
        div(class = "knn-input",
          textInput("knn_query", "Search Similar Clubs:", placeholder = "Enter keywords (e.g., health, sports)"),
          numericInput("knn_top", "Number of Results:", value = 4, min = 1, max = 10),
          actionButton("knn_search", "Find Similar Clubs", 
            class = "btn-primary",
            style = "width: 100%; background-color: var(--ucla-blue); border-color: var(--ucla-blue);"
          )
        ),
        # Results will be shown here
        uiOutput("knn_results")
      )
    ),
    
    # Main Content Area
    column(6,
      div(class = "content-panel",
        # Data Visualization Section
        div(class = "plot-container",
          h3(class = "plot-title", "Clubs by Category"),
          plotOutput("category_count_bar", height = "300px")
        ),
        div(class = "plot-container",
          h3(class = "plot-title", "Most Common Words"),
          plotOutput("top10_bar", height = "300px")
        ),
        div(class = "plot-container",
          h3(class = "plot-title", "Word Cloud Overview"),
          plotOutput("desc_wordcloud", height = "300px")
        )
      )
    ),
    
    # Chatbot Sidebar
    column(3,
      div(class = "sidebar",
        h3("Club Chatbot", style = "color: var(--ucla-blue)"),
        div(class = "chat-container",
          uiOutput("chat_ui")
        ),
        textInput("q_chat", NULL, 
          placeholder = "Ask about UCLA clubs...",
          width = "100%"
        ),
        actionButton("go_chat", "Ask", 
          class = "btn-primary",
          style = "width: 100%; margin-top: 10px;"
        )
      )
    )
  ),
  
  # Footer
  tags$div(class = "footer",
    div(
      "Built with R Shiny + Python Gemini API • Based on data from ",
      tags$a(href = "https://community.ucla.edu/studentorgs", target = "_blank", "UCLA Student Organizations")
    ),
    div(class = "social-links",
      tags$a(
        href = "https://github.com/DavidLiu0619/ucla-clubs-app",
        target = "_blank",
        icon("github", class = "github-icon"),
        style = "color: var(--ucla-gold);"
      ),
      tags$a(
        href = "https://www.linkedin.com/in/hengyuanliu2001/",
        target = "_blank",
        icon("linkedin", class = "linkedin-icon"),
        style = "color: var(--ucla-gold);"
      )
    )
  )
)