# EA_Swap

## Description
This automated investment strategy opens a position in a positive-swap forex pair before the end of wednesday session, and closes that position at the beginning of thursday session.

## Profit / Loss Theory
On the one hand, we have a loss caused by the spread and broker commission. 
We also have random probabilities of the price going against or in our favor during that small period of time.

On the other hand, we have a profit due to the triple rollover made on wednesday at 17:04:01 (New York time)

In conclusion, this EA is profitable if (3*swap > commission + spread) == true and variance is small enough.
If variance is too big, results will be random and not based on statistics and probability.

## Optimization


## Disclaimer
This code is disclosed publicly for educational purposes only.
It is expected that this EA has a low scalability and may have divergence due to lower liquidity and bigger spreads in the foreign exchange markets at open/close times. There may also be differences between backtests/demo and live accounts due to slippage
User at your own risk. I'm not responsible for any financial loss or damage caused by the use of this software.
