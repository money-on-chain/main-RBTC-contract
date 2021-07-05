# Fees calculation

Fees (namely, commission and vendor markup) are a percentage of the amount of the transaction that will be charged for the usage of the platform. The sum of the commission and vendor markup will be at around 0.1% of the amount.

The calculation for the fees associated with the transaction is managed in the function **calculateCommissionsWithPrices** of the **MoCExchange** contract.

This function deals with all the parameters needed to calculate said fees. You will need to pass these parameters in the form of the **CommissionParamsStruct** struct:
```
struct CommissionParamsStruct{
  address account; // Address of the user doing the transaction
  uint256 amount; // Amount from which commissions are calculated
  uint8 txTypeFeesMOC; // Transaction type if fees are paid in MoC
  uint8 txTypeFeesRBTC; // Transaction type if fees are paid in RBTC
  address vendorAccount; // Vendor address
}
```
You must assign all the parameters to the struct before calling the function. Transaction types for every operation are explained [here](commission-fees-values.md). You must have an instance of the **MoCInrate** contract in order to access every valid transaction type.

Fees will be paid in MoC in case the user has MoC token balance and allowance; otherwise they will be paid in RBTC.

You will receive a **CommissionReturnStruct** struct in return with all the values calculated for you:
```
struct CommissionReturnStruct{
  uint256 btcCommission; // Commission in BTC if it is charged in BTC; otherwise 0
  uint256 mocCommission; // Commission in MoC if it is charged in MoC; otherwise 0
  uint256 btcPrice; // BTC price at the moment of the transaction
  uint256 mocPrice; // MoC price at the moment of the transaction
  uint256 btcMarkup; // Markup in BTC if it is charged in BTC; otherwise 0
  uint256 mocMarkup; // Markup in MoC if it is charged in BTC; otherwise 0
}
```

In conclusion:

- If you are minting and fees are paid in RBTC, the amount sent to the transaction has to be at least the amount in BTC desired plus the commission (amount times the commission rate) plus the markup (amount times the vendor markup). If the operation involves interests, you should add them as well.

```
btcSent (msg.value) >= CommissionParamsStruct.amount + CommissionParamsStruct.amount * CommissionReturnStruct.btcCommission + CommissionParamsStruct.amount * CommissionReturnStruct.btcMarkup + interests
```
If fees are paid in MoC, then `btcSent (msg.value) == CommissionParamsStruct.amount`

- If you are redeeming and fees are paid in RBTC, the transaction returns the amount in RBTC discounting the previously calculated fees.  If the operation involves interests, you should subtract them as well.

```
totalBtc = <token>ToBtc(finalAmount);
btcReceived = totalBtc - totalBtc * CommissionReturnStruct.btcCommission - totalBtc * CommissionReturnStruct.btcMarkup - interests
```
If fees are paid in MoC, then `btcReceived == CommissionParamsStruct.amount`
