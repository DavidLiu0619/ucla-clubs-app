# UCLA Clubs Explorer
**Course**: STATS 418  
**Student**: Hengyuan (David) Liu  
**Quarter**: Spring 2025

This Shiny application helps UCLA students discover and explore student organizations based on their interests. The app provides interactive visualizations and search capabilities to make club discovery easier and more intuitive.

There are three URLs that can access this app:

1. Shinyapp: https://hengyuanliu.shinyapps.io/uclaclubs/
2. Google Cloud Run: https://ucla-clubs-app-980752141572.us-west1.run.app
3. My own domain: https://uclaclubs.hyl.gd.edu.kg/

## 🧠 API Infrastructure

This web app integrates **two custom APIs** I developed and deployed via **Google Cloud Run**. You can view the full implementation on GitHub and test them with the provided `curl` commands.

---

### KNN API Github: https://github.com/DavidLiu0619/ucla-clubs-knn-api
A fast and lightweight API using **TF-IDF** and **K-Nearest Neighbors** to find similar UCLA clubs based on keyword input.
**Test with:**
```bash
curl -X POST "https://ucla-clubs-knn-980752141572.us-central1.run.app/predict_clubs" -H "Content-Type: application/json" -d '{"query": "machine learning artificial intelligence", "top": 4}'
```

### Gemini+RAG API Github: https://github.com/DavidLiu0619/ucla-clubs-rag-api
A Retrieval-Augmented Generation (RAG) API that uses **LangChain**, **ChromaDB**, and **Gemini Flash** to answer natural-language questions about UCLA clubs.  
It converts CSV data into vectorized documents, retrieves the most relevant entries, and generates contextual answers using Gemini.
**Test with:**
```bash
curl -X POST "https://ucla-clubs-rag-api-980752141572.us-central1.run.app/ask" -H "Content-Type: application/json" -d '{"question":"I am a freshman student. Can you recommend some UCLA clubs?"}'
```



## Data Source

The application uses cleaned and processed data from the UCLA Student Organizations database: https://community.ucla.edu/studentorgs
Note: The data is webscrapped on April 27, 2025, so the data might be different while you seeing now. (You can refer the folder '/code/webscrapping.ipynb' in this repo.

## Exploratory Data Analysis

| Metric             | Count  |
|--------------------|--------|
| Total Categories   | 48     |
| Total Club Records | 2,829  |
| Unique Clubs       | 1,439  |

### Distribution of Clubs by Category
![Bar Plot of Club Categories](assests/bar_plots.png)


<video src="assests/short_demo.mp4" controls="controls" style="max-width: 730px;">
</video>


## Features

[https://github.com/DavidLiu0619/ucla-clubs-app/assets/short_demo.mp4?raw=true](https://github.com/user-attachments/assets/13da64fd-984d-4a29-a0fe-8f9d0ab5b7b7)

- **Interactive Visualizations**:
  - The user can select multiple Club Categories, and it will show:
    - Bar plots showing club distribution by categories
    - Bar plots of the most common words
    - Word cloud showing common themes across clubs
- **KNN Similarity Club Finder**:
  - The user can input the keywords and number of results
    - The table includes: Name of Clubs, Category, Clickable Link, and Similarity Score
- **Club Chatbot**: 
  - An AI Agent based on RAG Framework and Gemini API
  - The user can ask questions, and the chatbot can answer.

## Repository Structure

| File/Directory | Description |
|----------------|-------------|
| `code/` | Contains the Webscrapping and EDA code |
| `docker/` | Docker configuration files and setup scripts |
| `.dockerignore` | Specifies which files Docker should ignore |
| `deploy-to-shinyapps.R` | Script for deploying to shinyapps.io |
| `assets/` | figures and presentation slides |

## Local Development

### Prerequisites
- R (version 4.0 or higher)
- Required R packages (can be installed using `install_packages.R`):
  - shiny
  - dplyr
  - ggplot2
  - wordcloud
  - wordcloud2
  - and other dependencies

### Running Locally with Docker

1. Clone this repository:
```bash
git clone https://github.com/DavidLiu0619/ucla_clubs_app.git
cd ucla_clubs_app
cd docker
```

2. Build and run using Docker:
```bash
docker compose up -d
```

3. Access the application at `http://localhost:8080`

4. Stop Docker:
```bash
docker compose down -v
```

## Deployment

The application can be deployed to 
* shinyapps.io using the provided `deploy-to-shinyapps.R` script.
* Google Cloud Run


## License

This project is licensed under the terms of the license included in the repository.
