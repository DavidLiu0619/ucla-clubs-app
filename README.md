# UCLA Clubs Explorer
**Course**: STATS 418  
**Student**: Hengyuan (David) Liu  
**Quarter**: Spring 2025

This Shiny application helps UCLA students discover and explore student organizations based on their interests. The app provides interactive visualizations and search capabilities to make club discovery easier and more intuitive.

## Features

- **Club Search**: Search for clubs by keywords, categories, or descriptions
- **Interactive Visualizations**:
  - Word cloud showing common themes across clubs
  - Bar plots showing club distribution by categories
  - Dynamic data filtering and exploration
- **Club Details**: View detailed information about each club including:
  - Description
  - Contact information
  - Meeting times and locations
  - Membership requirements

## Repository Structure

| File/Directory | Description |
|----------------|-------------|
| `code/` | Contains the main Shiny application code |
| `docker/` | Docker configuration files and setup scripts |
| `.dockerignore` | Specifies which files Docker should ignore |
| `deploy-to-shinyapps.R` | Script for deploying to shinyapps.io |

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
```

2. Build and run using Docker:
```bash
docker-compose up -d
```

3. Access the application at `http://localhost:3838`

## Deployment

The application can be deployed to shinyapps.io using the provided `deploy-to-shinyapps.R` script.

## Data Source

The application uses cleaned and processed data from the UCLA Student Organizations database, providing information about registered student clubs and organizations at UCLA.

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the terms of the license included in the repository.