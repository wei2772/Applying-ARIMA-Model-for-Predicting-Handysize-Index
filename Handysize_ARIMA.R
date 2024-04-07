library(tseries)
library(forecast)
library(fpp)
library(lmtest)
library(urca)
library(vars)
library(tsDyn)
library(caret)
handysize_data <- read.csv("handysize_new.csv", header=TRUE)
handysize_data <- handysize_data[3:152,-1] 
handysize_season <- as.data.frame(matrix(0,nrow(handysize_data)/3,ncol(handysize_data)))
names(handysize_season) <- names(handysize_data)
for (i in 1:50)
{
  for (j in 1:17)
  {
    if (j==1){handysize_season[i,j] <- handysize_data[i*3-2,j]+handysize_data[i*3-1,j]+handysize_data[i*3,j]}
    else {handysize_season[i,j] <- (handysize_data[i*3-2,j]+handysize_data[i*3-1,j]+handysize_data[i*3,j])/3}
  }
}  


##find KPI
library(earth)
findKPI<-earth(Handysize~., degree=3, trace=2, data=handysize_season)
marsKPI<-varImp(findKPI)
marsKPI
#BHI_t.1+PPI_US+PPI_CN+Wheat+Australian.thermal.coal

handy <- ts(handysize_season$Handysize,start=c(2011,2), freq=4)

KPI1 <- ts(handysize_season$BHI_t.1,start=c(2011,2), freq=4)
KPI2 <- ts(handysize_season$PPI_US,start=c(2011,2), freq=4)
KPI3 <- ts(handysize_season$PPI_CN,start=c(2011,2), freq=4)
KPI4 <- ts(handysize_season$Wheat,start=c(2011,2), freq=4)
KPI5 <- ts(handysize_season$Australian.thermal.coal ,start=c(2011,2), freq=4)


table = array(0,c(3,3))
rownames(table)<-c("RMSE","MAE","MAPE")
colnames(table)<-c("SARIMA","DARIMA","Lag")

##stationary##
attach(handysize_season)

ndiffs(KPI1)
ndiffs(KPI2)
ndiffs(KPI3)
ndiffs(KPI4)
ndiffs(KPI5)

adf.test(handy)
pp.test(handy)
kpss.test(handy)
ndiffs(handy)

dif1_handy <- diff(handy)
adf.test(dif1_handy)
pp.test(dif1_handy)
kpss.test(dif1_handy)

####simple####
#auto.arima(handy, max.order=10, trace = T, d = 1, ic ="aic", approximation = FALSE, stepwise = FALSE)

ArimaS <- Arima(handy, order= c(3,1,2), seasonal = list(order=c(1,0,0), period=4),include.drift=T)


Box.test(ArimaS$residuals,lag = 4,type = c("Ljung-Box"))
tsdiag(ArimaS)
table[1,1]<- sqrt(mean((ArimaS$residuals)^2)) #RMSE
table[2,1]<- mean(abs(ArimaS$residuals)) #MAE
table[3,1]<- mean(abs(ArimaS$residuals/handy)) #MAPE


forecastS <- forecast(ArimaS,h=4,level=c(95))
print(forecastS)
plot(forecastS, xlab = "Year",ylab = "handysize", main = "Forecast for Handysize")
lines(forecastS$fitted,col="green")
lines(handy,col="red")
legend("topleft",legend=c("Predicted","Real"),fill=c("green","red"))

####KPI1~KPI5####
#auto.arima(KPI1, max.order=10, trace=T, ic="aic",approximation=FALSE, stepwise=FALSE)
Arima1<-Arima(KPI1,order=c(3,1,1),seasonal=list(order=c(0,0,1),period=4),include.drift=T)
forecast1<-forecast(Arima1,h=4,level=c(95))

#auto.arima(KPI2, max.order=10, trace=T, ic="aic",approximation=FALSE, stepwise=FALSE)
Arima2<-Arima(KPI2,order=c(1,1,0),include.drift=T)
forecast2<-forecast(Arima2,h=4,level=c(95))

#auto.arima(KPI3, max.order=10, trace=T, ic="aic",approximation=FALSE, stepwise=FALSE)
Arima3<-Arima(KPI3,order=c(1,0,3),seasonal=list(order=c(2,0,0),period=4),include.drift=T)
forecast3<-forecast(Arima3,h=4,level=c(95))

#auto.arima(KPI4, max.order=10, trace=T, ic="aic",approximation=FALSE, stepwise=FALSE)
Arima4<-Arima(KPI4,order=c(0,1,0),include.drift=T)
forecast4<-forecast(Arima4,h=4,level=c(95))

