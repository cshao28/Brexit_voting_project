library(RColorBrewer)
library(MASS)
library(ggplot2)
VotingData<-read.csv("ReferendumResults.csv")

#Divert output to file 
sink("Leave_results.txt")

##############################################################################
##            Clean Data                                                   ###
##############################################################################
### Removing missing values
### Making variable 'Leave' as proportion
VotingData <- VotingData[VotingData$Leave != -1, ]
VotingData$Leave<-VotingData[,5]/VotingData[,4]


#######Summary of the 'Leave'
cat("\nSUMMARY OF LEAVE DATA:\n")
cat("====================\n")
print(summary(VotingData$Leave))

# ##############################################################################
# ##############################################################################
# #                   EDA                                                  ######
# ##############################################################################
# ##############################################################################

cat("====================\n")
cat("====================\n")
cat("\nEDA part:\n")
cat("====================\n")
cat("====================\n")



#######################################
#     RegionName                    ###
#######################################

# Means of covariates for each region
par(mfrow=c(1,1))
RegionMeans <- aggregate(VotingData[,-(1:8)], by=list(VotingData$RegionName), FUN=mean)
rownames(RegionMeans) <- RegionMeans[,1]
RegionMeans <- scale(RegionMeans[,-1]) # Standardise to mean 0 & SD 1
Distances <- dist(RegionMeans) # Pairwise distances
ClusTree <- hclust(Distances, method="complete") # Do the clustering
par(mar=c(3,3,3,1), mgp=c(2,0.75,0)) # Set plot margins
plot(ClusTree, xlab="Region name", ylab="Separation", cex.main=0.8)
abline(h=8, col="red", lty=2) 

#divide region names into four groups
RegionGroups <- cutree(ClusTree, k=4)


cat("\nRegionGroups assigned to each region \n")
cat("====================\n")
print(RegionGroups, width=90)


#adding new column of RegionGoup to the dataset
VotingData <- merge(data.frame(RegionName=names(RegionGroups), RegionGroup=RegionGroups),
                    VotingData)

#######################################
#       Postals                     ###
#######################################

#boxplot of Postals N or NP with Leave
ggplot(VotingData, aes(Postals, Leave)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 21, size = 3, fill = "orange") +
  labs(x = "Postals", y = "Leave") +


#######################################
#       AdultMeanAge                ###
#######################################


cat("====================\n")
cat("\nCorrelations between all age groups covariates: \n")
cat("====================\n")

print(round(cor(VotingData[,18:27]),2))#correlation between all age groups


#######################################
#           Ethnicity               ###
#######################################

cat("====================\n")
cat("\nCorrelations between all ethnicity related covariates: \n")
cat("====================\n")

print(round(cor(VotingData[,28:32]),2)) #Correlations between all ethnicity related covariates

#Perform PCA on the Ethnicity covariates
Ethnicity.PCs<-prcomp(VotingData[,28:32],scale.=TRUE)
cat("====================\n")
cat("\nSummary table of Ethnicity PCs:\n")
cat("====================\n")

print(summary(Ethnicity.PCs))

#Create two variables containing two PC values
EthnicityPC1<-Ethnicity.PCs$x[,1]
EthnicityPC2<-Ethnicity.PCs$x[,2]

#######################################
#         Social Grade              ###
#######################################



cat("====================\n")
cat("\nCorrelations between social grade related variables: \n")
cat("====================\n")

print(round(cor(VotingData[,48:50]),2)) #Correlations between social grade related variables

Social.PCs<-prcomp(VotingData[,48:50],scale.  =TRUE) #assign all the PC values to Social.PCs
cat("====================\n")
cat("\nSummary table of Social Grade PCs:\n")
cat("====================\n")

print(summary(Social.PCs))
SocialGrade<-Social.PCs$x[,1] #Creating a new variable containing social grade PC value


#######################################
#   House Renting & Owning          ###
#######################################

#scatter plots between Owing/Renting house against Leave
par(mfrow=c(2,2))
plot(VotingData$Leave~VotingData$Owned, ylab = "Leave",
     xlab = "% of households owning their accomodation", 
     main = "Leave & owned", pch = 20, col="darkblue")

plot(VotingData$Leave~VotingData$OwnedOutright, ylab = "Leave",
     xlab = "% of households owning their accomodation outright", 
     main = "Leave & OwnedOutright", pch = 20, col="blue")

plot(VotingData$Leave~VotingData$SocialRent, ylab = "Leave",
     xlab = "% of households renting from social agent", 
     main = "Leave & SocialRent", pch = 20, col="red")

