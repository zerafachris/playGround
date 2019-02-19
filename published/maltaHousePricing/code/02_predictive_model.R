## PREDICTIVE MODELLING OF DATA ###############################################
print('PREDICTIVE MODELLING')
# rm(list=ls(all=TRUE))
load('02_3_tm_ready.RData')
# LIBRARIES
library(ggplot2)
library(plyr)
library(ggthemes)
library(zoo)
library(Metrics)
library(plyr)
library(dplyr)
library(caret)
library(moments)
library(glmnet)

# PM - Further analysis to identify Linear Regressions ######
source('02_DO_PLOTS.R')
TYPE_G <- unique(df$TYPE_GROUPING)[!is.na(unique(df$TYPE_GROUPING))] #SELECT GROUPINGS
DIST <- unique(df$DISTRICT)[which(unique(df$DISTRICT) != 'unknown')] #REMOVE UNKNOWN DISTRIC
predic_model_scatter(DIST,TYPE_G,df,3) #scatter plots vs time WHICH SAVE TO FILE
# PM - clean data for Predic Model ####
df_pd <- df
# str(df_pd) #CHECK WHICH ARE CHARACTER & set to numeric
df_pd$DAY_NUM <- as.numeric(df_pd$DAY_NUM)
df_pd$YEAR <- as.numeric(df_pd$YEAR)
df_pd$PHONE <- as.numeric(df_pd$PHONE)
df_pd$QUARTER <- as.numeric(df_pd$QUARTER)
df_pd$GARAGE <- as.numeric(df_pd$GARAGE)
df_pd$SHELL <- as.numeric(df_pd$QUARTER)
df_pd$FURNISHED <- as.numeric(df_pd$SHELL)
df_pd$POOL <- as.numeric(df_pd$POOL)
df_pd$ENSUITE <- as.numeric(df_pd$ENSUITE)
df_pd$DATE <- as.numeric(df_pd$DATE)
# replace unkown with NA
df_pd$LOCALITY[grepl('unknown',df_pd$LOCALITY)] <- NA 
#colSums(sapply(df_pd,is.na)) #count rows containing NAs
tiff(filename = '02_PRED_MODEL_NA_DATA.tiff',height = 8, width = 8, unit='in',res = 300) 
plot_missing(df_pd[,colSums(is.na(df_pd))>0]) #plot NA data
dev.off()
# remove COLUMNS: BEDROOM 11653, BATHROOM 47277,
# remove ROWS containing NA: LOCALITY 730, TYPE 1065, TYPE_GROUPING 106, PHONE 228
df_pd <- subset(df_pd, select = -c(BEDROOM, BATHROOM))
df_pd <- df_pd[complete.cases(df_pd),]
# PM - Model build ####
# loosley based on the following references:
# https://www.analyticsvidhya.com/blog/2015/09/complete-guide-boosting-methods/
# https://www.analyticsvidhya.com/blog/2015/09/perfect-build-predictive-model-10-minutes/  
# https://www.kaggle.com/jimthompson/house-prices-advanced-regression-techniques/regularized-linear-models-in-r
#https://www.kaggle.com/jimthompson/house-prices-advanced-regression-techniques/regularized-linear-models-in-r
df_pd <- subset(df_pd, select = -c(LOCALITY,TYPE)) #drop locality due to large number of options
df_pd <- subset(df_pd, select = -c(COUNT)) #drop count
feature_classes <- sapply(names(df_pd),function(x){class(df_pd[[x]])}) # Get data type for each feature
numeric_feats <-names(feature_classes[feature_classes != "character"]) # identify numeric feature
skewed_feats <- sapply(numeric_feats,function(x){skewness(df_pd[[x]],na.rm=TRUE)}) # determine skew for each numeric feature
df_pd$PRICE <- log(df_pd$PRICE + 1) # transform excessively skewed PRICE to log(PRICE + 1)
categorical_feats <- names(feature_classes[feature_classes == "character"]) # names of categorical features
dummies <- dummyVars(~.,df_pd[categorical_feats]) # caret dummyVars function for hot one encoding for categorical features
df_none_1_hot <- df_pd[(as.integer(nrow(df_pd)*0.9)+1):nrow(df_pd),]#SAVE score DF BEFORE ONE HOT CODING
categorical_1_hot <- predict(dummies,df_pd[categorical_feats]) #one-hot coding
df_pd <- cbind(df_pd[numeric_feats],categorical_1_hot) # reconstruct all_data with pre-processed data
# save(df_pd,file='02_df_predic_model.Rdata')
# load('02_df_predic_model.Rdata')

