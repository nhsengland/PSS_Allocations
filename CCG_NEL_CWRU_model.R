library(dplyr)
library(stringr)
library(broom)
library(tidyverse)
library(readxl)
ccg <- read_excel("~/CCG_NEL_CWRU.xlsx", sheet = "CCG_NEL_CWRU")
ccg$ln_nel_cwru <- log(ccg$NEL_CWRU, base = exp(1))
ccg$ln_pop <- log(ccg$Population_all, base = exp(1))
ccg$Pop60depr_prop <- ccg$Pop60plus_depr/ccg$Population_all
View(ccg)

f <- ggplot(data=ccg, mapping = aes(ln_nel_cwru))
f + geom_histogram()# binwidth = 0.5

g <- ggplot(ccg, mapping = aes(ln_nel_cwru, ln_pop))
g + geom_jitter() + geom_smooth()

mod1 <- lm(NEL_CWRU ~ Population_all + Pop60depr_prop
             #PopUnder60 + Pop60plus
             #PopUnder60_depr +
             #Pop60plus_depr
             #
             #Pop60plus_depr
           , data = ccg)
summary(mod1)
tidy_mod1 <- tidy(mod1)
tidy_mod1
write.csv(tidy_mod1, "tidy_mod1.csv")
pred <- predict(mod1, interval = "prediction")
mydata <- cbind(ccg, pred)
#View(mydata)

g <- ggplot(data = mydata, mapping = aes(fit, NEL_CWRU))
g + geom_point() + stat_smooth(method = lm)  +
geom_line(aes(y = lwr), color = "red", linetype = "dashed") +
geom_line(aes(y = upr), color = "red", linetype = "dashed")