plot(VotingData$Leave~VotingData$PrivateRent, ylab = "Leave",
     xlab = "% of households renting from private landlords", 
     main = "Leave & PrivateRent", pch = 20, col="green")

cat("====================\n")
cat("\nCorrelations between 'Owned' and 'OwnedOutright': \n")
cat("====================\n")

print(round(cor(VotingData[,33:34]),2)) #Correlations between 'Owned' and 'OwnedOutright'

cat("====================\n")
cat("\nCorrelations between 'Socialrent' and 'PrivateRent': \n")
cat("====================\n")

print(round(cor(VotingData[,35:36]),2)) #Correlations between 'Socialrent' and 'PrivateRent'
Owning.PCs<-prcomp(VotingData[,33:34],scale.  =TRUE)   #assign PC values of Owing variables     
Owning<-Owning.PCs$x[,1] #creating new variable containing PC values for 'Owned' and 'OwnedOutright'



####################################
##        Education             ####
####################################

#scatter plots of levels of education against leave
png("Figure1 Education.png")
par(mfrow=c(2,2))

plot(VotingData$Leave~VotingData$NoQuals, ylab = "% of Leave",
     xlab = "% of residents with no academic qualification", 
     main = "Leave & No Qual", pch = 20, col="darkblue")

plot(VotingData$Leave~VotingData$L1Quals, ylab = "% of Leave",
     xlab = "% of residents with Level1 qualifications", 
     main = "Leave & Level1 Qual", pch = 20, col="blue")

plot(VotingData$Leave~VotingData$L4Quals_plus, ylab = "% of Leave",
     xlab = "% of residents with degree level or above", 
     main = "Leave & Degree level+", pch = 20, col="red")

plot(VotingData$Leave~VotingData$Students, ylab = "% of Leave",
     xlab = "% of students", 
     main = "Leave & Students", pch = 20, col="green")
dev.off()
cat("====================\n")
cat("\nCorrelations between all education related covariates: \n")
cat("====================\n")

print(round(cor(VotingData[,37:40]),2)) #Correlations between all education related covariates


#######################################
#           Occupation              ###
#######################################

#scatter plots of occupation against leave
png("Figure3 Occupation.png")
par(mfrow=c(2,2))
plot(VotingData$Leave~VotingData$Unemp, ylab = "Leave",
     xlab = "% of unemployed residents", 
     main = "Leave & Unemployed", pch = 20, col="darkblue")

plot(VotingData$Leave~VotingData$UnempRate_EA, ylab = "Leave",
     xlab = "% of unemployed economically active residents ", 
     main = "Leave & EA Unemployed", pch = 20, col="blue")

plot(VotingData$Leave~VotingData$HigherOccup, ylab = "Leave",
     xlab = "% of Higher-level occupations residents", 
     main = "Leave & Higher Occupation", pch = 20, col="red")

plot(VotingData$Leave~VotingData$RoutineOccupOrLTU, ylab = "Leave",
     xlab = "% of Routine occupation residents", 
     main = "Leave & Routine Occupation", pch = 20, col="green")
dev.off()
cat("====================\n")
cat("\nCorrelations between all Occupation related covariates: \n")
cat("====================\n")

print(round(cor(VotingData[,41:44]),2)) #Correlations between all Occupation related covariates


#######################################
#         Deprivation               ###
#######################################

#scatter plots of deprivation/multideprivation against leave
png("Figure2 Deprivation.png")
par(mfrow=c(1,2))
plot(VotingData$Leave~VotingData$Deprived, ylab = "% of Leave",
     xlab = "% of Deprived households", 
     main = "Leave & Deprived", pch = 20, col="darkblue")

plot(VotingData$Leave~VotingData$MultiDepriv, ylab = "% of Leave",
     xlab = "% of Multideprived households", 
     main = "Leave &MultiDepriv", pch = 20, col="blue")
dev.off()
cat("====================\n")
cat("\nCorrelations between 'Deprived' and 'MultiDepriv': \n")
cat("====================\n")

print(cor(VotingData$Deprived,VotingData$MultiDepriv)  ) #Correlations between 'Deprived' and 'MultiDepriv'




# ##############################################################################
# ##############################################################################
# #                     Model Building                                  ########
# ##############################################################################
# ##############################################################################
cat("====================\n")
cat("====================\n")

cat("\nModel building part:\n")
cat("====================\n")
cat("====================\n")

#######################################
#######################################
#         Model1                    ###
#######################################
#######################################

