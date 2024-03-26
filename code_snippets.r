# 
# a <- ggplot(data = df, mapping = aes(Total_EL_Activity, cwru_el))
# a + geom_jitter() + geom_smooth()
# mod1 <- lm(cwru_el ~ Total_EL_Activity*el_age + apache, data = df)
# summary(mod1)
# 
# b <- ggplot(data = df, mapping = aes(CC_Weighted_EL_Activity, cwru_el))
# b + geom_jitter() + geom_smooth()
# mod2 <- lm(cwru_el ~ CC_Weighted_EL_Activity*el_age + apache, data = df)
# summary(mod2)
#install.packages('cellranger')
#a <- read_excel("20210713 Cancer Undiagnosed Need Model v3.xlsx", sheet = "timeSeries",range = "A4:H195")

library(tidyverse)
library(readxl)
df <- read_excel("~/ACC_CWRU_EL_NEL_with_IMD_domains_RegressionAnalysisEthn.xlsx", sheet = "data2")
dg <- read_excel("~/LSOA_Hosp_Vars.xlsx", sheet = "LSOA_Hosp_Vars")

#View(Adult_Critical_Care_Cost_Weights_Model_v7)
#df <- ACC_CWRU_EL_NEL_with_IMD_domains_RegressionAnalysisEthn
View(df)

# NOT SURE THIS IS RIGHT. SHOULD THE INDICES APPLY TO THE WHOLE POPULATION???
df$CWRU <- df$CWRUphp*df$Population
df$Pop70plus <- df$PopnOver70*df$Population
df$Pop70_Depr <- df$Pop70plus*df$Income_Deprivation_Affecting_Older_People_Index
df$Pop70_nonDepr <- df$Pop70plus-df$Pop70_Depr
df$PopUnder70 <- df$Population-df$Pop70plus
df$PopUnder70_Depr <- df$PopUnder70*df$Employment_Deprivation_Domain
df$PopUnder70_nonDepr <- df$PopUnder70-df$PopUnder70_Depr

# df$Pop70deprRatio <- df$Pop70_Depr/df$Pop70_nonDepr
# df$PopUnder70deprRatio <- df$PopUnder70_Depr/df$PopUnder70_nonDepr
# df$Pop70nonDeprRatio <- df$Pop70_nonDepr/df$Pop70_Depr
# df$PopUnder70nonDeprRatio <- df$PopUnder70_nonDepr/df$PopUnder70_Depr

df$Pop70deprRate <- df$Pop70_Depr/df$Population
#df$Pop70deprRate_sq <- df$Pop70deprRate*df$Pop70deprRate
df$PopUnder70deprRate <- df$PopUnder70_Depr/df$Population
df$Pop70nonDeprRate <- df$Pop70_nonDepr/df$Population
df$PopUnder70nonDeprRate <- df$PopUnder70_nonDepr/df$Population

#df$PopnSqrd <- df$Population*df$Population
#df$ln_cwru <- log(df$CWRU, base = exp(1))
#df$cwru_sqrt <- (df$CWRU)^(1/2)
#df$ln_popn <- log(df$Population, base = exp(1))
#df$Rurality_binary <- ifelse(grepl("Rural",df$Rurality),'Rural','Urban')

#dfn <- df[!(df$NPOD!='EL'),] # Elective activity only

dfn <- df[!(df$NPOD!='NEL'),] # Non-elective activity only
df1 <- dfn[!(dfn$CWRUpkhp>50),] # Remove outliers
df1 <- do.call(data.frame,      # Replace Inf in data by NA
lapply(df1,
function(x) replace(x, is.infinite(x), NA)))
df1 <- na.omit(df1)                           # Remove NA rows

dh = merge(x = df1, y = dg, by = "LSOA", all.x = TRUE)
df1 = dh
# df1 <- df1[is.finite(rowSums(df1)),]
# df1<-df1[complete.cases(df1),]
#df2 <- dfn[!(dfn$CWRUpkhp>150),]
#df2<-df2[complete.cases(df2),]
df4 <- df[!(df$CWRUpkhp>50),] # Remove outliers

df1$Rurality_UrbMajCon <- ifelse(grepl("Urban major conurbation",df1$Rurality),'UrbMajCon','Other')
#View(df1)

#df3 <- df[!(df$CWRUpkhp>15),]
#View(dfn)

#df$fy_str <- as.character(df$fy_short)

g <- ggplot(df1, mapping = aes(Popn_nonWhite, color = IMD_decile))
g + geom_density()

g <- ggplot(df1, mapping = aes(x = Popn_nonWhite))
g + geom_histogram()

g <- ggplot(data = df1, mapping = aes(y = Income_Deprivation_Affecting_Older_People_Index, x = IMD_decile))
g + geom_boxplot()

g <- ggplot(data = df1, mapping = aes(x = CWRU, y = Popn_nonWhite, color = Income_Deprivation_Affecting_Older_People_Index))
g + geom_jitter()

