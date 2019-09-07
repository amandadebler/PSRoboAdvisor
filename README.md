# PSRoboAdvisor
The robo advisor for DIY S&P 500 indexing that nobody asked for - in PowerShell.

DIY indexing is pointless for most of you - buying VOO (S&P 500) or VT (total US market) will give you similar results with much less headache.

If, like me, you are a US citizen living in the EU, this is probably not possible. Your US brokerage will not let you buy US ETFs if they know that you live in the EU, and few EU brokerages will have anything to do with you when they find out that you're a US citizen, and even if they will take your money, you do NOT want to deal with PFIC taxes on non-US-domiciled funds. VUSA is Vanguard's S&P 500 ETF for the European market, but because it is domiciled in Ireland, is a PFIC for US taxpayers.

We can still buy individual stocks. So, DIY time!

This tool will help you find the closest approximation of the S&P 500 at the previous trading day's closing prices for a given amount of money, transaction cost and desired expense ratio.

Data source: https://www.slickcharts.com/sp500. If the format there ever changes, I'll need to update this script.

## How to use

Copy the PSRoboAdvisor folder into C:\yourusername\Documents\WindowsPowerShell\Modules.

Open PowerShell and run:

Import-Module PSRoboAdvisor

Find out what your transaction fees are for stock purchases ($4.95 with Schwab and Fidelity, lower with Interactive Brokers and other services designed for active traders) and decide what expense ratio you're willing to tolerate (2% by default)

To find the best fit portfolio for $40,000 with a transaction fee of $4.95 per purchase and desired expense ratio of 1%:

$myportfolio = Get-BestFitPortfolio -amount 40000 -transactionCost 4.95 -maxCostRatio 0.01

- Cost of your portfolio, including transaction fees: $myportfolio.cost
- List of stocks and how many shares to buy: $myportfolio.portfolio
- How many different stocks are in this portfolio: $myportfolio.portfolio.count