#using glm() and binomial distribution
model1<- glm(Leave~AdultMeanAge
             +RegionGroup     
             +Postals
             +EthnicityPC1
             +EthnicityPC2
             +NoQuals +L1Quals +L4Quals_plus
             +Owning
             +SocialRent +PrivateRent
             +HigherOccup +RoutineOccupOrLTU
             +Density
             +Deprived
             +MultiDepriv
             +SocialGrade,
             weight=NVotes, family=("binomial"),data=VotingData)

cat("\nModel1 summary:\n")
cat("====================\n")
print(summary(model1)) #Model1 summary table
par(mfrow=c(2,2))
plot(model1) #Model1 Plots
cat("====================\n")
cat("\nModel1 variance of Pearson residual:\n")
cat("====================\n")
#Model1 variance of Pearson residual
print(sum( resid(model1,type="pearson")^2 ) / model1$df.residual)

#######################################
#######################################
#         Model2                    ###
#######################################
#######################################

#Model 2 change to the quasibinomial distribution
model2<-update(model1,.~., family=("quasibinomial"))
cat("====================\n")
cat("\nModel2 summary:\n")
cat("====================\n")

print(summary(model2)) #Model2 summary table

#removing Deprived due to high p-value
model2_remove_dep<-update(model2,.~.-Deprived)
cat("====================\n")
cat("\nsummary of Model2 with Deprived removed:\n")
cat("====================\n")
print(summary(model2_remove_dep))

#######################################
#######################################
#         Model3                    ###
#######################################
#######################################

#Model3 removing PrivateRent based on model2 with Deprived removed
model3<-update(model2,.~. -PrivateRent)
cat("====================\n")
cat("\nModel3 summary:\n")
cat("====================\n")
print(summary(model3)) #Model3 summary table

##Plot of interaction between Ethnicity and Region Group
plotEthniRegion<-ggplot(VotingData,aes(x=EthnicityPC1,y=EthnicityPC2,z=Leave,color=RegionGroup)) +
  geom_point()



################################
#     Testing interactions   ###
################################

