# Redeeming DOCs on Settlement: redeemDocRequest

`function redeemDocRequest(uint256 docAmount) public`

There is only one redeem request per user during a settlement. A new reedeem request is created if the user invokes it for the first time or has its value updated if it already exists.

## Parameters of the operation

### The docAmount parameter

It is the amount that the contract will use to create or update a DOCs redeem request.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and can be greater than user's balance at request time, allowing to, for example, redeem all future user's DoCs.

### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some DOCs.

## Possible failures

This operation may fail if one of the following scenarios occurs:

### The contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. The condition is the same as that explained in [The MoC contract is paused](minting-docs.md#the-moc-contract-is-paused).

### Settlement is not ready:

The function can only be invoked when the Settlement is finished executing. If called during execution, the transaction reverts with the error message: _Function can only be called when settlement is ready_.

### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert (again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

### Not active redeemer:

When a user tries to update a reedem request, but the system can not find its address as an active user for the current settlement. It is a very rare condition in which a transaction reverts with the error message: _This is not an active redeemer_.
If this situation occurs then you can contact the [Money on Chain team](https://moneyonchain.com/) to help you.

### Not allowed redeemer:

When a user tries to update a reedem request and the system found its address as an active user but redeem request has a different address in the current settlement. It is a very rare condition in which a transaction reverts with the error message: _Not allowed redeemer_.
If this situation occurs then you can contact the [Money on Chain team](https://moneyonchain.com/) to help you.

## Commissions

The redeemDocRequest operation has no commissions, but when the settlement runs, the total requested amount to redeem will pay commissions. This fee will be the same as the `REDEEM_DOC_FEES_RBTC` value. The commission fees are explained in [this](commission-fees-values.md) section.
