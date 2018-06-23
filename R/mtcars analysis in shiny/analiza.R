#install.packages('e1071', dependencies = TRUE)
library(e1071)
library(tidyverse)
library(ggplot2)
library(dplyr)

# Zadanie: zeksploruj dataset mtcars. Poszukaj interesujących zależności pomiędzy danymi.
# Zaprezentuje wyniki, np w Shiny.
  
data("mtcars")
head(mtcars)
?mtcars

summary(mtcars)

#cz 1 - Czy istnieje zależność pomiędzy zużyciem paliwa (mpg) a wagą auta (wt)? Wykorzystanie regresji liniowej 

# Scatter plot - sprawdzamy czy może istnieć liniowa zależnośc pomiędzy zmiennymi.
scatter.smooth(x=mtcars$wt, y=mtcars$mpg, main="Weight~mpg")

#wyglada na to ze jest liniowa zaleznosc - im wieksza waga tym wieksze zuzycie paliwa

# BoxPlot – sprawdzamy czy istnieją wartości mocno odstające od reszty
par(mfrow=c(1,2)) 
boxplot(mtcars$wt, main="Weight")
boxplot(mtcars$mpg, main="mpg")

#w zmiennej wt mamy outliery

#Funkacja gęstośći - sprawdzamy czy zmienna zależna ma rozkład normalny

par(mfrow=c(1,2))
plot(density(mtcars$wt), main="Weight", ylab="Czestotliwosc",
     sub=paste("Skosnosc:", round(e1071::skewness(mtcars$wt), 1)))
polygon(density(mtcars$wt), col="red")

plot(density(mtcars$mpg), main="mpg", ylab="Czestotliwosc",
     sub=paste("Skosnosc:", round(e1071::skewness(mtcars$mpg), 1)))
polygon(density(mtcars$mpg), col="red")

#uwazam ze obie zmienne maja rozklad zblizony do normalnego

#licze skosnosc dla obu zmiennych

skewness(mtcars$wt) 
round(e1071::skewness(mtcars$wt), 1) 
paste("Skosnosc Weight:", round(e1071::skewness(mtcars$wt), 1)) 

skewness(mtcars$mpg) 
round(e1071::skewness(mtcars$mpg), 1) 
paste("Skosnosc mpg:", round(e1071::skewness(mtcars$mpg), 1)) 

#Korelacja
cor(mtcars$wt, mtcars$mpg)
# -0,87 czyli korelacji wysoka odwrotna

# Model liniowy

X <- mtcars[,"wt"] #wybieramy zmienną objasnianą
Y <- mtcars[,"mpg"] #wybieramy zmienną objasniającą

model1 <- lm(Y~X)
model1 #zwraca wspolczynniki ai b



#wykres z linia regresji
plot(Y~X) 
abline(model1, col="blue", lwd=3) 

# Predykcja zuzycia paliwa dla auta o wadze = 3.000
p1 <- predict(model1,data.frame("X"=3.000)) 
p1

#cz 2 czy istnieje zaleznosc pomiedzy moca silnika (liczba koni mech.) a przyspieszeniem (czas do 1.4 mili)? 
#wykorzystaniem gradeintu

#normalizacja danych
normalize <- function(x){
  return((x-min(x))/(max(x)-min(x)))
}

mtcars$hp <- normalize(mtcars$hp)
mtcars$qsec <- normalize(mtcars$qsec)

# definiowanie zmiennych
x <- mtcars$hp
y <- mtcars$qsec

# Dopasowanie modelu regresji liniowej do danych

res <- lm(y~x)
print(res)

# Wizualizacja modelu

par(mfrow=c(1,1))
plot(x,y, col=rgb(0.2,0.4,0.6,0.4), main='Regresja liniowa - gradient prosty')
abline(res, col='blue')

# Definiujemy funkcję kosztu

cost <- function(Z, y, theta) {
  sum((Z %*% theta - y)^2)/(2*length(y)) 
}

# Learning rate i limit iteracji

alpha <- 0.07 #lernning rate
num_iters <- 600 # liczba iteracji

# Inicjalizacja parametrów

theta <- matrix(c(0,0), nrow=2) 

# Dodajemy kolumnę z 1'kami dla wyrazu wolnego

Z <- cbind(1, matrix(x))

cost_history <- double(num_iters)
theta_history <- list(num_iters)


# Gradient prosty
for (i in 1:num_iters) {
  error <- (Z %*% theta - y)
  delta <- t(Z) %*% error / length(y)
  theta <- theta - alpha * delta
  cost_history[i] <- cost(Z,y,theta)
  theta_history[[i]] <- theta
}

print(theta)

# Wizualizacja danych

plot(x,y, col=rgb(0.2,0.4,0.6,0.4), main='Linear regression by gradient descent', ylab='qsec', xlab='hp')
for (i in c(1,3,6,10,14,seq(20,num_iters,by=10))) {
  abline(coef=theta_history[[i]], col=rgb(0.8,0,0,0.3))
}
abline(coef=theta, col='blue')

# Funkcja kosztu dla kolejnych iteracji
plot(cost_history, type='line', col='blue', lwd=2, main='Funkcja kosztu',
     ylab='cost', xlab='Iteracja')



#cz 3 czy istnieje zaleznosc pomiedzy moca silnika (liczba koni mech.) a przyspieszeniem (czas do 1.4 mili)? 

ggplot(mtcars, aes(hp, qsec)) +
  geom_point()+
  geom_smooth()


#istnieje zależnośc wprostproporcjonalna - im większa liczba koni mechanicznych tym większe przyspieszenie (krótszy czas do 1/4 mili)


#cz 4 analiza zalezności zuzycia paliwa od typu skrzyni biegow. teza - automaty pala wiecej
#dziele baze na 2

cars_auto <- subset(mtcars, am == 0)

cars_manu <- subset(mtcars, am == 1)

par("mar")
par(mar=c(1,1,1,1))

par(mfrow = c(2, 1))
hist(cars_auto$mpg, main = "Distribution mpg - automatic", xlab = "mpg", breaks=5)
abline(v = mean(cars_auto$mpg), col = "red")
hist(cars_manu$mpg, main = "Distribution mpg - manual", xlab = "mpg")
abline(v = mean(cars_manu$mpg), col = "red")


#rozklad aut ze skrzynia automatyczna jest bardziej zblizony do normalnego niz z reczna
#wyglada na to ze automatiki pala mniej
#trzeba zbadać czy ta różnica jest statystycznie istotna - 
#metoda t-test
#hipoteza - różnica jest statystycznie istotna

t.test(cars_manu$mpg, cars_auto$mpg, paired = F, var.equal = F)

#p-value = 0,001374 co oznacza z^e różnica jest istotna
