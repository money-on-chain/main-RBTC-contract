# Process Actions

## Interest-payments

Leveraged positions are charged by an interest as return for the borrowed value.
On each investment, the total interest to be paid is calculated and pre-allocated in an common interest "bag" (inrateBag) for all payments.
Once a day[^1] the smart contract allows a transaction to move certain amount of RBTC from that bag, to the base bucket itself.
Once executed for the current block span, it gets blocked "waiting" for blocks to be mined until the conditions are meet again.

[^1]: based on a given number of blocks dependent on the network's mining rate.

## Settlement

Similar to daily payments, settlements are a time based recurrent process which relies on block number to allow/reject execution. This is currently intended to execute on 90 day intervals, although it can be adjusted on deploy.
During settlement, two important events take place: deleveraging of leveraged positions, and Doc redeem request processing.

As this process involves array loops, it might require more than on call to complete. That's why it is wrapped on a TASK and the step amount parameter indicates the maximum number of iterations to be performed on each call. Take in account that during the execution (in between calls) some other functions won't be available to execute.

### Deleveraging

Although the name deleveraging evokes a broader process, in this case it just refers to the "settlement" of all individual leveraged position. At this time, all interests should had been payed (as they depends inversely to days to settlement), so it's a matter of converting the remaining open positions to RBTC and give back the corresponding DoCs borrowed. Under the hood, it simply invokes redeem for each user account. Market will determine whether they had lost or earned money.

### DoC redeem requests

As explained in the [redeem section](../integration/redeeming-docs.md), docs are not entirely liquid but need to be programmed to be redeemed (burn DoC and retrieve RBTC). Users enter a list (currently called queue in anticipation of future pagination) waiting to be executed during settlement.
This events simply goes through the aforementioned collection burning the corresponding DoC amount[^1], sending the equivalent RBTC (at the current BTC-USD rate) and obviously updating the bucket balances in the process.
Said collection should be empty at the end of the process.

[^1]: Note that the intended amount it's not validated until processing, so obviously that amount would only be fulfilled if the user actually owns that amount of DoCs. If he has less, all of them will be redeemed.

## System Liquidation

If the BTC/USD price drops drastically, an none of the incentive mechanisms along the coverage dropping prevents it to cross the liquidation threshold (currently: coverage < 1.04) the system will enter the liquidation state and the liquidation function will be available to be executed.
Although there is an specific method to evaluate liquidation (`evalLiquidation`), to guarantee this process is executed, the same logic is evaluated and, if needed, executed in every MoC state changing method. For example, mintDocVendors, redeemBProVendors, etc or even settlement itself; every that has the `transitionState` modifier actually.
Liquidation process will invalidate the BitPro Token (it cannot be transfer any more) as a precaution measure as it has no more RBTC backing it, it has no value. Users can redeem all of their DoCs at once, valued at the liquidation price.

## Bucket Liquidation

Leveraged buckets will get to critical coverage values quicker than the system as a whole, so they will potentially cross liquidation threshold (currently `liq = 1.04`) sooner.
Bucket liquidation process is verified on every bucket State Transition (`bucketStateTransition` modifier), that being mint/redeem of leveraged (X) instruments. And there is also a public function to evaluate (and trigger if needed): `evalBucketLiquidation`.
For a leveraged bucket, reaching coverage liquidation point (~1) means that user's funds had absorbed all the price dropping, so this process just needs to return the borrowed value (to base bucket) and dissolve the position.

## Commission splitting

By adding the CommissionSplitter contract and set it as the destination of Money on Chain commissions (just as a normal commission destination address), the splitting process can be made.

The CommissionSplitter contract will accumulate commissions until the `split()` function is called. At that moment a part of the commissions will be added to Money on Chain reserves using the Collateral Injection functionality and the other part will be sent to a final destination address.

## Collateral injection

Collateral injection is the operation of adding reserveTokens to the system's reserves without minting RiskPro. This come in handy when reserves are running low and there is a need of Stable token minting.

This injection is made by sending funds directly to the main MoC Contract, this will result in executing the fallback function which will update the internal values according to the sent value.
