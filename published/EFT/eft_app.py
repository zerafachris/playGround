import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html

from pandas_datareader import data as web
from datetime import datetime as dt
from plotly import graph_objs as go


import quandl as qd
qd.ApiConfig.api_key = '_snzQRYasyZYGYgx5Yms'
import numpy as np

import pandas as pd
import matplotlib.pyplot as plt
import datetime


app = dash.Dash('')
# =============================================================================
# Identify the unique tickers present
# =============================================================================
# search back XX days
dd = 1
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
tickerList['tickerName'] = tickerList.ticker +' - ' +tickerList.Name
#tickerList = tickerList.head()
def effFrontierSim(tickers,NumPortfolios,NumYears):
    #keep tickers that are greater than 1
    tickers = [s for s in tickers if len(s) > 1]
    numYears = int(NumYears)
    #set number of runs of random portfolio weights
    num_portfolios = int(NumPortfolios)
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
    for ii in tickers: #ii=1
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
    results = np.zeros(((3+len(tickers)),num_portfolios))
    # loop doing MC sims
    for ii in range(num_portfolios): #ii = 1
        #select random weights for portfolio holdings
        weights = np.random.random(len(tickers))
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
    colNames = ['ret','stdev','sharpe']+tickers
    results_frame = pd.DataFrame(results.T,columns= colNames)
    #locate position of portfolio with highest Sharpe Ratio
    max_sharpe_port = results_frame.iloc[results_frame['sharpe'].idxmax()]
    #locate positon of portfolio with minimum standard deviation
    min_vol_port = results_frame.iloc[results_frame['stdev'].idxmin()]
    results = dict(results_frame = results_frame,
                   cov = cov_matrix,
                   maxSharpe = max_sharpe_port,
                   minVol = min_vol_port)
    return results

# =============================================================================
# app layout
# =============================================================================
pageSize = '1000'
sliderWidth = '250'

default_portfolio_test = '1000' #10
default_years_history = '10' #2


app.layout = html.Div([
        html.H1(children='''Effeciency Frontier Simulation'''),
        html.Div([
            html.Div([
                    html.H4(children='''Sector:'''),
                    dcc.Dropdown(
                            id='cklist-Sector',
                            options=[{'label': i, 'value': i} for i in list(set(tickerList.Sector))],
                            value=['Technology'],
                            multi=True
                            )
                    ],style={'width': sliderWidth}),#,'display': 'inline-block'}),
            html.Div([
                    html.H4(children='''Industry:'''),
                    dcc.Dropdown(
                            id='cklist-Ind'
    #                        options=[{'label': i, 'value': i} for i in tickerList.Industry],
                            , value=['Electrical Products']
                            , multi=True
                            )
                    ],style={'width': sliderWidth}),#,'display': 'inline-block'}),
            html.Div([
                    html.H4(children='''Ticker:'''),
                    dcc.Checklist(
                            id='cklist-ticker',
            #                options=[{'label': i, 'value': j} for i,j in zip(tickerList.tickerName,tickerList.ticker)],
                            values=['SANM','PLXS','TTMI']
                            )
                    ],style={'width': sliderWidth})#,'display': 'inline-block'}),
                ],style={'display': 'inline-block','width' : sliderWidth}),
        html.Div([
                html.H6("Covariance Matrix", className="gs-header gs-table-header padded"),
                html.Table(id='cov-table', className="reversed"),
                html.H6("Max Return Portfolio:"),
                html.P(id='maxReturn-table'),
                html.H6("Min Volatility Portfolio:"),
                html.P(id='minVol-table'),
                ],style={'width': sliderWidth, 'float': 'right', 'display': 'inline-block'}),
        html.Div([
                html.Div([
                        html.Div([
                                html.P(children='''Portfolios to Test :'''),
                                dcc.Input(id='input-1-NumPort', type="integer", value=default_portfolio_test)
                                ],style={'display': 'inline-block'}),
                        html.Div([
                                html.P(children='''Years of History :'''),
                                dcc.Input(id='input-2-NumYears', type="integer", value=default_years_history)
                                ],style={'display': 'inline-block'})
                        ]),
                dcc.Graph(id='eft-graph')
                ],style={'width': str(int(pageSize)-(int(sliderWidth)*2)), 'float': 'right', 'display': 'inline-block'}),
        html.Div([])
        ], style={'width': pageSize})

