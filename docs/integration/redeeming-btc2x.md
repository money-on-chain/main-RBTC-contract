# Redeeming BTCx

The Money On Chain's Smart Contract suite is in control of redeeming its tokens, including the BTCx token. This means that the return of BTCx is controlled programmatically by said suite. ​A user can "sell" their BTCx back to the contract and have RBTC deposited are sent back to the user, alongside the refunded interests (waiting in inrateBag) for the remaining time until the settlement (not yet charged).

In this tutorial the method (or function) that is of interest to us is `function redeemBProxVendors(bytes32 bucket, uint256 bproxAmount, address vendorAccount) public`

NOTE: there is a retrocompatibility function called `function redeemBProx(bytes32 bucket, uint256 bproxAmount)` which is suitable for those who are already integrated to MoC platform and are not ready to use vendor functionality. In the future we are planning to deprecate this method.

## Parameters of the operation

### The bucket parameter

A bucket is a bag that stores the balances of the leveraged token holders. Currently, only the BTCx bucket called _X2_ exists. The X2 must be passed as an hex value.

There is also a bucket named _C0_ but it should not be used to mint and redeem BTCx.

In the following example you can see how to do it with javascript and the web3 library. For more detailed information about web3 you can read the [From outside the blockchain](from-outside-the-blockchain.md) section.

```js
const BUCKET_X2 = web3.utils.asciiToHex('X2', 32);
```

### The bproxAmount parameter

It is the amount that the contract will use to redeem BTCx and will be used to calculate commissions. All of these funds will be transformed exclusively into RBTC.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and is defined in **MoCLibConnection** contract.

### The vendorAccount parameter

It is the address of the vendor who will receive a [markup](vendors.md#markup) from the current transaction.


The redeeming process is divided into 5 parts:

The first part transforms the amount **bproxAmount** into an RBTC amount, but 2 things can happen:

- The amount entered in bproAmount must not exceed the user's balance in BPROs. If this occurs then the user’s balance will be used to calculate the value in RBTC.

```js
userBalance = bproxBalanceOf(bucket, user);
bproxToRedeem = Math.min(bproxAmount, userBalance);
rbtcToRedeem = bproxToBtc(bproxToRedeem, bucket);
```

The second part computes interests to be paid to the user.

The third part will be used to pay the commission, this part is a percentage of the first part. The commission fees are explained in [this](commission-fees-values.md) section.

The fourth part corresponds to the vendor markup, which refers to the fee a vendor will receive from this transaction and is a percentage of the first part. The vendor markup is explained in [this](vendors.md#markup) section.

The fifth part returns the amount in RBTC adding the computed interest and discounting the previously calculated commissions (if paid in RBTC).

All the needed calculations for the third and fourth parts are explained in more detail [here](fees-calculation.md).

### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some BTCx.

## Possible failures

This operation may fail if one of the following scenarios occurs:

### The MoC contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more BTCx will be available for redeeming.
To know if the contract is liquidated you can ask the **MocState** for the **state**, this will return a 0 if liquidated (it is actually an enum).

### The MoC contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. You can get more information about stoppable contracts [here](https://github.com/money-on-chain/Areopagus-Governance/blob/develop/contracts/Stopper/Stoppable.sol). In that state, the contract doesn't allow minting any type of token.

To know if this is the case you can ask to **MoC** if it's **paused()**.

### Settlement is not ready:

The function can only be invoked when the Settlement has finished executing. If called during execution, the transaction reverts with the error message: _Function can only be called when settlement is ready_.

### Bucket is not available:

Currently, only the BTCx bucket called 'X2' exists. If it is called with another bucket, the transaction reverts with the error message: _Bucket is not available_.

### Bucket is not a base bucket:

Currently, only the BTCx bucket called 'X2' exists. If you call the function with _C0_ bucket, the transaction reverts with the error message: _Bucket should not be a base type bucket_.

### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert (again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

## How-to

In the following sections we will give some code on how this can be done through a Smart Contract or directly, with a console or with an app.
​

### Smart Contract​

​
To create a new Smart Contract that uses the Money On Chain platform, you can use any language and IDE you want. In this tutorial, we will show you how to do it using [Solidity language](https://solidity.readthedocs.io/en/v0.5.8/), [Truffle Framework](https://www.trufflesuite.com/) and [NPM](https://www.npmjs.com/).
Truffle framework offers some template projects that you can use to develop applications that use smart contracts. You can get more information [here](https://www.trufflesuite.com/boxes).
Assuming you already have your project up and running (if you don't, please follow [this link](../rationale/getting-started.md)) the only extra thing you need to do is to install our repo as a dependency in your NPM project. In order you need to do this you just need to run the following command.
​

```
npm install --save -E git+https://git@github.com/money-on-chain/main-RBTC-contract.git
```

Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some BitPros. The good news is that you can do this instantly just by minting them. The code necessary to do this is actually pretty simple.
​
You just have to import the contract
​

```js
import 'money-on-chain/contracts/MoC.sol';
```

Receive the address in the constructor in order to be able to interact with it later, and the vendorAccount address needed to do the operation

```js
constructor (MoC _mocContract, address vendorAccount, rest of your params...) {
//....rest of your constructor....
}
```

​and, finally, redeem some BTCx for RBTCs
​

```js
uint256 bproxAmountToRedeem = 2;
bytes32 constant public BUCKET_X2 = "X2";
moc.redeemBProxVendors(BUCKET_X2, bproxAmountToRedeem, vendorAccount);
```
​
You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before

This will leave you with a contract similar to the following
​
​

```js
pragma solidity ^0.5.8;
​
import "money-on-chain/contracts/MoC.sol";
// Here you will import your own dependencies
​
contract YourRedeemingBtc2xContract {
    // Address of the MoC contract
    MoC public moc;
    // Define a constant to call bucket X2
​    bytes32 constant public BUCKET_X2 = "X2";
    // Address that will receive the markup
    address public vendorAccount;
    // rest of your variables

    constructor (MoC _moc, address _vendorAccount) public {
        moc = _moc;
        vendorAccount = _vendorAccount;
        // You could have more variables to initialize here
    }
​
    function doTask(uint256 _bproxAmount) public {
        uint256 prevRbtcBalance = moc.bproxBalanceOf(BUCKET_X2, msg.sender);
        // Mint some new BTCx
        moc.redeemBProxVendors(BUCKET_X2, _bproxAmount, vendorAccount);
        uint256 newRbtcBalance = moc.bproxBalanceOf(BUCKET_X2, msg.sender);
        // Rest of the function to actually perform the task
    }
    // rest of your contract
}
```
