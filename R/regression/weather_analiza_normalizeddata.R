#install.packages("stargazer")
library(ROCR)
library(stargazer)
library(text2vec)
library(data.table)
library(magrittr)


mydata<-read.csv("C:/Users/BUNT/Documents/JDS/R/Projekt WW2/Summary of Weather.csv")

summary(mydata)

mydata2 <- subset(mydata, select=c(MaxTemp, MinTemp))

#normalizacja
normalize <- function(x){
  return((x-min(x))/(max(x)-min(x)))
}

mydata$MinTemp <- normalize(mydata$MinTemp)
mydata$MaxTemp <- normalize(mydata$MaxTemp)


#dzielimy dane na zbior trenujacy i testujacy
mydata2$ID <- seq.int(nrow(mydata2))
setDT(mydata2)
setkey(mydata2, ID)
set.seed(2018) #wartosc dowolna zawsze wybierze te same 4000 obserwacji
all_ids = mydata2$ID
train_ids = sample(all_ids, 84000) 
test_ids = setdiff(all_ids, train_ids) 

train = mydata2[J(train_ids)] #J - to jest join
test = mydata2[J(test_ids)]

head(train)
str(train)
summary(train)

mapply(anyNA, train)

# 1.3. BoxPlot – sprawdzamy czy istnieją wartości mocno odstające od reszty
par(mfrow=c(1,2)) 
boxplot(train$MaxTemp, main="MaxTemp")
boxplot(train$MinTemp, main="MinTemp")

#sprawdz gestosci

par(mfrow=c(1,2))
plot(density(train$MaxTemp), main="MaxTemp", ylab="Czestotliwosc",
     sub=paste("Skosnosc:", round(e1071::skewness(train$MaxTemp), 1)))
polygon(density(train$MaxTemp), col="red")

plot(density(train$MinTemp), main="MinTemp", ylab="Czestotliwosc",
     sub=paste("Skosnosc:", round(e1071::skewness(train$MinTemp), 1)))
polygon(density(train$MinTemp), col="red")

skewness(train$MaxTemp) #liczy skosnosc
round(e1071::skewness(cars$speed), 1) #zaokragla do 1
paste("Skosnosc:", round(e1071::skewness(train$MaxTemp), 1)) #laczy tekst z wartoscia


# 1.5. Korelacja
cor(train$MaxTemp, train$MinTemp)

# 1.6. Model liniowy
model1 <- lm(MaxTemp ~MinTemp, data=train) # 2.3. Regresja liniowa z wykorzystaniem funkcli lm

plot(train$MaxTemp ~train$MinTemp) #scatter plot zmiennych X i Y
abline(model1, col="blue", lwd=3) #dodajemy wykres regresji liniowej do wykresu punktowego

# 2.4. Predykcja 

p1 <- predict(model1,data.frame("MinTemp"=0)) #trzeba znormalizowac x
p1

p2 <- predict(model1,test) #trzeba znormalizowac x
p2

data_with_prediction <- cbind(test, p2)

summary(model1)



MSE <- mean((data_with_prediction$MaxTemp - data_with_prediction$p2)^2)
MSE



