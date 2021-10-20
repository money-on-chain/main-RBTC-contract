# Vendors

Vendors are third parties who want to integrate their platform with the MoC ecosystem. Vendors can charge a markup of up to 1% of the value to mint/redeem operations, 
and receive this value as MoC tokens. These tokens neither receive rewards nor vote nor can they participate as an oracle or as no other function that MoC stakeholders have in the Staking Machine.

## Registration

Please contact the [Money on Chain team](https://moneyonchain.com/) if you wish to be registered as a vendor.

**Register a vendor in money on chain requires**:

* Address of the account where markup commissions are going to be transferred.
* Markup in %. Ex: 0.05%. (Limit: 0.00001 - 1%)

## Unregistration

Please contact the [Money on Chain team](https://moneyonchain.com/) if you wish to be unregistered as a vendor.

Note that once a vendor is unregistered, they will not receive any more profits.

## Markup

When a vendor decides to integrate their platform with the MoC ecosystem, they must be [registered](#vendor-registration) first. 
Then, they will receive a markup for every transaction they are involved in (denoted by the parameter **[vendorAccount](minting-bitpros.md)**).

If the user who makes the transaction has balance and allowance of MoC token, this markup will be charged in MoC; otherwise it will be charged in RBTC. 
The exact percentage of the markup cannot be more than 1%. This is set in the **vendors** mapping of the **MoCVendors** contract 
(the vendor account address is the key), and the value to check is **markup**.

Note that the markup has also a precision of 18 decimals, i.e. a 1 \* 10^15 in that parameter means that 0.1% is being charged as a commission.


### Base commissions and markup in money on chain webapp:

**Base commission**

* Pay in RBTC: 0.1%
* Pay in MOC: 0.05%

**Markup**

* Webapp of Money on chain is a vendor
* Markup is 0.05%.
* Markup in RBTC: 0.05%
* Markup in MOC: 0.05%
* Final Commission in RBTC: 0.1% + 0.05% = 0.15%
* Final Commission in MOC: 0.05% + 0.05% = 0.10%



### Moc Vendors

Contract that manage vendors functions.

[MoCVendors contract ABI interface](../abis/MoCVendors.md). 

| Environment | Contract | Contract address |
| --- | --- | --- |
| Testnet | MoCVendors | 0x84b895A1b7be8fAc64d43757479281Bf0b5E3719 |
| Mainnet | MoCVendors | 0x2d442aA5D391475b6Af3ad361eA3b9818fb35BcA |

#### Allowance

Before start operations with MoCVendor we need to allow to MoCVendors.sol and MoC.sol using MoC Token. The approval 
transaction is used to grant permission for the smart contract to transfer a certain amount of the token, called allowance. 

**Moc Token**

| Environment | Contract | Contract address |
| --- | --- | --- |
| Testnet | MoCToken | 0x45A97b54021A3F99827641AFE1bFae574431E6ab |
| Mainnet | MoCToken | 0x9aC7Fe28967b30e3a4E6E03286D715B42B453d10 |


The functions that interest us are the following:


**Approve (tx)** involve contract address and amount of token to allow

```js
function approve(address _contract, uint256 _amount) public returns (bool success)
```

**Allowance (call)** function return remaining amount of token amount

```
function allowance(address _owner, address _contract) public view returns (uint256 remaining)
```

Example Call approve:

| Environment | Contract to allow | Address                                    | Amount in wei          |
| ---         | ---               | ---                                        | ---                    |
| Testnet     | MoC.sol           | 0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F | 1000000000000000000000 |
| Testnet     | MoCVendors.sol    | 0x84b895A1b7be8fAc64d43757479281Bf0b5E3719 | 1000000000000000000000 |
| Mainnet     | MoC.sol           | 0xf773B590aF754D597770937Fa8ea7AbDf2668370 | 1000000000000000000000 |
| Mainnet     | MoCVendors.sol    | 0x2d442aA5D391475b6Af3ad361eA3b9818fb35BcA | 1000000000000000000000 |

The **approve** transaction is part of the ERC-20 standard and you can find more information [here](https://eips.ethereum.org/EIPS/eip-20).


## Staking and MoC Vendors

Upon registration, vendors must add stake using the function `addStake(uint256 staking)` defined in the [MoCVendors contract ABI interface](../abis/MoCVendors.md#addstake). 
This allows the vendor to receive the profits in MoC token when an user perform a mint/redeem operation through vendor's integration.

A vendor can change the amount of stake in the system using the function `removeStake(uint256 staking)` defined in the [MoCVendors contract ABI interface](../abis/MoCVendors.md#removestake).

If no Moc Token staked, there is not going to transfer commission markup to vendors account. 

To transfer markup to vendors account also need:

`Moc Staked > getTotalPaidInMoC`

After settlement (30 days) the counted Paid in MoC will be reseted to 0 (getTotalPaidInMoC).

**Add stake**  

Allows an active vendor (msg.sender) to add staking

[MoCVendors contract ABI interface](../abis/MoCVendors.md#addstake)

```
/**
    @dev Allows an active vendor (msg.sender) to add staking
    @param staking Staking the vendor wants to add
  */
  function addStake(uint256 staking) public onlyActiveVendor() {
   ...
  }
```

**Remove stake**

Allows an active vendor (msg.sender) to remove staking

[MoCVendors contract ABI interface](../abis/MoCVendors.md#removestake)

```
/**
    @dev Allows an active vendor (msg.sender) to remove staking
    @param staking Staking the vendor wants to remove
  */
  function removeStake(uint256 staking) public onlyActiveVendor() {
    ...
  }
```

**Vendor is active**

Gets if a vendor is active

[MoCVendors contract ABI interface](../abis/MoCVendors.md#getisactive)

```
/**
    @dev Gets if a vendor is active
    @param account Vendor address
    @return true if vendor is active; false otherwise
  */
  function getIsActive(address account) public view
  returns (bool) {

  }
```  

**Vendor markup**

Gets vendor markup

[MoCVendors contract ABI interface](../abis/MoCVendors.md#getmarkup)

```
  /**
    @dev Gets vendor markup
    @param account Vendor address
    @return Vendor markup
  */
  function getMarkup(address account) public view
  returns (uint256) {
    return vendors[account].markup;
  }
```

**Total Paid in MoC**

Gets vendor total paid in MoC

[MoCVendors contract ABI interface](../abis/MoCVendors.md#gettotalpaidinmoC)

```
  /**
    @dev Gets vendor total paid in MoC
    @param account Vendor address
    @return Vendor total paid in MoC
  */
  function getTotalPaidInMoC(address account) public view
  returns (uint256) {
    return vendors[account].totalPaidInMoC;
  }
```

**Vendor staking**

Gets vendor staking


[MoCVendors contract ABI interface](../abis/MoCVendors.md#getstaking)

```
  /**
    @dev Gets vendor staking
    @param account Vendor address
    @return Vendor staking
  */
  function getStaking(address account) public view
  returns (uint256) {
    return vendors[account].staking;
  }
```


## Integrating Vendors on operations

To integrate vendors in mint, redeem , etc please take a look to:

* [MoC Minting BitPro](minting-bitpros.md)
* [MoC Minting BTCx](minting-btc2x.md)
* [MoC Minting DoC](minting-docs.md)
* [MoC Redeeming BitPro](redeeming-bitpros.md)
* [MoC Redeeming BTCx](redeeming-btc2x.md)
* [MoC Redeeming DoC](redeeming-docs.md)