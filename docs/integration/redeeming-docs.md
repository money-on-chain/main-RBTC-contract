# Redeeming DOCs

**Settlements** is a time based recurring process that allows or rejects the processing of DOC redeem requests. The process runs in 90 days intervals.

There are three ways to redeem DOCs:

- On settlement: A DoC redeem request can be created to redeem any amount of DoCs, but this will be processed on the next settlement. The amount can be greater than the user's balance at request time, allowing to, for example, redeem all future user's DoCs regardless of whether their balance increases. The functions that interests us are: `function redeemDocRequest(uint256 docAmount) public` and `function alterRedeemRequestAmount(bool isAddition, uint256 delta) public`

- Outside of settlement: Only free DoCs can be redeemed outside of the settlement. Free DoCs are those that were not transferred to another to provide leverage. The function that interests us is: `function redeemFreeDocVendors(uint256 docAmount, address vendorAccount) public`.

NOTE: there is a retrocompatibility function called `redeemFreeDoc(uint256 docAmount)` which is suitable for those who are already integrated to MoC platform and are not ready to use vendor functionality. In the future we are planning to deprecate this method.

- On Liquidation State: The user can redeem all his DoCs with the method: `function redeemAllDoc() public`
