
#deploy to shinyapps.io
#first you will need an account

install.packages('rsconnect')

#name is account name, get both your authentication token and secret in your account
#rsconnect::setAccountInfo(name='hengyuanliu',
#                          token='<hide>',
#                          secret='<SECRET>')
rsconnect::setAccountInfo(name='hengyuanliu', 
                          token='hide', 
                          secret='hide')

#setwd("~Users/Documents/UCLA/shiny-app-418")
library(rsconnect)
rsconnect::deployApp(appDir = 'docker/',appName="uclaclubs")

#this is now running at
#https://hengyuanliu.shinyapps.io/uclaclubs/
