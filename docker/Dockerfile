# Use shiny-verse which comes with tidyverse and shiny pre-installed
FROM rocker/shiny-verse:latest

# Set working directory
WORKDIR /srv/shiny-server/

# Install only the essential packages
RUN R -e "install.packages(c('wordcloud', 'tm'), repos='https://cloud.r-project.org/')"

# Copy app files
COPY . /srv/shiny-server/

# Make sure the directory is writable
RUN chown -R shiny:shiny /srv/shiny-server/

# Use port 8080
EXPOSE 8080

# Run app
CMD R -e "shiny::runApp('/srv/shiny-server/', host = '0.0.0.0', port = 8080)"

