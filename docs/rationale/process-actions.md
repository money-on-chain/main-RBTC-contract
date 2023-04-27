# Process Actions

## System Liquidation

If the BTC/USD price drops drastically, an none of the incentive mechanisms along the coverage dropping prevents it to cross the liquidation threshold (currently: coverage < 1.04) the system will enter the liquidation state and the liquidation function will be available to be executed.
Although there is an specific method to evaluate liquidation (`evalLiquidation`), to guarantee this process is executed, the same logic is evaluated and, if needed, executed in every MoC state changing method. For example, mintDocVendors, redeemBProVendors, etc or even settlement itself; every that has the `transitionState` modifier actually.
Liquidation process will invalidate the BitPro Token (it cannot be transfer any more) as a precaution measure as it has no more RBTC backing it, it has no value. Users can redeem all of their DoCs at once, valued at the liquidation price.

## Commission splitting

By adding the CommissionSplitter contract and set it as the destination of Money on Chain commissions (just as a normal commission destination address), the splitting process can be made.

The CommissionSplitter contract will accumulate commissions until the `split()` function is called. At that moment a part of the commissions will be added to Money on Chain reserves using the Collateral Injection functionality and the other part will be sent to a final destination address.

## Collateral injection

Collateral injection is the operation of adding reserveTokens to the system's reserves without minting RiskPro. This come in handy when reserves are running low and there is a need of Stable token minting.

This injection is made by sending funds directly to the main MoC Contract, this will result in executing the fallback function which will update the internal values according to the sent value.
