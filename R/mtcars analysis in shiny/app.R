#install.packages("shinydashboard")
library(shinydashboard)
library(RPostgreSQL)
library(plyr)
library(dplyr)
library(scales)
library(wordcloud)
library(syuzhet)
library(tidyverse)
library(e1071)

library(shiny)

par(mar=c(1,1,1,1))
plot(1,1)

ui <- fluidPage(
  
      titlePanel("Analiza danych bazy mtcars"),
  
      fluidRow("Podsumowanie danych",
       dataTableOutput("sum")),

      fluidRow("Czy istnieje zależność pomiędzy zużyciem paliwa (mpg) a wagą auta (wt)? Wykorzystanie regresji liniowej ",
        plotOutput("scat")),
      
      #sprawdzamy czy istnieją wartości mocno odstające od reszty
      fluidRow(
        column(6, plotOutput("box1"),
        column(6, plotOutput("box2")))),
      
      #tutaj dodac #Funkacja gęstośći - sprawdzamy czy zmienna zależna ma rozkład normalny
      
      fluidRow("Wykres z linia regresji",
        plotOutput("reg")) ,     
        
      fluidRow("Czy istnieje zależność pomiędzy mocą silnika (liczba koni mech.) a przyspieszeniem (czas do 1.4 mili)? - gradient",
            plotOutput("grad1")),
      
      fluidRow("Czy istnieje zależność pomiędzy mocą silnika (liczba koni mech.) a przyspieszeniem (czas do 1.4 mili)? - gradient",
               plotOutput("grad2")),
      
      fluidRow("Czy istnieje zależność pomiędzy mocą silnika (liczba koni mech.) a przyspieszeniem (czas do 1.4 mili)?",
           plotOutput("smooth")),
  
      fluidRow("Analiza zależności zużycia paliwa od typu skrzyni biegów-atumatic",
           plotOutput("hist1")),
  
      fluidRow("Analiza zależności zużycia paliwa od typu skrzyni biegów-manual",
           plotOutput("hist2"))  
     
  
  
  
   )
      
#cz 4 analiza zalezności zuzycia paliwa od typu skrzyni biegow. teza - automaty pala wiecej

server <- function(input, output) {
      output$sum <- renderDataTable(
        summary(mtcars))
  
      output$scat <- renderPlot(
        scatter.smooth(x=mtcars$wt, y=mtcars$mpg, main="Weight~mpg"))
      
      output$box1 <- renderPlot(
        boxplot(mtcars$wt, main="Weight"))
      
      output$box2 <- renderPlot(
        boxplot(mtcars$mpg, main="mpg"))
      

      reg_lin <-function(){
        X <<- mtcars[,"wt"]
        Y <<- mtcars[,"mpg"]
        model1 <- lm(Y~X)
      }
      
      reg_lin()
      
      output$reg <-renderPlot(
        plot(Y~X) +
          abline(reg_lin(), col="blue", lwd=3))
      
      grad <-function(){
        normalize <- function(x){
          return((x-min(x))/(max(x)-min(x)))
        }
        
        mtcars$hp <<- normalize(mtcars$hp)
        mtcars$qsec <<- normalize(mtcars$qsec)
        
        # definiowanie zmiennych
        x <<- mtcars$hp
        y <<- mtcars$qsec
        
        # Dopasowanie modelu regresji liniowej do danych
        
        res <- lm(y~x)
        print(res)
       }
        grad()
      
      output$grad1 <- renderPlot(
        plot(x,y, col=rgb(0.2,0.4,0.6,0.4), main='Regresja liniowa - gradient prosty')+
        abline(grad(), col='blue')
     )


      cost <- function(Z, y, theta) {
        sum((Z %*% theta - y)^2)/(2*length(y)) 
      }
      
      alpha <- 0.07 #lernning rate
      num_iters <- 600 # liczba iteracji
      theta <- matrix(c(0,0), nrow=2) 
      Z <- cbind(1, matrix(x))
      cost_history <- double(num_iters)
      theta_history <- list(num_iters)
      for (i in 1:num_iters) {
        error <- (Z %*% theta - y)
        delta <- t(Z) %*% error / length(y)
        theta <- theta - alpha * delta
        cost_history[i] <- cost(Z,y,theta)
        theta_history[[i]] <- theta
      }
      print(theta)
      
      output$grad2 <-renderPlot(
        plot(x,y, col=rgb(0.2,0.4,0.6,0.4), main='Linear regression by gradient descent', ylab='qsec', xlab='hp') +
        for (i in c(1,3,6,10,14,seq(20,num_iters,by=10))) {
          abline(coef=theta_history[[i]], col=rgb(0.8,0,0,0.3))
        } +
        abline(coef=theta, col='blue')
      )

      
      output$smooth <- renderPlot(
        ggplot(mtcars, aes(hp, qsec)) +
          geom_point()+
          geom_smooth()
      )
      
            
      hist_fn <- function(){
        cars_auto <<- subset(mtcars, am == 0)
        cars_manu <<- subset(mtcars, am == 1)
      }
      
        hist_fn()
      
      output$hist1 <- renderPlot(
        hist(cars_auto$mpg, xlab = "mpg")
                )
      output$hist2 <- renderPlot(
        hist(cars_manu$mpg, xlab = "mpg")
      )
      }


shinyApp(ui = ui, server = server)