g <- ggplot(data = df1, mapping = aes(x = Popn_nonWhite, y = PopUnder70, color = Income_Deprivation_Affecting_Older_People_Index))
g + geom_jitter(size = 0.1)

#df1 <- df[!(df$CWRUpkhp>50),] #View(df1)
g <- ggplot(data = df1, mapping = aes(x = Popn_nonWhite, y = CWRU))
g + geom_boxplot()
#summary(lm(ln_cwru ~ 0+IMD_decile, df1))

#df3 <- df[!(df$CWRU>50),]
g <- ggplot(data = df4, mapping = aes(x = CWRU, y = Rurality, color = NPOD))
g + geom_boxplot()


#df$Hi_int_prop <- df$High_intensity_spells/df$Total_EL_Spells
#df$Lo_int_prop <- df$Low_intensity_spells/df$Total_EL_Spells
df$ln_spells <- log(df$Total_EL_Spells, base = exp(1))
df$ln_wSpells <- log(df$CC_Weighted_EL_Spells, base = exp(1))


library(dplyr)
library(stringr)

#install.packages("broom")
library(broom)
#install.packages("normtest")
library(normtest)

#+ FinYear
mod1 <- glm(CWRU ~ #ln_cwru
            #0 +
            #Rurality_binary +
            Population +
            Pop70deprRate +
            Pop70nonDeprRate +
            PopUnder70deprRate +
            PopUnder70nonDeprRate +
            Popn_nonWhite 
             #White_perc +
             #Asian_perc 
             #Black_perc +
             #Mixed_perc +
             #Other_eth_perc
           , data = df1)
summary(mod1)
#par(mfrow = c(2, 2))
#plot(mod1)

#tidy_mod1 <- tidy(mod1)
#tidy_mod1
#write.csv(tidy_mod1, "tidy_mod1.csv")

pred <- predict(mod1, interval = "prediction")
mydata <- cbind(df1, pred)
mydata$residualCNST <- mydata$CWRU - mydata$fit
#mydata = subset(mydata, select = -c(fit) )
View(mydata)
write.csv(mydata, "ACC_NEL_prediction__cwru.csv")




mod2 <- lm(residualCNST ~ DomProv_Occupancy + DomProv_AggBeds, data = mydata) # + DomProv_AggBeds
summary(mod2)

pred2 <- predict(mod2, interval = "prediction")
mydata2 <- merge(mydata, pred2, by=0, all = TRUE)
#View(mydata2)
mydata2$residual2 <- mydata2$residualCNST - mydata2$fit

j <- ggplot

g <- ggplot(data = mydata2, mapping = aes(x=residual2))
g + geom_histogram()
summary(mydata2$residual2)

#??normtest
jb.norm.test(mydata$residualCNST, nrepl = 2000)
ajb.norm.test(mydata$residualCNST, nrepl=2000)
kurtosis.norm.test(mydata$residualCNST, nrepl=2000)
skewness.norm.test(mydata$residualCNST, nrepl=2000)

g <- ggplot(data = mydata, mapping = aes(CWRU, fit))
g + geom_point() + stat_smooth(method = lm) 
  #geom_line(aes(y = lwr), color = "red", linetype = "dashed") +
  #geom_line(aes(y = upr), color = "red", linetype = "dashed") 


p <- ggplot(mydata, aes(fit, CWRU)) +
  geom_point() +
  stat_smooth(method = lm)
p
# 3. Add prediction intervals
p + geom_line(aes(y = fit), color = "blue") +
  geom_line(aes(y = lwr), color = "red", linetype = "dashed")+
  geom_line(aes(y = upr), color = "red", linetype = "dashed")



View(mydata)
write.csv(mydata, "acc_lsoa_predictions.csv")

mod2 <- lm(CWRU ~ 
           Population 
           #PopnOver70 +
           #NPOD +
           #IMD_Score +
           #Rurality +
           #Barriers_to_Housing_and_Services_Domain +
           #Crime_Domain +
           #Education_Skills_and_Training_Domain +
           #Employment_Deprivation_Domain +
           #Health_Deprivation_and_Disability_Domain +
           #Income_Deprivation_Domain +
           #Income_Deprivation_Affecting_Children_Index +
           #Income_Deprivation_Affecting_Older_People_Index +
           #Living_Environment_Deprivation_Domain
           , data=df1)
summary(mod2)
tidy_mod2 <- tidy(mod2)
tidy_mod2
write.csv(tidy_mod2, "tidy_mod2.csv")


mod <- lm(Local_weight_unitCost ~ 
           `1_organ`#*`0_org_Trust`
          + `2_organs_noARS`
          + `2_organs_ARS_Perc`
          + `3_organs`
          + `4_organs`
          + `5_organs`#*`6_org_Trust`
          + `6_organs`
          #+ Hi_Spec
          #+ Lo_Spec
          #+ NEL_prop
          #Organs
          #+ Specialties
          #+ Travel_Distance
          , data = d)

