library(tidyverse)
library(readxl)

nel <- read_excel("C:/Users/ADickson/Documents/ACC_baseData_v2.xlsx", 
                  sheet = "lsoa_data")

el <- read_excel("C:/Users/ADickson/Documents/ACC_baseData_v2.xlsx", 
                  sheet = "ccg_data")

nel$lnCWRU_NEL <- log(nel$CWRU_NEL, base = exp(1))

g <- ggplot(data = nel, aes(lnCWRU_NEL))
g + geom_histogram()

mod1 <- lm(CWRU_NEL ~ Population + nonWhiteProp 
                                + Pop70deprPRP + Pop70nonDeprPRP
                                + PopUnder70deprPRP, data = nel)
summary(mod1)
pred1 <- predict(mod1, interval = "prediction")
#View(pred1)
mydata1 <- cbind(nel, pred1)
mydata1$residuals <- mydata1$CWRU - mydata1$fit
#View(mydata1)
#write.csv(mydata1, "ACC_NEL_prediction_cwru.csv")
h <- ggplot(data = mydata1, aes(residual))
h + geom_histogram()



mod2 <- lm(CWRU_EL_y ~ CCwtd_EL_spells, data = el)
summary(mod2)
pred2 <- predict(mod2, interval = "prediction")
View(pred2)
mydata2 <- cbind(el, pred2)
mydata2$residual <- mydata2$CWRU - mydata2$fit
View(mydata2)
write.csv(mydata2, "ACC_EL_prediction_cwru.csv")
j <- ggplot(data = mydata2, aes(residual))
j + geom_histogram()