# 1) load packages devtools, openxlsx, RPostgreSQL, dplyr

library("devtools")
library("openxlsx")
library("RPostgreSQL")
library("dplyr")

# 2) read and build function active_packages, which will read all packages from prvious point. Print the text "packages ready" at the end of function

active_packages <- function(...){
  library("devtools")
  library("openxlsx")
  library("RPostgreSQL")
  library("dplyr")
  Print("packages ready")
}

#3) run function active_packages in concolse and check whether "packages ready" text appreared

#dziala

#4) load all data from szczegoly_rekompensat table into data frame called df_compensations

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "postgres", host = "localhost", port = 5432, user = "postgres", password = "postgres")
dbExistsTable(con, "szczegoly_rekompensat")
df_compensations <- dbGetQuery(con, "SELECT * from szczegoly_rekompensat")

#5) check if table tab_1 exists in a connection defined in previous point

dbExistsTable(con,"tab_1") #FALSE - nie istnieje

#6) print df_compensations data frame summary 

summary(df_compensations)

#VECTORS

#7) create vector sample_vector which contains numbers 1,21,41 (don't use seq function)

sample_vector <- c(1,21,41)

#8) create vector sample_vector_seq which contains numbers 1,21,41 (use seq function)

sample_vector_seq <- seq(from = 1, to = 41, by = 20)

#9) Combine two vectors (sample_vector, sample_vector_seq) into new one: v_combined

v_combined <- c(sample_vector, sample_vector_seq) 

#10) Sort data descending in vector v_combined

sort(v_combined , decreasing = TRUE)

#11) Create vector v_accounts created from df_compensations data frame, which will store data from 'konto' column

v_accounts <- (df_compensations$konto)

#12) Check v_accounts vector length

length(v_accounts)

#13) Because previously created vector containst duplicated values, we need a new vector (v_accounts_unique), with unique values. Print vector and check its length 

v_accounts_unique <- unique(v_accounts)
length(v_accounts_unique)

#MATRIX

#14) Create sample matrix called sample_matrix, 2 columns, 2 rows. Data: first row (998, 0), second row (1,1)

sample_matrix <- matrix( 
    c(998,0,1,1),  
    nrow=2,        
    ncol=2,        
    byrow = TRUE)  

#15) Assign row and column names to sample_matrix. Rows: ("no cancer", "cancer"), Columns: ("no cancer", "cancer")

dimnames(sample_matrix) = list(
c("no cancer", "cancer"),
c("no cancer", "cancer"))

#16) Create 4 variables: precision, recall, acuracy, fscore and calculate their result based on data from sample_matrix

precision<-sample_matrix[4]/sum(sample_matrix[,2]) 
recall<-sample_matrix[4]/sum(sample_matrix[2,]) 
accuracy<-sample_matrix[1]/sum(sample_matrix) 
fscore<-2*precision*recall/(precision+recall) 
#100%, 50%, 99,8%, 66,67%


#17) Create matrix gen_matrix with random data: 10 columns, 100 rows, random numbers from 1 to 50 inside 

gen_matrix <- matrix( 
  sample(1:50),  
  nrow=100,        
  ncol=10,        
  byrow = TRUE) 

#LIST

#18) Create list l_persons with 3 members from our course. Each person has: name, surname, test_results (vector), homework_results (vector)

name <- c("Magda", "Monika", "Wojtek") 
surname <- c("Kortas", "Serkowska", "Artichowicz") 
test_results <- c(91.2, 71.9, 75) 
homework_results <- c(100, 80, 100)
l_persons <- list(name, surname, test_results,homework_results)

#19) Print first element from l_persons list (don't use $ sign)

l_persons[[1]]

#20) Print first element from l_persons list (use $ sign)

l_persons$name

#21) Create list l_accounts_unique with unique values of 'konto' column from df_compensations data frame. Check l_accounts_unique type 

l_accounts_unique <- list(unique(df_compensations$konto))
class(l_accounts_unique)

#DATA FRAME

#22) Create data frame df_comp_small with 4 columns from df_compensations data frame (id_agenta, data_otrzymania, kwota, konto)

df_comp_small <- data.frame(df_compensations[c('id_agenta','data_otrzymania','kwota','konto')])

#23) Create new data frame with aggregated data from df_comp_small (how many rows we have per each account, and what's the total value of recompensations in each account)

df_new <- df_comp_small %>% 
group_by(konto) %>% 
summarise (liczba = n(), total_compensation_value = sum(kwota)) 
df_new

#24) Which agent recorded most recompensations (amount)? Is this the same who recorded most action? 

df_new <- df_comp_small %>% 
group_by(id_agenta) %>% 
summarise (total_compensation_value = sum(kwota)) %>%  
arrange(desc(total_compensation_value))
df_new

#agent 168 mial najwieksza sume rekompensat

df_new <- df_comp_small %>% 
group_by(id_agenta) %>% 
summarise (liczba = n()) %>%  
arrange(desc(liczba))
df_new

#agent 168 mial rowniez najwiecej zdarzen

#LOOPS and conditional instructions

#25) Create loop (for) which will print random 100 values

  for(x in 1:100) {
   x<-sample(1:100,1)
print(x)
  }
 
#26) Create loop (while) which will print random values (between 1 and 50) until 20 wont' appear

x <- 1
while(x !=  20) {
x <- sample(1:50, 1);
print(x); 
}

#27) Add extra column into df_comp_small data frame called amount_category. 

df_comp_small$amount_category <- 0

#28) Store data from df_comp_small into new table in DB

dbWriteTable(con, "df_comp_small", df_comp_small)

#29) Fill values in amount_category. All amounts below average: 'small', All amounts above avg: 'high'

avg_kwota <- mean(df_comp_small$kwota)
df_comp_small$amount_category <- ifelse (df_comp_small$kwota<avg_kwota, 'small' ,'high')
dbWriteTable(con, "df_comp_small", df_comp_small)

