library(FactoMineR)
library(factoextra)
library(gplots)

data("mtcars")
head(mtcars)
str(mtcars)
?mtcars

summary(mtcars)


#[, 1]	 mpg	 Miles/(US) gallon
#[, 2]	 cyl	 Number of cylinders
#[, 3]	 disp	 Displacement (cu.in.)
#[, 4]	 hp	 Gross horsepower
#[, 5]	 drat	 Rear axle ratio
#[, 6]	 wt	 Weight (1000 lbs)
#[, 7]	 qsec	 1/4 mile time
#[, 8]	 vs	 V/S
#[, 9]	 am	 Transmission (0 = automatic, 1 = manual)
#[,10]	 gear	 Number of forward gears
#[,11]	 carb	 Number of carburetors


#As correspondence Analysis (CA) is a multivariate graphical technique designed to explore relationships
#among categorical variables the following variables were choosen: cyl, gear, carb.
#data are numerical and I need factors so I convert them:
cyl <- as.factor(mtcars$cyl)
cyl

gear <- as.factor(mtcars$gear)
gear

carb <- as.factor(mtcars$carb)
carb

# 1 pair - cyl and gear. I create a contingency table:
table1 <- table(cyl, gear)
table1

#ballonplot
balloonplot(t(table1), main ="plot", xlab="", ylab="",
            label+true, show.margins=FALSE)

#plot shows that majority of cars with3 gears has 8 cylinders, and majority of cars with 4 gears has 4 cylinders, for cars with 5 gears the numer of cyliders vary

#compute Correspondace Analysis
ca_result1 <- CA(table1, graph=FALSE)
print(ca_result1)

#as chi square=18 and p-value =0,00121 the association is highly significant

#determine number of dimension - method 1
eig.val <- get_eigenvalue(ca_result1)
eig.val
#cumulative.variance.percent is satisfactory

#determine number of dimension - method 2
fviz_screeplot(ca_result1, addlabels=TRUE, ylim=c(0,100))

#contribution of rows
par(mfrow=c(2,1))
fviz_contrib(ca_result1, choice="row", axes=1, top=10)
fviz_contrib(ca_result1, choice="row", axes=2, top=10)
#axes to dimension 1-2

#plot final biplot
fviz_ca_biplot(ca_result1, col.row="contrib")

###########
# 2 pair - cyl and carb. I create a contingency table:
table2 <- table(cyl, carb)
table2

#ballonplot
par(mar=c(1,1,1,1))
balloonplot(t(table2), main ="plot", xlab="", ylab="",
            label+true, show.margins=FALSE)

#plot shows that majority of cars with 4 cylinders has 1 or 2 carburators, for other it varies

#compute Correspondace Analysis
ca_result2 <- CA(table2, graph=FALSE)
print(ca_result2)
#as chi square=24 and p-value =0,0066 the association is highly significant

#determine number of dimension - method 1
eig.val <- get_eigenvalue(ca_result2)
eig.val
#cumulative.variance.percent is satisfactory

#determine number of dimension - method 2
fviz_screeplot(ca_result2, addlabels=TRUE, ylim=c(0,100))

#contribution of rows
par(mfrow=c(2,1))
fviz_contrib(ca_result2, choice="row", axes=1, top=10)
fviz_contrib(ca_result2, choice="row", axes=2, top=10)
#axes to dimension 1-2

#plot final biplot
fviz_ca_biplot(ca_result2, col.row="contrib")

###########
# 3 pair - gear and carb. I create a contingency table:
table3 <- table(gear, carb)
table3

#ballonplot
par(mar=c(1,1,1,1))
balloonplot(t(table3), main ="plot", xlab="", ylab="",
            label+true, show.margins=FALSE)

#compute Correspondace Analysis
ca_result3 <- CA(table3, graph=FALSE)
print(ca_result3)
#as chi square=16 and p-value =0,0857 the association is not significant

###########
# 4 pair - mpg and gear. as mpg in dataframe is a continuous variable I creat categories 3:
mtcars$mpg_bin <- 0
mtcars$mpg_bin  <- ifelse(mtcars$mpg < 20, 1, mtcars$mpg_bin) # Below mpg 20
mtcars$mpg_bin  <- ifelse(mtcars$mpg >= 20 & mtcars$mpg < 30, 2,mtcars$mpg_bin) # Mpg 20-30.
mtcars$mpg_bin  <- ifelse(mtcars$mpg >= 30, 3, mtcars$mpg_bin) # Mpg 30+.

#and change mpg_bin into factor
mpg_bin <- as.factor(mtcars$mpg_bin)
mpg_bin

#I create a contingency table:
table4 <- table(mpg_bin, gear)
table4

#ballonplot
par(mar=c(1,1,1,1))
balloonplot(t(table4), main ="plot", xlab="", ylab="",
            label+true, show.margins=FALSE)

#compute Correspondace Analysis
ca_result4 <- CA(table4, graph=FALSE)
print(ca_result4)
#as chi square=13,98 and p-value =0,0073 the association is highly significant

#determine number of dimension - method 1
eig.val <- get_eigenvalue(ca_result4)
eig.val
#cumulative.variance.percent is satisfactory

#determine number of dimension - method 2
fviz_screeplot(ca_result4, addlabels=TRUE, ylim=c(0,100))

#contribution of rows
par(mfrow=c(2,1))
fviz_contrib(ca_result4, choice="row", axes=1, top=10)
fviz_contrib(ca_result4, choice="row", axes=2, top=10)
#axes to dimension 1-2

#plot final biplot
fviz_ca_biplot(ca_result4, col.row="contrib")