# split data in 90% training datset and 10% test
df_train <- df_pd[1:(as.integer(nrow(df_pd)*0.9)),]
df_train_price <- df_train$PRICE
df_train <- subset(df_train, select = -c(PRICE))

df_score <- df_pd[(as.integer(nrow(df_pd)*0.9)+1):nrow(df_pd),]
df_score_price <- df_score$PRICE
df_score <- subset(df_score, select = -c(PRICE))
# nrow(df_train)+nrow(df_score) #CHECK split
# CARET MODEL TRAINING PARAMETERS #####
# model specific training parameter
set.seed(55)  # for reproducibility
CARET.TRAIN.CTRL <- trainControl(method="repeatedcv",
                                 number=5,
                                 repeats=5,
                                 verboseIter=FALSE)
# Ridge regression model ####
lambdas <- seq(0.05,0,-0.0005)
# train model
set.seed(55)  # for reproducibility
model_ridge <- train(x=df_train,y=df_train_price,
                     method="glmnet",
                     metric="RMSE",
                     maximize=FALSE,
                     trControl=CARET.TRAIN.CTRL,
                     tuneGrid=expand.grid(alpha=0, # Ridge regression
                                          lambda=lambdas))
m1_ridge_mean <- mean(model_ridge$resample$RMSE) #MEAN rmse
m1_ridge_plot <- ggplot(data=filter(model_ridge$result,RMSE<0.5)) + geom_line(aes(x=lambda,y=RMSE)) + ggtitle(label = paste('Ridge regression model - Mean: ',round(m1_ridge_mean,4), sep = ''))+ theme_gdocs(base_family = 'Helvetica') + theme(plot.background = element_blank())
# Lasso regression model ####
# train model
set.seed(55)  # for reproducibility
model_lasso <- train(x=df_train,y=df_train_price,
                     method="glmnet",
                     metric="RMSE",
                     maximize=FALSE,
                     trControl=CARET.TRAIN.CTRL,
                     tuneGrid=expand.grid(alpha=1,  # Lasso regression
                                          lambda=lambdas))
                                          #lambda=c(1,0.1,0.05,0.01,seq(0.009,0.001,-0.001),
                                          #         0.00075,0.0005,0.0001)))
m2_lasso_mean <- mean(model_lasso$resample$RMSE)
m2_lasso_plot <- ggplot(data=filter(model_lasso$result,RMSE<0.5)) + geom_line(aes(x=lambda,y=RMSE))+ ggtitle(label = paste('Lasso regression model - Mean: ',round(m2_lasso_mean,4), sep = '')) + theme_gdocs(base_family = 'Helvetica') + theme(plot.background = element_blank())
#plot Ridge and Lasso
tiff(filename = '02_PRED_MODEL_REGULARISED_REG.tiff',height = 8, width = 8, unit='in',res = 300)
grid.newpage()
grid.draw(rbind(ggplotGrob(m1_ridge_plot),
                ggplotGrob(m2_lasso_plot),
                size = "last"))