@app.callback(
    dash.dependencies.Output('cklist-Ind', 'options'),
    [dash.dependencies.Input('cklist-Sector', 'value')])
def set_sector_options(selected_Sector): #selected_Sector = ['Finance']
    return [{'label': i, 'value': i} for i 
            in list(set(tickerList[tickerList.Sector.isin(selected_Sector)].Industry))]

@app.callback(
    dash.dependencies.Output('cklist-ticker', 'options'),
    [dash.dependencies.Input('cklist-Ind', 'value'),
     dash.dependencies.Input('cklist-Sector', 'value')])
def set_ticker_options(selected_Ind, selected_Sector): #selected_Sector = ['Energy'] selected_Ind = ['Coal Mining']
    return [{'label': i, 'value': j} for i,j 
            in zip(
                    list(set(tickerList[tickerList.Sector.isin(selected_Sector) & tickerList.Industry.isin(selected_Ind)].tickerName)),
                    list(set(tickerList[tickerList.Sector.isin(selected_Sector) & tickerList.Industry.isin(selected_Ind)].ticker)))]
    
@app.callback(Output('eft-graph', 'figure'),
              [Input('cklist-ticker', 'values'),
               Input('input-1-NumPort', 'value'),
               Input('input-2-NumYears', 'value')])
def eft_fig(ticker_value,NumPort,NumYears):
    results_frame = effFrontierSim(ticker_value,NumPort,NumYears)['results_frame']
    return {
        'data': [{
                'x': results_frame.stdev,
                'y': results_frame.ret,
                'mode': 'markers'
                }],
        'layout': {
                'margin': {'l': 40, 'r': 0, 't': 20, 'b': 30},
                'xaxis': {
                        'title': 'Volatlity'
                },
                'yaxis': {
                    'title': 'Return'
                }
                }
    }
                                               
def make_dash_table(df): #df=cov
    ''' Return a dash definitio of an HTML table for a Pandas dataframe '''
    table = []
    for index, row in df.iterrows():
        html_row = []
        for i in range(len(row)):
            html_row.append(html.Td([row[i]]))
        table.append(html.Tr(html_row))
    table
    return table

@app.callback(Output('cov-table', 'children'),
              [Input('cklist-ticker', 'values'),
               Input('input-1-NumPort', 'value'),
               Input('input-2-NumYears', 'value')])
def cov_tab(ticker_value,NumPort,NumYears):
    cov = effFrontierSim(ticker_value,NumPort,NumYears)['cov']
    cov = cov.round(5)
    cov['tickers']=cov.index
    covCols = cov.columns.tolist()
    covCols = covCols[-1:] + covCols[:-1]
    cov=cov[covCols]
    cov2 = cov.columns.tolist()
    cov.loc[len(tickerList)+1] = cov2
    modifed_cov_table = make_dash_table(cov)
    return modifed_cov_table
@app.callback(Output('maxReturn-table', 'children'),
              [Input('cklist-ticker', 'values'),
               Input('input-1-NumPort', 'value'),
               Input('input-2-NumYears', 'value')])
def maxReturn_tab(ticker_value,NumPort,NumYears):
    maxReturn = effFrontierSim(ticker_value,NumPort,NumYears)['maxSharpe']
    maxReturn = ''.join('{} {:.6f} \u000A'.format(key, val) for key, val in maxReturn.items())
    return maxReturn
@app.callback(Output('minVol-table', 'children'),
              [Input('cklist-ticker', 'values'),
               Input('input-1-NumPort', 'value'),
               Input('input-2-NumYears', 'value')])
def minVolatility_tab(ticker_value,NumPort,NumYears):
    minVolatility = effFrontierSim(ticker_value,NumPort,NumYears)['minVol']
    minVolatility = ''.join('{} {:.6f} \u000A'.format(key, val) for key, val in minVolatility.items())
    return minVolatility

app.css.append_css({'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'})
# default server : http://127.0.0.1:8050/
if __name__ == '__main__':
    app.run_server()