#auto.arima(KPI5, max.order=10, trace=T, ic="aic",approximation=FALSE, stepwise=FALSE)
Arima5<-Arima(KPI5,order=c(0,1,2),seasonal=list(order=c(0,0,1),period=4),include.drift=T)
forecast5<-forecast(Arima5,h=4,level=c(95))

####dynamic####
xhandyD<- cbind(KPI1,KPI2,KPI3,KPI4,KPI5)
#auto.arima(handy,xreg=xhandyD, max.order=10, d=1,trace=T, ic="aic",approximation=FALSE, stepwise=FALSE)

arimaD<-Arima(handy, xreg=xhandyD,order= c(3,1,0), seasonal= list(order=c(2,0,1), period=4),include.drift=T)
summary(arimaD)

##arima model
Box.test(arimaD$residuals,lag = 4,type = c("Ljung-Box"))
tsdiag(arimaD)
table[1,2]<- sqrt(mean((arimaD$residuals)^2)) #RMSE
table[2,2]<- mean(abs(arimaD$residuals)) #MAE
table[3,2]<- mean(abs(arimaD$residuals/handy)) #MAPE


xr.handyD=cbind(forecast1$mean,forecast2$mean,forecast3$mean,forecast4$mean,forecast5$mean)
forecastD<-forecast(arimaD,h=4,level=c(95),xreg=xr.handyD)
print(forecastD)
plot(forecastD, xlab="Year", ylab= "handysize", main="Forecast for Handysize without lags")
lines(forecastD$fitted,col="green")
lines(handy,col="red")
legend("topleft",legend=c("Predicted","Real"),fill=c("green","red"))


##dynamic
xhandyL<- cbind(KPI1,KPI2,KPI3,KPI4,KPI5)
best_aic=1000000
best_i=0
best_j=0
best_k=0
best_l=0
best_m=0
system.time({
  for (i in 0:4)
  {  
    for (j in 0:4)
    { 
      for (k in 0:4)
      {
        for (l in 0:4)
        {
          for (m in 0:4)
          {
            n=max(i,j,k,l,m)
            x_start=1+n
            xhandyL=cbind(KPI1[(x_start-i):(50-i)],KPI2[(x_start-j):(50-j)],KPI3[(x_start-k):(50-k)],KPI4[(x_start-l):(50-l)],KPI5[(x_start-m):(50-m)])
            arimaxhandyL=auto.arima(handy[x_start:50],xreg=xhandyL, max.order=10, d=1, trace=T, ic="aic",approximation=FALSE, stepwise=FALSE)
            cat("time=",i*625+j*125+k*25+l*5+m+1,"\n")
            if(arimaxhandyL$aic<best_aic)
            {
              best_aic=arimaxhandyL$aic
              best_i=i
              best_j=j
              best_k=k
              best_l=l
              best_m=m
            }
          }
        }
      }
    }
  }
  cat("p=",best_i,"\t",best_j,"\t",best_k,"\t",best_l,"\t",best_m,"\t","best_aic",best_aic,"\n")
})
#p= 0 	 4 	 1 	 3 	 0 	 best_aic 1594.48 

xhandyD<- cbind(KPI1[5:50], KPI2[1:46],KPI3[4:49],KPI4[2:47],KPI5[5:50])
#auto.arima(handy[5:50],xreg=xhandyD, max.order=10, d=1 ,trace=T, ic="aic",approximation=FALSE, stepwise=FALSE)

arimaL<-Arima(handy[5:50], xreg=xhandyD,order=c(0,1,4),include.drift=T)
summary(arimaL)

##arima model
Box.test(arimaL$residuals,lag= 4,type = c("Ljung-Box"))
tsdiag(arimaL)
table[1,3]<-sqrt(mean((arimaL$residuals)^2)) #RMSE
table[2,3]<-mean(abs(arimaL$residuals)) #MAE
table[3,3]<-mean(abs(arimaL$residuals/handy[5:50])) #MAPE

xr.hdL=cbind(forecast1$mean,KPI2[47:50],c(KPI3[50], forecast3$mean[1:3]),c(KPI4[48:50],forecast4$mean[1]),forecast5$mean)
forecastL<-forecast(arimaL,h=4,level=c(95),xreg=xr.hdL)
print(forecastL)

plot(forecastL, xlab="Year", ylab= "handysize", main="Forecast for Handysize considering lags")
lines(forecastL$fitted,col="green")
lines(handy[5:50],col="red")
legend("topleft",legend=c("Predicted","Real"),fill=c("green","red"))

