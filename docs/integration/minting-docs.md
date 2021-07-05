# Minting DOCs

DOC can only be minted in exchange for RBTC. Given an amount of RBTC paid to the contract, the system calculates the corresponding DOCs amount to mint, RBTC and DOC balances are added to the Money on Chain system and the new tokens are sent to the user.

In this tutorial the method (or function) that is of interest to us is `function mintDocVendors(uint256 btcToMint, address vendorAccount) public payable`. As you can see this function is payable, this means that it is prepared to receive RBTCs.

NOTE: there is a retrocompatibility function called `function mintDoc(uint256 btcToMint)` which is suitable for those who are already integrated to MoC platform and are not ready to use vendor functionality. In the future we are planning to deprecate this method.

## Parameters of the operation

### The btcToMint parameter

It is the amount the contract will use to actually mint DOCs, i.e. it will not be used to pay commission, all of this funds will be transformed purely on DOCs.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and is defined in **MoCLibConnection** contract.
It could be the case, depending on the state of the contract, that a value less than btcToMint will be used to mint the DOCs. In that case, all the extra RBTCs will be sent to you.

### The vendorAccount parameter

It is the address of the vendor who will receive a [markup](vendors.md#markup) from the current transaction.

### The value sent

The amount sent in RBTCs to the contract can be considered as a parameter of the transaction, which is why it will be explained in this section. You have to take into consideration that it will be split in four.

- The first part will be used to mint some DOC, the size of this part depends directly on the **btcToMint**. For security reasons, the system allows to mint a maximum amount of DOCs that can be obtained by invoking the `absoluteMaxDoc()` function of the **MoCState** contract.
- The second part will be used to pay the commission, this part is a percentage of the previous part. The commission fees are explained in [this](commission-fees-values.md) section.
- The third part corresponds to the vendor markup, which refers to the fee a vendor will receive from this transaction and is a percentage of the first part. The vendor markup is explained in [this](vendors.md#markup) section.
- The fourth part is always returned, so if you have doubts of how much you should send, keep in mind that if you send too much RBTCs we will return everything that it is not used for commissions or minting.

All the needed calculations for the second and third parts are explained in more detail [here](fees-calculation.md).


### Gas limit and gas price

This two values are a parameter of the transaction, which are not used in the contract and are usually managed by your wallet (you should read about them if you are developing and you don't know exactly what are they), but you should take them into account when trying to send all of your funds to mint some DOCs.

## Possible failures

This operation may fail if one of the following scenarios occurs:

### The MoC contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more DOCs will be available for minting.
To know if the contract is liquidated you can ask the **MocState** for the **state**, this will return a 0 if liquidated (it is actually an enum).

### The MoC contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. You can get more information about stoppable contracts [here](https://github.com/money-on-chain/Areopagus-Governance/blob/develop/contracts/Stopper/Stoppable.sol). In that state, the contract doesn't allow minting any type of token.

To know if this is the case you can ask to **MoC** if it's **paused()**.

### You sent too few funds:

If the funds you sent doesn't cover the amount you specified on btcToMint.

If this is the case the transaction will revert, all your funds will be returned (except the fee paid to the network). The error message will be "amount is not enough".

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

Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some DOCs. The good news is that you can do this instantly just by minting them. The code necessary to do this is actually pretty simple.
​
You just have to import the contracts
​

```js
import 'money-on-chain/contracts/MoC.sol';
import 'money-on-chain/contracts/MoCInrate.sol';
import 'money-on-chain/contracts/MoCExchange.sol';
```

Receive the addresses in the constructor in order to be able to interact with it later, and the vendorAccount address needed to do the operation

```js
constructor (MoC _mocContract, MoCInrate _mocInrateContract, MoCExchange _mocExchangeContract, address vendorAccount, rest of your params...) {
//....rest of your constructor....
}
```

​and, finally, when you receive a commission, exchange it for some DoCs
​

```js
// Calculate operation fees
CommissionParamsStruct memory params;
params.account = '<address_of_minter>';
params.amount = btcAmount; // BTC amount you want to mint
params.txTypeFeesMOC = mocInrate.MINT_DOC_FEES_MOC();
params.txTypeFeesRBTC = mocInrate.MINT_DOC_FEES_RBTC();
params.vendorAccount = vendorAccount;

CommissionReturnStruct memory commission = mocExchange.calculateCommissionsWithPrices(params);

uint256 fees = commission.btcCommission - commission.btcMarkup;
// If commission is paid in RBTC, subtract it from value
moc.mintDocVendors.value(msg.value)(msg.value - fees, vendorAccount);
```
​
You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the DoC token.
​
This will leave you with a contract similar to the following
​
​

```js
pragma solidity ^0.5.8;
​
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/token/DocToken.sol";
import 'money-on-chain/contracts/MoCInrate.sol';
import 'money-on-chain/contracts/MoCExchange.sol';
// Here you will import your own dependencies
​
contract YourMintingDocContract {
    // Address of the MoC contract
    MoC public moc;
    // Address of the MoCInrate contract
    MoCInrate public mocInrate;
    // Address of the MoCExchange contract
    MoCExchange public moCExchange;
    // Address of the doc token
    DocToken public doc;
    // Address that will receive all the commissions
    address public receiverAddress;
    // Address that will receive the markup
    address public vendorAccount;
    // rest of your variables

    constructor (MoC _mocContract, MoCInrate _mocInrateContract, MoCExchange _mocExchangeContract, DocToken _doc, address _receiverAddress, address _vendorAccount) public {
        moc = _mocContract;
        mocInrate = _mocInrateContract;
        moCExchange = _mocExchangeContract;
        doc = _doc;
        receiverAddress = _receiverAddress;
        vendorAccount = _vendorAccount;
        // You could have more variables to initialize here
    }
​
    function doTask(uint256 btcAmount) public payable {
      // Calculate operation fees
      CommissionParamsStruct memory params;
      params.account = address(this); // address of minter
      params.amount = btcAmount; // BTC amount you want to mint
      params.txTypeFeesMOC = mocInrate.MINT_DOC_FEES_MOC();
      params.txTypeFeesRBTC = mocInrate.MINT_DOC_FEES_RBTC();
      params.vendorAccount = vendorAccount;

      CommissionReturnStruct memory commission = mocExchange.calculateCommissionsWithPrices(params);
      // If commission is paid in RBTC, subtract it from value
      uint256 fees = commission.btcCommission - commission.btcMarkup;
      // Mint some new DoC
      moc.mintDocVendors.value(msg.value)(msg.value - fees, vendorAccount);
​      // Transfer it to your receiver account
      doc.transfer(receiverAddress, doc.balanceOf(address(this)));
      // Rest of the function to actually perform the task
    }
    // rest of your contract
}
```

And that is it, the only thing left to do is to add in the [Truffle migrations](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations) scripts the address to MoC and DoC when deploying YourMintingDocContract and you are done.
