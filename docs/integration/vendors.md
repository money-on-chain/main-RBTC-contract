# Vendors

Vendors are third parties who want to integrate their platform with the MoC ecosystem. Vendors can charge a markup of up to 1% of the value to mint/redeem operations, and receive this value as MoC tokens. These tokens neither receive rewards nor vote nor can they participate as an oracle or as no other function that MoC stakeholders have in the Staking Machine.

## Registration

Please contact the [Money on Chain team](https://moneyonchain.com/) if you wish to be registered as a vendor.

## Staking

Upon registration, vendors must add stake using the function `addStake(uint256 staking)` defined in the [MoCVendors contract ABI interface](../abis/MoCVendors.md#addstake). This allows the vendor to receive the profits in MoC token when an user perform a mint/redeem operation through vendor's integration.

A vendor can change the amount of stake in the system using the function `removeStake(uint256 staking)` defined in the [MoCVendors contract ABI interface](../abis/MoCVendors.md#removestake).

## Unregistration

Please contact the [Money on Chain team](https://moneyonchain.com/) if you wish to be unregistered as a vendor.

Note that once a vendor is unregistered, they will not receive any more profits.

## Markup

When a vendor decides to integrate their platform with the MoC ecosystem, they must be [registered](#vendor-registration) first. Then, they will receive a markup for every transaction they are involved in (denoted by the parameter **vendorAccount**).

If the user who makes the transaction has balance and allowance of MoC token, this markup will be charged in MoC; otherwise it will be charged in RBTC. The exact percentage of the markup cannot be more than 1%. This is set in the **vendors** mapping of the **MoCVendors** contract (the vendor account address is the key), and the value to check is **markup**.

Note that the markup has also a precision of 18 decimals, i.e. a 1 \* 10^15 in that parameter means that 0.1% is being charged as a commission.
