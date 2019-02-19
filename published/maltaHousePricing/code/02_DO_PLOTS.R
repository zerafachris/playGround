doPlots <- function(data_in, fun, ii, ncol=3) {
  pp <- list()
  for (i in ii) {
    p <- fun(data_in=data_in, i=i)
    pp <- c(pp, list(p))
  }
  do.call("grid.arrange", c(pp, ncol=ncol))
}

plotHist <- function(data_in, i) {
  data <- data.frame(x=data_in[[i]])
  p <- ggplot(data=data, aes(x=factor(x))) + stat_count() + xlab(colnames(data_in)[i]) + theme_light() + 
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
  return (p)
}

plotDen <- function(data_in, i){
  data <- data.frame(x=data_in[[i]], PRICE = data_in$PRICE)
  p <- ggplot(data= data) + geom_line(aes(x = x), stat = 'density', size = 1,alpha = 1.0) +
    xlab(paste0((colnames(data_in)[i]), '\n', 'Skewness: ',round(skewness(data_in[[i]], na.rm = TRUE), 2))) + theme_light() 
  return(p)
}

plotCorr <- function(data_in, i){
  data <- data.frame(x = data_in[[i]], Price = data_in$Price)
  p <- ggplot(data, aes(x = x, y = Price)) + geom_point(shape = 1, na.rm = TRUE) + geom_smooth(method = lm ) + xlab(paste0(colnames(data_in)[i], '\n', 'R-Squared: ', round(cor(data_in[[i]], data$Price, use = 'complete.obs'), 2))) + theme_light()
  return(suppressWarnings(p))
}

cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}
lm_eqn <- function(df,x,y){ 
  m <- lm(y ~ x, df);
  eq <- paste('y = ',format(coef(m)[1], digits = 2),
              ' + ',format(coef(m)[2], digits = 2),
              '*x',sep = '')
  as.character(as.expression(eq));                 
}
plot_scatter <- function(df, DIST, TYPE_G){ #DIST <- 'Northen';TYPE_G <- 'commercial'
  data_in <- df[which(df$DISTRICT == DIST & df$TYPE_GROUPING == TYPE_G),]
  data <- data.frame(x = data_in$DATE, Price = data_in$PRICE)
  line_eqn <- lm_eqn(df = data_in,data_in$DATE,data_in$PRICE)
  p <- ggplot(data, aes(x = x, y = Price)) + geom_point(shape = 1, na.rm = TRUE) + geom_smooth(method='lm',formula=y~x) + xlab(paste0('DATE \n', 'R^2: ', round(cor(as.numeric(data_in$DATE), data$Price, use = 'complete.obs'), 4),', ',line_eqn)) + ggtitle(label = paste(DIST,TYPE_G,sep = ' - ') )+ theme_light()
  return(suppressWarnings(p))
}

predic_model_scatter <- function(DIST, TYPE_G, df,numcols) {
  for (i in DIST){ #i <- 'Northen'
    pp <- c()
    for (j in TYPE_G){ #j<-'commercial'
      p <- plot_scatter(df,i,j)
      pp <- c(pp, list(p))
    }
    picname <- paste('02_PRED_MODEL_scatters_',i,'.tiff',sep = '')
    tiff(filename = picname,height = 8, width = 8, unit='in',res = 300) 
    do.call("grid.arrange", c(pp, ncol=numcols))
    dev.off()
  }
}

plot_missing <- function(data_in, title = NULL){
  temp_df <- as.data.frame(ifelse(is.na(data_in), 0, 1))
  temp_df <- temp_df[,order(colSums(temp_df))]
  data_temp <- expand.grid(list(x = 1:nrow(temp_df), y = colnames(temp_df)))
  data_temp$m <- as.vector(as.matrix(temp_df))
  data_temp <- data.frame(x = unlist(data_temp$x), y = unlist(data_temp$y), m = unlist(data_temp$m))
  p <- ggplot(data_temp) + geom_tile(aes(x=x, y=y, fill=factor(m))) + scale_fill_manual(values=c("white", "black"), name="Missing\n(0=Yes, 1=No)") + theme_light() + ylab("") + xlab("") + ggtitle(title)
  return(suppressWarnings(p))
}

deviation_density <- function(PROP) {
  p <- ggplot(data = df_xval_ERR) + geom_line(aes(NORM_DEV,color = as.character(df_xval_ERR[,which(names(df_xval_ERR)==PROP)])),stat = 'density', size = 1,alpha = 1.0) + theme_light() + ylab('Density') + xlab('log(Normalised Deviation)') + theme(legend.title=element_blank(),plot.background = element_blank()) + ggtitle(label = PROP)
  suppressWarnings(p)
}
plots_PM <- function(fun, ii, ncol=3) {
  # fun <- deviation_density; ii <- 1:14; ncol <-3
  pp <- list()
  for (i in ii) { #i<-1
    p <- fun(names(df_xval_ERR)[i])
    pp <- c(pp, list(p))
  }
  do.call("grid.arrange", c(pp, ncol=ncol))
}
