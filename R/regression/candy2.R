#install.packages("ggcorrplot")

library(ROCR)
library(ggplot2)
library(ggcorrplot)

#Can you predict if a candy is chocolate or not based on its other features?

wojtekPath = "C:\\Users\\miser\\Documents\\Projects\\GIT\\DATA_SCIENCE\\jdsz1-sqluci\\PROJEKT_R2\\monika\\candy-data.csv"
mydata<-read.csv(wojtekPath)
#mydata<-read.csv("C:/Users/BUNT/Documents/JDS/R/Projekt candy/candy-data.csv")

summary(mydata)
str(mydata)

#for correlation anylizis I need numeric data so I remove competitorname (factor)

mydata2 <- mydata[c(2:13)]

mapply(anyNA, mydata2)

# Compute a correlation matrix
corr <- round(cor(mydata2), 1)
head(corr[, 1:12])

# Compute a matrix of correlation p-values
p.mat <- cor_pmat(mydata2)
head(p.mat[, 1:12])

# Visualize the correlation matrix
# --------------------------------
# method = "square" (default)
ggcorrplot(corr)

# method = "circle"
ggcorrplot(corr, method = "circle")

# Reordering the correlation matrix
# --------------------------------
# using hierarchical clustering
ggcorrplot(corr, hc.order = TRUE, outline.col = "white")

# Types of correlogram layout
# --------------------------------
# Get the lower triangle
ggcorrplot(corr, hc.order = TRUE, type = "lower",
           outline.col = "white")

# Get the upeper triangle
ggcorrplot(corr, hc.order = TRUE, type = "upper",
           outline.col = "white")

# Add correlation coefficients
# --------------------------------
# argument lab = TRUE
ggcorrplot(corr, hc.order = TRUE, type = "lower",
           lab = TRUE)
# Add correlation significance level
# --------------------------------
# Argument p.mat
# Barring the no significant coefficient
ggcorrplot(corr, hc.order = TRUE,
           type = "lower", p.mat = p.mat)

# Leave blank on no significant coefficient
ggcorrplot(corr, p.mat = p.mat, hc.order = TRUE,
           type = "lower", insig = "blank")

#not at all correlated - sugarpercent
#variables pricepercent and winpercent not binar

#creat gml model for all variables but sugarpercent, pricepercent and winpercent
str(mydata)

mydata3 <- mydata[c(1:10)]

str(mydata3)

#change class into factors
mydata3$chocolate <- factor(mydata3$chocolate)
mydata3$fruity <- factor(mydata3$fruity)
mydata3$caramel <- factor(mydata3$caramel)
mydata3$peanutyalmondy <- factor(mydata3$peanutyalmondy)
mydata3$nougat <- factor(mydata3$nougat)
mydata3$crispedricewafer <- factor(mydata$crispedricewafer)
mydata3$hard <- factor(mydata$hard)
mydata3$bar <- factor(mydata3$bar)
mydata3$pluribus <- factor(mydata3$pluribus)

str(mydata3)

#chocalate probability
model1 <- glm(chocolate~competitorname+fruity+caramel+peanutyalmondy+nougat+crispedricewafer+hard+bar+pluribus, family=binomial(), data=mydata3)
summary(model1)

# choco probability
choco_prob <- predict(model1, mydata3, type="response")

choco_results <- cbind(mydata4, choco_prob)

#as I get:Warning message:
#In predict.lm(object, newdata, se.fit, scale = 1, type = ifelse(type ==  :
#predykcja z dopasowania z niedoborem rang może być myląca
#it is adviced to simplyfy the model

##################
#I wouldlike to create gml model for variables with corr > +-0,5 which are fruity, bar and pricepercent
#so I need to change procepercent into bins and factors

str(mydata)

mydata3 <- mydata[c(2,3,9,12)]


####################################
#I create gml model for variables with corr > +-0,5 which are fruity, bar
str(mydata)

mydata4 <- mydata[c(2,3,9,12)]

str(mydata4)

mydata4$pricepercent_bin <- 5
mydata4$pricepercent_bin <- ifelse(mydata4$pricepercent < 0.50, 0, mydata4$pricepercent_bin) # Below 0,5
mydata4$pricepercent_bin <- ifelse(mydata4$pricepercent >= 0.50, 1, mydata4$pricepercent_bin) #Above 0,5

#i remove pricepercent

mydata5 <- mydata4[c(1,2,3,5)]

#change class into factors
mydata5$chocolate <- factor(mydata5$chocolate)
mydata5$fruity <- factor(mydata5$fruity)
mydata5$bar <- factor(mydata5$bar)
mydata5$pricepercent_bin <- factor(mydata5$pricepercent_bin)

str(mydata5)

#glm model
model2 <- glm(chocolate~fruity+bar+pricepercent_bin, family=binomial(), data=mydata5)
summary(model2)

# choco probability
choco_prob <- predict(model2, mydata5, type="response")

choco_results <- cbind(mydata5, choco_prob)

# contingency matrix dla progu 50% 
table(mydata5$chocolate, choco_prob > 0.5)

ROCRpred <- prediction(choco_prob, mydata5$chocolate)
ROCRperf <- performance(ROCRpred, 'tpr','fpr')
par(mfrow = c(1, 1))
plot(ROCRperf, colorize = TRUE)

auc <- performance(ROCRpred, measure = "auc")
auc <- auc@y.values[[1]]
auc

#auc 0,9411599

###########

# just 2 factors - fruity and bar
str(mydata)

mydata6 <- mydata[c(2,3,9)]
str(mydata6)

#change class into factors
mydata6$chocolate <- factor(mydata6$chocolate)
mydata6$fruity <- factor(mydata6$fruity)
mydata6$bar <- factor(mydata6$bar)

#glm model
model3 <- glm(chocolate~fruity+bar, family=binomial(), data=mydata6)
summary(model3)

# choco probability
choco_prob <- predict(model3, mydata6, type="response")

choco_results <- cbind(mydata6, choco_prob)

# contingency matrix dla progu 50% 
table(mydata6$chocolate, choco_prob > 0.5)

ROCRpred <- prediction(choco_prob, mydata6$chocolate)
ROCRperf <- performance(ROCRpred, 'tpr','fpr')
par(mfrow = c(1, 1))
plot(ROCRperf, colorize = TRUE)

auc <- performance(ROCRpred, measure = "auc")
auc <- auc@y.values[[1]]
auc
#auc 0,923705