summary(mod)



#Population + 
#NPOD +
#IMD_Score +
#Pop70plus
#Income_Deprivation_Affecting_Older_People_Index
#Rural_area +
#Urban_area +
#Rurality_binary +
#Rurality +
#Barriers_to_Housing_and_Services_Domain +
#Crime_Domain +
#######Education_Skills_and_Training_Domain +
#Employment_Deprivation_Domain 
#Health_Deprivation_and_Disability_Domain +
#Income_Deprivation_Domain +
#Income_Deprivation_Affecting_Children_Index +
#Income_Deprivation_Affecting_Older_People_Index +
#Living_Environment_Deprivation_Domain


# Replace Inf in data by NA
#df1 <- do.call(data.frame,                    
#                  lapply(df1,
#                         function(x) replace(x, is.infinite(x), NA)))
#df1 <- na.omit(df1)
#View(df1)


#mydata <- read.csv("https://stats.idre.ucla.edu/stat/data/binary.csv")
## view the first few rows of the data
#head(mydata)
#View(mydata)
#install.packages("aod")
#library(aod)
#summary(mydata)
#mydata$rank <- factor(mydata$rank)
#mylogit <- glm(admit ~ gre + gpa + rank, data = mydata, family = "binomial")
#see: https://stats.idre.ucla.edu/r/dae/logit-regression/


df$ln_tf <- log(df$Transfers, base = exp(1))
df$Transfer_rate <- df$Transfers_CC/df$Spells_total

mod <- lm(LocalPrice_Payment ~ Spells_total + Transfer_rate, data = df)
summary(mod)

mod <- lm(Ref_Cost ~ Spells_total + Transfer_rate, data = df)
summary(mod)

tidy_mod <- tidy(mod)
tidy_mod
write.csv(tidy_mod, "tidy_mod.csv")


g <- ggplot(data = df, mapping = aes(x = Unbundled_HRG, y = Transfers))
g + geom_boxplot()

h <- ggplot(data = df, mapping = aes(x = Transfers_CC))
h + geom_histogram()

##################################################################
#ELECTIVE MODEL

library(readxl)
de <- read_excel("ACC Project R/ACC_Population/cwru_el_ccg_1516_2122.xlsx", 
                                                       sheet = "data")
de <- do.call(data.frame,      # Replace Inf in data by NA
               lapply(de,
                      function(x) replace(x, is.infinite(x), NA)))
de <- na.omit(de)                           # Remove NA rows
de[!is.na(as.numeric(as.character(de$ACC_CWRU_El))),]
de$finYear <- factor(de$fy_short)
View(de)

me <- lm(ln_cwru_el ~ #ACC_CWRU_El
           0 +
           ln_elSpellsCCW 
           #CC_Weighted_EL_Spells
           #finYear
           , data = de) 
summary(me)

g <- ggplot(de, mapping = aes(ln_cwru_el))
  g + geom_density()

g <- ggplot(de, mapping = aes(x = ln_cwru_el))
  g + geom_histogram()

g <- ggplot(data = de, mapping = aes(y = ln_cwru_el, x = finYear, group = finYear))
  g + geom_boxplot()

g <- ggplot(data = de, mapping = aes(x = ln_elSpellsCCW, y = ln_cwru_el, color = finYear))
  g + geom_jitter() #+ geom_smooth()
  
  
  
  summary(me)
  par(mfrow = c(2, 2))
  plot(me)
  
  library(dplyr)
  library(stringr)
  
  #install.packages("broom")
  library(broom)
  #install.packages("normtest")
  library(normtest)
  
  tidy_mod2 <- tidy(me)
  tidy_mod2
  
  write.csv(tidy_mod2, "tidy_mod2.csv")
  pred <- predict(me, interval = "prediction")
  mydata_el <- cbind(de, pred)
  mydata_el$residual <- mydata_el$ln_cwru_el - mydata_el$fit
  View(mydata_el)
  
  #write.csv(mydata_el, "prediction_ln_cwru_el.csv")
  
  g <- ggplot(data = mydata_el, mapping = aes(x=residual))
  g + geom_histogram() 
  summary(mydata_el$residual)
  
  #??normtest
  jb.norm.test(mydata_el$residual, nrepl = 2000)
  ajb.norm.test(mydata_el$residual, nrepl=2000)
  kurtosis.norm.test(mydata_el$residual, nrepl=2000)
  skewness.norm.test(mydata_el$residual, nrepl=2000)
  
  
  p <- ggplot(mydata_el, aes(fit, ln_cwru_el)) +
    geom_point() #+ stat_smooth(method = lm)
  #p
  # 3. Add prediction intervals
  p + geom_line(aes(y = fit), color = "blue") +
    geom_line(aes(y = lwr), color = "red", linetype = "dashed")+
    geom_line(aes(y = upr), color = "red", linetype = "dashed")
  
  