########Creating new model with interactions
#Try to add the interaction between ethnicity and region group
newmodel_1inter<-update(model3,.~. +EthnicityPC1*RegionGroup +EthnicityPC2*RegionGroup)
cat("====================\n")
cat("\nANOVA table (F test) between model3 and newmodel_1inter with interactions 
    between ethnicity related covariates and RegionGroup:\n")
cat("====================\n")

print(anova(model3,newmodel_1inter,test='F')) #ANOVA table 


##Plot of interaction between MultiDeprivd and Region Group
png("Figure5 MultiDeprived & Region Group.png")
plot(VotingData$MultiDepriv, VotingData$Leave, 
     col = as.factor(VotingData$RegionGroup),cex=0.8,xlab = "% of MultiDeprived",
     ylab = "% of Leave",main = "MultiDeprived & Leave (by Region)")
legend("topleft",legend = c("Group1", "Group2", "Group3", "Group4"),
       col=unique(VotingData$RegionGroup),pch=20)
modelxy1<-lm(Leave~MultiDepriv,subset = RegionGroup=="1",data = VotingData)
abline(modelxy1,col="black",cex=1.5)
modelxy2<-lm(Leave~MultiDepriv,subset = RegionGroup=="2",data = VotingData)
abline(modelxy2,col="red",cex=1.5)
modelxy3<-lm(Leave~MultiDepriv,subset = RegionGroup=="3",data = VotingData)
abline(modelxy3,col="green",cex=1.5)
modelxy4<-lm(Leave~MultiDepriv,subset = RegionGroup=="4",data = VotingData)
abline(modelxy4,col="blue",cex=1.5)
dev.off()


#adding interaction between multideprivation and region group, based on the model with 1 interaction
newmodel_2inter<-update(newmodel_1inter,.~. +MultiDepriv*RegionGroup)
cat("====================\n")
cat("\nAnova table(F test) between newmodel_1inter and newmodel_2inter with interactions 
    between 'MultiDepriv' and 'RegionGroup':\n")
cat("====================\n")

print(anova(newmodel_1inter,newmodel_2inter,test='F')) #ANOVA table


##Plot of interaction between L4Quals_plus and HigherOccup
plotL4Higher <- ggplot(VotingData, aes(L4Quals_plus, Leave, color = HigherOccup)) +
  geom_point(size = 2) +
  xlab("% of Degree level or above residents") +
  ylab("% of Leave")+
  labs(color = "% of Higher occupation")


#adding interaction between L4+ qualification holders and people having higher occupations
#based on the model with two interactions
newmodel_3inter<-update(newmodel_2inter,.~. +L4Quals_plus*HigherOccup)
cat("====================\n")
cat("\nAnova table(F test) between newmodel_2inter and newmodel_3inter with interactions 
    between 'L4Quals_plus' and 'HigherOccup':\n")
cat("====================\n")

print(anova(newmodel_2inter,newmodel_3inter,test='F')) #ANOVA table

#######################################
#######################################
#         Model4                    ###
#######################################
#######################################

model4<-newmodel_3inter #new model with 3 interactions denoted as model4
cat("====================\n")
cat("\nModel4 summary:\n")
cat("====================\n")
print(summary(model4))


#standard deviation of the prediction errors
vote.pred2 <-predict(model2,newdata=VotingData,type="response",se.fit=TRUE)
vote.pred3 <-predict(model3,newdata=VotingData,type="response",se.fit=TRUE)

vote.pred <-predict(model4,newdata=VotingData,type="response",se.fit=TRUE)
##plot for the fitted value
png("Figure7 Fitted plots.png")
par(mfrow=c(2,2))
plot(vote.pred2$fit, VotingData$Leave, xlim=c(0,1),ylim=c(0,1),
     main="Model2", xlab="predicted values", ylab="observed values")
abline(0,1,col="red")

plot(vote.pred3$fit, VotingData$Leave, xlim=c(0,1),ylim=c(0,1),
     main="Model3", xlab="predicted values", ylab="observed values")
abline(0,1,col="red")

plot(vote.pred$fit, VotingData$Leave, xlim=c(0,1),ylim=c(0,1),
     main="Model4", xlab="predicted values", ylab="observed values")
abline(0,1, col="red")
dev.off()

#QQ plot of Model4
png("Figure8 Model4_qqplot.png")
model4_stdres<-rstandard(model4)
qqnorm (model4_stdres, main="", ylab = "Standardised Residuals", xlab = "Quantiles of N(0,1)",pch = 20)
title(main="QQ-plot of model4")
qqline (model4_stdres, col = 'red')
dev.off()


# ##############################################################################
# ##############################################################################
# #               Export the plots/ Graphs                                  ####
# ##############################################################################
# ##############################################################################

#Figure1 Education use png() to save
#Figure2 Depriviation use png() to save
#Figure3 Occupation use png() to save
#Figure4
ggsave("Figure4 Ethnicity & RegionGroup.png",plot = plotEthniRegion,width = 6, height = 4, dpi = 300)
#Figure5 Multideprived and region interaction use png() to save
#Figure6
ggsave("Figure6 L4_Quals_plus & HigherOccupation.png",plot = plotL4Higher,width = 6, height = 4, dpi = 300)
#Figure7 fitted plots of all models use png() to save
#Figure8 QQ-plot of model4 use png() to save



# ##############################################################################
# ##############################################################################
# #                Predict output on test data                              ####
# ##############################################################################
# ##############################################################################

predict_data<-read.csv("ReferendumResults.csv")
predict_data <- predict_data[predict_data$Leave == -1, ]

Ethnicity.PCs_pre<-prcomp(predict_data[,27:31],scale.=TRUE)
predict_data$EthnicityPC1<-Ethnicity.PCs_pre$x[,1]
predict_data$EthnicityPC2<-Ethnicity.PCs_pre$x[,2]


# Create a new variable based on the RegionName column
predict_data$RegionGroup <- ifelse(predict_data$RegionName == "East Midlands", 1,
                                   ifelse(predict_data$RegionName %in% c("East of England", 
                                                                         "South East", "South West"), 2,
                                          ifelse(predict_data$RegionName == "London", 3, 4)))


SocialGrade.PC<-prcomp(predict_data[,47:49],scale.  =TRUE)###Social Grade PCA
predict_data$SocialGrade<-SocialGrade.PC$x[,1]

Owning.PC<-prcomp(predict_data[,32:33],scale.  =TRUE)   ###Housing Renting PCA
predict_data$Owning<-Owning.PC$x[,1]



test.pred <- predict(model4,        # The prediction
                     newdata=data.frame(predict_data),
                     type="response" , se.fit=TRUE)



# Create a data frame with the prediction and standard error
pred_df <- data.frame(predict_data$ID, test.pred$fit, test.pred$se.fit)

# Write the data frame to a .dat file
write.table(pred_df, "ICA_GROUP_CS_pred", sep = " ", row.names = FALSE, col.names = FALSE)

sink(); par(mfrow=c(1,1))