dev.off()
# extract coefficients for the best performing model
coef <- data.frame(coef.name = dimnames(coef(model_lasso$finalModel,s=model_lasso$bestTune$lambda))[[1]],coef.value = matrix(coef(model_lasso$finalModel,s=model_lasso$bestTune$lambda)))
coef <- coef[-1,] # exclude the (Intercept) term
# print summary of model results
picked_features <- nrow(filter(coef,coef.value!=0))
not_picked_features <- nrow(filter(coef,coef.value==0))
# sort coefficients in ascending order
coef <- arrange(coef,-coef.value)
#plot coefficients
lass_coeff <- ggplot(coef) +
  geom_bar(aes(x=reorder(coef.name,coef.value),y=coef.value),
           stat="identity")  + theme_gdocs(base_family = 'Helvetica') +
  coord_flip() +
  ggtitle("Coefficents in the Lasso Model") +
  theme(axis.title=element_blank()) 
lass_coeff
ggsave("02_PRED_MODEL_REGULARISED_REG_coefficients.tiff", plot = lass_coeff,
       height = 8, width = 8, unit='in',dpi = 600) #SAVE TO FILE
# predictions ####
preds <- exp(predict(model_lasso,newdata=df_score)) -1 #convert predicts to normal price . recall converstion [XX = log(price + 1)] due to skewness

# crossvalidation of PREDICTON####
df_xval <- data.frame(df_none_1_hot,
                      PRICE_PREDIC = preds,
                      PRICE_CORRECT = (exp(df_score_price) -1)) 

# XVAL - RMSE ####
mod_RMSE <- rmse(sim = df_xval$PRICE_PREDIC,obs = df_xval$PRICE_CORRECT)
print(paste('Model RMSE: ', paste("€",format(round(mod_RMSE,0), big.mark=","),sep=""), sep = ''))
# XVAL - ANALYSIS ####
df_xval <- subset(df_xval, select = -c(PRICE))
df_xval$DATE <- as.Date(df_xval$DATE)
#save(df_xval,file = '02_df_xval.Rdata')
#load('02_df_xval.Rdata')
# quick plots
XX <- names(df_xval)[which(names(df_xval) != 'PRICE_PREDIC')]
XX <- XX[which(XX != 'PRICE_CORRECT')]
df_xval_melt <- melt(df_xval,id = XX)
names(df_xval_melt)[which(names(df_xval_melt)=='variable')] <- 'Model'
names(df_xval_melt)[which(names(df_xval_melt)=='value')] <- 'Price'
df_xval_melt$Model <- as.character(df_xval_melt$Model)
df_xval_melt$Model[grepl('PRICE_PREDIC',df_xval_melt$Model)] <- 'Predicted'
df_xval_melt$Model[grepl('PRICE_CORRECT',df_xval_melt$Model)] <- 'Original'
G1 <- ggplot(data = df_xval_melt,
       aes(x = DATE,
           y = Price,
           group = Model,
           colour = Model,
           shape = Model)) + geom_point() + theme_gdocs(base_family = 'Helvetica') + xlab('Date') + ylab('Price') + scale_y_continuous(labels = dollar_format(suffix = "", prefix = "€")) + ggtitle('XValidation - Date')
ggsave("02_PRED_MODEL_XVAL_scatter.tiff", plot = G1,
       height = 8, width = 8, unit='in',dpi = 600) #SAVE TO FILE
#  DEVIATION OF Predicted FROM Original ####
# compute normalised deviation from correct value
df_xval$NORM_DEV <- sqrt((log(df_xval$PRICE_CORRECT+1) - log(df_xval$PRICE_PREDIC+1))^2)/log(df_xval$PRICE_CORRECT+1)
df_xval_ERR <-subset(df_xval, select = -c(PRICE_PREDIC,PRICE_CORRECT)) #remove PREDIC and CORRECT
df_xval_ERR$TYPE_GROUPING <- capitalize(df_xval_ERR$TYPE_GROUPING) #format name
# density plots for the different plots for the different parameters
tiff(filename = '02_PRED_MODEL_XVAL_1.tiff',height = 10, width = 10, unit='in',res = 300)
plots_PM(deviation_density,c(1,  2 , 3 , 5,  7 , 8),2)
dev.off()
tiff(filename = '02_PRED_MODEL_XVAL_2.tiff',height = 10, width = 10, unit='in',res = 300)
plots_PM(deviation_density,c(9, 10, 11, 12, 13, 14),2)
dev.off()

