# MoC precisions

The Money on Chain system handles different types of currency precision to operate with tokens and RBTC. The **MoCLibConnection** contract defines 2 variables that are used across the platform:

- _mocPrecision_: Currently DoC, BPros and BTCx tokens use 18 decimal places of precision.
- _reservePrecision_: Currently RBTC amounts use 18 decimal places of precision.
