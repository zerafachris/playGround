import quandl as qd
qd.ApiConfig.api_key = '_snzQRYasyZYGYgx5Yms'
import numpy as np

import pandas as pd
import matplotlib.pyplot as plt
import datetime

# =============================================================================
# Identify the unique tickers present
# =============================================================================
# search back XX days
dd = 2
dataQD = qd.get_table('WIKI/PRICES', 
                            qopts = { 'columns': ['ticker'] }, 
                            date = {'gte' : '2018-02-17'},
# this data source was no longer mainted as of 2018-02-11, so I have fixed the date as at '2018-02-17'                            
#                            date = { 'gte':datetime.datetime.now().date() - datetime.timedelta(days=dd)},
                            paginate=True)
dataQD = pd.DataFrame(list(set(dataQD.ticker)))
dataQD.rename(columns={0:'ticker'},inplace=True)
# Get additional information for the tickers
tickerInfo=pd.read_csv('http://www.nasdaq.com/screening/companies-by-industry.aspx?exchange=NASDAQ&render=download')
# inner join both datasets
tickerList = dataQD.merge(tickerInfo, left_on='ticker',right_on='Symbol',how='inner')

# =============================================================================
# Parameters
# =============================================================================
# identify stocks
stocks = ['AAPL', 'AMZN', 'MSFT', 'GOOGL']
# number of years to track back from current
numYears = 10
#set number of runs of random portfolio weights
num_portfolios = 250


# =============================================================================
# create required data for EFT
# =============================================================================
sdate = datetime.datetime.now().date() - datetime.timedelta(days=numYears*365)

# function which connects to quandl based on stokc ticker
def getQDclose(stockTicker): # stockTicker = 'MSFT'
    data = qd.get_table('WIKI/PRICES', 
                            qopts = { 'columns': ['date','adj_close'] }, 
                            ticker = stockTicker, 
                            date = { 'gte':sdate },
                            paginate=True)
    data.rename(columns={'adj_close':stockTicker},inplace=True)
    return data

df = pd.DataFrame(pd.date_range(sdate,datetime.datetime.today()), columns=['date'] )

for ii in stocks:
    df = df.merge(getQDclose(ii), left_on='date',right_on='date',how='left')

# drop na within dataframe
df = df.dropna(0)
# change index to date
df.index = df['date']
# drop date column
del df['date']

# =============================================================================
# EFT
# =============================================================================
#convert daily stock prices into daily returns
returns = df.pct_change()
 
#calculate mean daily return and covariance of daily returns
mean_daily_returns = returns.mean()
cov_matrix = returns.cov()
 
#set up array to hold results
results = np.zeros(((3+len(stocks)),num_portfolios))

# loop doing MC sims
for ii in range(num_portfolios): #ii = 2
    #select random weights for portfolio holdings
    weights = np.random.random(len(stocks))
    #rebalance weights to sum to 1
    weights /= np.sum(weights)
 
    #calculate portfolio return and volatility
    # 252 trading days
    portfolio_return = np.sum(mean_daily_returns * weights) * 252
    portfolio_std_dev = np.sqrt(np.dot(weights.T,np.dot(cov_matrix, weights))) * np.sqrt(252)
 
    #store results in results array
    results[0,ii] = portfolio_return
    results[1,ii] = portfolio_std_dev
    #store Sharpe Ratio (return / volatility) - risk free rate element excluded for simplicity
    results[2,ii] = results[0,ii] / results[1,ii]
    #iterate through the weight vector and add data to results array
    for jj in range(len(weights)):
        results[jj+3,ii] = weights[jj]
 
#convert results array to Pandas DataFrame
colNames = ['ret','stdev','sharpe']+stocks
results_frame = pd.DataFrame(results.T,columns= colNames)

# =============================================================================
# EFT results 
# =============================================================================
# PLOT
#locate position of portfolio with highest Sharpe Ratio
max_sharpe_port = results_frame.iloc[results_frame['sharpe'].idxmax()]
#locate positon of portfolio with minimum standard deviation
min_vol_port = results_frame.iloc[results_frame['stdev'].idxmin()]
 
#create scatter plot coloured by Sharpe Ratio
plt.scatter(results_frame.stdev,results_frame.ret,c=results_frame.sharpe,cmap='RdYlBu')
plt.xlabel('Volatility')
plt.ylabel('Returns')
plt.colorbar()
#plot red star to highlight position of portfolio with highest Sharpe Ratio
plt.scatter(max_sharpe_port[1],max_sharpe_port[0],marker=(5,1,0),color='r',s=100)
#plot green star to highlight position of minimum variance portfolio
plt.scatter(min_vol_port[1],min_vol_port[0],marker=(5,1,0),color='g',s=100)

# rels
print('Max sharpe :'+ max_sharpe_port)
print('Min volatility :' + min_vol_port)
print(cov_matrix)
plt.matshow(cov_matrix)

# print portfolio to maximize sharpe ratio
print('**********Portfolio to Maximize Sharpe Ratio**********')
print(max_sharpe_port)
# print portfolio to minimize portfolio variance
print('**********Portfolio to Minimize Volatility**********')
print(min_vol_port)
plt.show(plt.scatter)
plt.show(plt.colorbar())

