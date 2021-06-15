# Redeeming BitPros

The Money On Chain's Smart Contract suite is in control of the redeeming of its tokens, including the BitPro token. This means that the return of BitPros is controlled programmatically by said suite. ​A user can "sell" their BitPro back to the contract and recover the corresponding amount of RBTC.

This means that to redeem BitPros you must interact with the suite. The entry point are the same as explained in [Minting BitPros](minting-bitpros.md).

In this tutorial the method (or function) that is of interest to us is `function redeemBProVendors(uint256 bproAmount, address vendorAccount) public`

NOTE: there is a retrocompatibility function called `function redeemBPro(uint256 btcToMint)` which is suitable for those who are already integrated to MoC platform and are not ready to use vendor functionality. In the future we are planning to deprecate this method.

## Parameters of the operation

### The bproAmount parameter

It is the amount that the contract will use to redeem BitPros and to calculate commissions. All of these funds will be transformed exclusively into RBTC.

This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and is defined in **MoCLibConnection** contract.


Money on Chain is a dynamic system that allows you to redeem a maximum amount of BitPros and can be obtained by calling the `absoluteMaxBPro()` view of the **MocState** contract.

The redeeming process is divided into 4 parts:

The first part transforms the amount **bproAmount** into an RBTC amount, but 2 things can happen:

- The amount entered in bproAmount must not exceed the user's balance in BPROs. If this occurs then the user’s balance will be used to calculate the value in RBTC.

```
userBalance = bproToken.balanceOf(user);
userAmount  = Math.min(bproAmount, userBalance);
```

- The userAmount must not exceed the absolute maximum amount of allowed BitPros. If this occurs then absoluteMaxBPro will be used to transform it to RBTC.

```
bproFinalAmount = Math.min(userAmount, absoluteMaxBPro);
```

The second part will be used to pay the commission, this part is a percentage of the previous part. The commission fees are explained in [this](commission-fees-values.md) section.

The third part corresponds to the vendor markup, which refers to the fee a vendor will receive from this transaction and is a percentage of the first part. The vendor markup is explained in [this](vendors.md#markup) section.

The fourth part returns the amount in RBTC discounting the previously calculated fees.

All the needed calculations for the second and third parts are explained in more detail [here](fees-calculation.md).

### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some BitPros.

## Possible failures

This operation may fail if one of the following scenarios occurs:

### The contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more BitPros will be available for redeeming. The condition is the same as that explained in [The MoC contract is liquidated](minting-bitpros.md#the-moc-contract-is-liquidated).

### The contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. The condition is the same as that explained in [The MoC contract is paused](minting-bitpros.md#the-moc-contract-is-paused).

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

​To run a local blockchain you can use

```
npm run ganache-cli
```

To deploy the contracts you can use

```
npm run deploy-reset-development
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
And redeem some BPros:

```js
uint256 bproAmount = 9000000;
moc.redeemBProVendors(bproAmount, vendorAccount);
```

You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following
​​

```js
pragma solidity ^0.5.8;
​
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/token/BProToken.sol";
// Here you will import your own dependencies

contract YourRedeemingBproContract {
    // Address of the MoC contract
    MoC public moc;
    // Address of the bitpro token
    BProToken public bpro;
    // Address that will receive all the commissions
    address public receiverAddress;
    // Address that will receive the markup
    address public vendorAccount;
    // rest of your variables
​
    constructor (MoC _moc, address _receiverAddress, address _vendorAccount) public {
        moc = _moc;
        receiverAddress = _receiverAddress;
        vendorAccount = _vendorAccount;
        // You could have more variables to initialize here
    }
​
    function doTask(uint256 _bproAmount) public {
        uint256 previousBalance = bpro.balanceOf(receiverAddress);
        moc.redeemBProVendors(_bproAmount, vendorAccount);
        uint256 newBalance = bpro.balanceOf(receiverAddress);
    }
    // rest of your contract
}​
```

And that is it, the only thing left to do is to add in the [Truffle migrations](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations) scripts the address to MoC and BPro when deploying YourRedeemingBproContract and you are done.
​​