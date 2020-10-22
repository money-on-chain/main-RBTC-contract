# Integration to Money on Chain Platform

1.  [Introduction to MoC](#introduction-to-moc)
    1.  [The Moc Contract](#the-moc-contract)
    1.  [MoC State Contracts](#the-moc-state-contract)
1.  [Getting BPros](#getting-bpros)
    1.  [Minting BitPros](#minting-bitpros)
    1.  [Redeeming BitPros](#redeeming-bitpros)
1.  [Getting DOCs](#getting-docs)
    1.  [Minting DOCs](#minting-docs)
    1.  [Redeeming DOCs](#redeeming-docs)
1.  [Getting BTC2X](#getting-btc2x)
    1.  [Minting BTC2X](#minting-btc2x)
    1.  [Redeeming BTC2X](#redeeming-btc2x)
1.  [Commission fees values](#commission-fees-values)
1.  [From outside the blockchain](#from-outside-of-the-blockchain)
    1.  [Using RSK nodes](#using-rsk-nodes)
    1.  [Using web3](#using-web3)
    1.  [Official Money on Chain ABIS](#official-money-on-chain-abis)
    1.  [Example code minting BPROS](#example-code-minting-bpros)

# Introduction to MoC

Money On Chain is a suite of smart contracts whose purpose is providing:

- A bitcoin-collateralized stable-coin, Dollar On Chain, (DoC)
- A passive income hodler-targeted token, BitPro (BPRO)
- A leveraged Bitcoin investment instrument (BTCX series).

The rationale behind this is that deposits of RBTC help collateralize the DoCs, BitPro absorbs the USD-BTC rate fluctuations, and BTC2X is leveraged borrowing value from BitPro and DoC holders, with a daily interest rate being paid to the former.

Note in this tutorial we will use BTC and RBTC as interchangeable terms, as there is a 1:1 peg guaranteed by the RSK network, but in all the cases we mean RBTC as this is the correct coin of the RSK token.

MoC system is a network of cooperative smart contracts working together to ultimately provide a US dollar pegged ERC20 Token (DoC). In this sense, the contracts we can categorize them into 4 categories:

- _MoC state Contracts_: They keep MoC state variables and logic (MoC, MoCState, MoCBucketContainer, MoCSettlement, MoCBurnout)
- _MoC pure logic Contracts & Libraries_: Functional extensions of the above merely to have responsibility separation and contracts size (aka deploy fee) low. (MoCHelperLib, MoCLibConnection, MoCConverter, MoCExchange, MoCConnector, MoCBProxManager, MoCInrate, MoCWhitelist, MoCBase)
- _Tokens_: Tokens backed by the system (OwnerBurnableToken, DocToken, BProToken, MoCToken)
- _External Dependencies_: External contracts the system relies on, in this case the Oracle or price provider; this could evolve independently of MoC system as along as the interface is maintained. (PriceProvider)

Also you can read official information about [MoC architecture and Money on Chain's smart contracts](https://github.com/money-on-chain/main-RBTC-contract/blob/master/MOC.md)

## The Moc Contract

The Money On Chain's Smart Contract suite is in control of the minting and redeeming of its tokens, including the BitPro, DOC and BTC2X tokens. This means that the generation of new tokens is controlled programmatically by said suite. To get some new tokens you should interact with the suite. The entry point is the MoC smart contract whose addresses are available on the following networks:

- mainnet: [ 0xf773B590aF754D597770937Fa8ea7AbDf2668370 ](https://explorer.rsk.co/address/0xf773b590af754d597770937fa8ea7abdf2668370)
- testnet: [ 0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F ](https://explorer.testnet.rsk.co/address/0x2820f6d4d199b8d8838a4b26f9917754b86a0c1f)

In the world of second and third generation blockchains it is not possible to update the code of an already deployed smart contract. If we need to fix a bug or update the logic of a function, then we can use the proxy architecture pattern.

The proxy pattern allows all function calls to go through a Proxy contract that will redirect the message to another smart contract that contains the business logic. MoC is a Proxy Contract.

When the logic needs to be updated, a new version of your business logic contract is created and the reference is updated in the proxy contract. You can read more about proxies contracts [here](https://blog.openzeppelin.com/proxy-patterns/).

### MoC precisions

The Money on Chain system handles different types of currency precision to operate with tokens and RBTC. The **MoCLibConnection** contract defines 2 variables that are used across the platform:

- _mocPrecision_: Currently DOC, BROS and BTC2X tokens use 18 decimal places of precision.
- _reservePrecision_: Currently RBTC amounts use 18 decimal places of precision.

### MoC State Contracts

#### MocInrate

Deals with interest payments on leverage deposits and defines the interest rates to trade with DOC and BTC2X. Also with the commission rates to operate on the Money on Chain platform.

- mainnet: [ 0xc0f9B54c41E3d0587Ce0F7540738d8d649b0A3F3 ](https://explorer.rsk.co/address/0xc0f9B54c41E3d0587Ce0F7540738d8d649b0A3F3)
- testnet: [ 0x76790f846FAAf44cf1B2D717d0A6c5f6f5152B60 ](https://explorer.testnet.rsk.co/address/0x76790f846FAAf44cf1B2D717d0A6c5f6f5152B60)

#### MocState

This contract holds the system variables to manage the state, whether it's the state itself or the liquidation thresholds, as well as many `view` functions to access and evaluate it.

- mainnet: [ 0xb9C42EFc8ec54490a37cA91c423F7285Fa01e257 ](https://explorer.rsk.co/address/0xb9C42EFc8ec54490a37cA91c423F7285Fa01e257)
- testnet: [ 0x0adb40132cB0ffcEf6ED81c26A1881e214100555 ](https://explorer.testnet.rsk.co/address/0x0adb40132cB0ffcEf6ED81c26A1881e214100555)

# Getting BPros

In this tutorial we will show you how to get BitPro tokens.

The BitPro, as you may already know, is an _ERC20_ token.(If you didn't, and you don't know what is exactly an _ERC20_ token [here](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) is a full explanation of it).
​
This means that most wallets like Nifty and MetaMask can handle them if you tell them to ([MetaMask tutorial on how to do it](https://metamask.zendesk.com/hc/en-us/articles/360015489031-How-to-View-Your-Tokens), Nifty is very similar to it so you should follow that link too if you are using the latter).
​
That BitPro is an _ERC20_ Token also means that any user that has already some tokens can trade them to you in exchange for a service or for another token.
​
But in some circumstances you may not find such a user (maybe they are keeping the tokens to themselves ESTO ES OPCIONAL). In those cases, you may be happy to know that you can create them(or mint them, as it is usually said) using the Smart Contracts.

## Minting BitPros

In this tutorial the method (or function) that is of interest to us is `function mintBPro(uint256 btcToMint) public payable` As you can see this function is payable, this means that it is prepared to receive RBTCs.

### Parameters of the operation

#### The btcToMint parameter

It is the amount the contract will use to actually mint BitPros, i.e. it will not be used to pay commission, all of this funds will be transformed purely on BitPros.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places is defined in **MoCLibConnection** contract.
Maybe, depending on the state of the contract, a value lesser than btcToMint will be used to mint the BitPros. In that case, all the extra RBTCs will be sent to you.

#### The value sent

The amount sent in RBTCs to the contract can be considered as a parameter of the transaction, which is why it will be explained in this section. You have to take into consideration that it will be split in three.
The first part will be used to mint some BitPro, the size of this part depends directly on the btcToMint, and, as explained in the previous section, it may be smaller than btcToMint.

The second part will be used to pay the commission, this part is a percentage of the previous part. The commission fees are explained in [this](#commission-fees-values) section.

The third part is always returned, so if you have doubts of how much you should send, keep in mind that if you send too much RBTCs we will return everything that it is not used for commissions or minting.
In conclusion the amount sent has to be at least the btcToMint plus the commission (if paid in RBTC), the commission being btcToMint times the commission rate.

```
btcSent (msg.value) >= btcToMint + btcToMint * commissionRateInRbtc
```

#### Gas limit and gas price

This two values are a parameter of the transaction, this is not used in the contract and it is usually managed by your wallet(you should read about them if you are developing and you don't know exactly what are they) but you should take them into account when trying to send all of your funds to mint some BitPros.

### Possible failures

This operation may fail if one of the following scenarios occurs:

#### The MoC contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more BitPros will be available for minting.
To know if the contract is liquidated you can ask the **MocState** for the **state**, this will return a 0 if liquidated(it is actually an enum).

#### The MoC contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. You can get more information about stoppables contracts [here](https://github.com/money-on-chain/Areopagus-Governance/blob/develop/contracts/Stopper/Stoppable.sol)
In that state, the contract doesn't allow minting any type of token.

To know if this is the case you can ask to **MoC** if it's **paused()**.

#### You sent too few funds:

If the funds you sent doesn't cover the amount you specified on btcToMint.

If this is the case the transaction will revert, all your funds will be returned (except the fee paid to the network). The error message will be "amount is not enough".

#### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

### How-to

In the following sections we will give some code on how this can be done through a Smart Contract or directly, with a console or with an app.
​

#### Smart Contract​

​
To create a new Smart Contract that uses the Money On Chain platform, you can use any language and IDE you want. In this tutorial, we will show you how to do it using [Solidity language](https://solidity.readthedocs.io/en/v0.5.8/), [Truffle Framework](https://www.trufflesuite.com/) and [NPM](https://www.npmjs.com/).
Truffle framework offers some template projects that you can use to develop applications that use smart contracts. You can get more information [here](https://www.trufflesuite.com/boxes).
Assuming you already have your project up and running (if you don't, please follow [this link](https://github.com/money-on-chain/main-RBTC-contract/blob/master/README.md)) the only extra thing you need to do is to install our repo as a dependency in your NPM project. In order you need to do this you just need to run the following command.
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

​
Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some BitPros. The good news is that you can do this instantly just by minting them. The code necessary to do this is actually pretty simple.
​
You just have to import the contract
​

```js
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
```

Receive the address in the constructor in order to be able to interact with it later

```js
constructor (MoC _mocContract, MoCInrate _mocInrateContract, rest of your params...) {
//....rest of your constructor....
}
```

​and, finally, when you receive a commission, exchange it for some BitPros
​

```js
uint8 transactionType = mocInrate.MINT_BPRO_FEES_RBTC(); // or mocInrate.MINT_BPRO_FEES_MOC();
uint256 commissionOfMoC = mocInrate.calcCommissionValue(msg.value, transactionType);
// If commission is paid in RBTC, substract it from value
moc.mintBPro.value(msg.value)(msg.value-commissionOfMoC);
```

​
You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following
​
​

```js
pragma solidity 0.5.8;
​
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
import "money-on-chain/contracts/token/BProToken.sol";
// Here you will import your own dependencies
​
contract YourMintingBproContract {
    // Address of the MoC contract
    MoC public moc;
    // Address of the MocInrate contract
    MoCInrate public mocInrate;
    // Address of the bitpro token
    BProToken public bpro;
    // Address that will receive all the commissions
    address public receiverAddress;
    // rest of your variables
​
    constructor (MoC _moc, MoCInrate _mocInrate, BProToken _bpro, address _receiverAddress) public {
        moc = _moc;
        mocInrate = _mocInrate;
        bpro = _bpro;
        receiverAddress = _receiverAddress;
        // You could have more variables to initialize here
    }
​
    function doTask() public payable {
        //We set transaction type according to the way fees are paid
        uint8 transactionType = mocInrate.MINT_BPRO_FEES_RBTC(); // or mocInrate.MINT_BPRO_FEES_MOC();
        //We compute the commision.
​        uint256 commission = mocInrate.calcCommissionValue(msg.value, transactionType);
        //We compute the btcToMint. If commission is paid in RBTC, substract it from value
        uint256 btcToMint = msg.value - commission;
        // Mint some new BitPro
        moc.mintBPro.value(msg.value)(btcToMint);
​        // Transfer it to your receiver account
        bpro.transfer(receiverAddress, bpro.balanceOf(address(this)));
        // Rest of the function to actually perform the task
    }
    // rest of your contract
}
```

And that is it, the only thing left to do is to add in the [truffle migrations](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations) scripts the address to MoC and BPro when deploying YourContract and you are done.
​​

## Redeeming BitPros

The Money On Chain's Smart Contract suite is in control of the redeeming of its tokens, including the BitPro token. This means that the return of BitPros is controlled programmatically by said suite. ​A user can "sell" their BitPro back to the contract and recover the corresponding amount of RBTC.

This means that to redeem BitPros you must interact with the suite. The entry point are the same as explained in [Minting BitPros](#minting-BitPros).

In this tutorial the method(or function) that is of interest to us is `function redeemBPro(uint256 bproAmount) public`.

### Parameters of the operation

#### The bproAmount parameter

It is the amount that the contract will use to redeem BitPros and to calculate commissions. All of these funds will be transformed exclusively into RBTC.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and is defined in **MoCLibConnection** contract.
Money on Chain is a dynamic system that allows you to redeem a maximum amount of BitPros and can be obtained by calling the `absoluteMaxBPro()` view of the **MocState** contract.

The redeeming process is divided into 3 parts:
The first part transforms the amount **bproAmount** into an RBTC amount, but 3 things can happen:

- The amount entered in bproAmount must not exceed the user's balance in BPROs. If this occurs then the user’s balance will be used to calculate the value in RBTC.

```
userBalance = bproToken.balanceOf(user);
userAmount  = Math.min(bproAmount, userBalance);
```

- The userAmount must not exceed the absolute maximum amount of allowed BitPros. If this occurs then absoluteMaxBPro will be used to transform it to RBTC.

```
bproFinalAmount = Math.min(userAmount, absoluteMaxBPro);
```

The second part will be used to pay the commission, this part is a percentage of the previous part. The commission fees are explained in [this](#commission-fees-values) section.

The third part returns the amount in RBTC discounting the previously calculated commissions.

```
totalBtc = bproToBtc(bproFinalAmount);
btcReceived = totalBtc - totalBtc * commissionRateInRbtc
```

#### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some BitPros.

### Possible failures

This operation may fail if one of the following scenarios occurs:

#### The contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more BitPros will be available for redeeming. The condition is the same as that explained in [The MoC contract is liquidated](#the-MoC-contract-is-liquidated).

#### The contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. The condition is the same as that explained in [The MoC contract is paused](#the-MoC-contract-is-paused).

#### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

### How-to

In the following sections we will give some code on how this can be done through a Smart Contract or directly, with a console or with an app.
​

#### Smart Contract​

​
To create a new Smart Contract that uses the Money On Chain platform, you can use any language and IDE you want. In this tutorial, we will show you how to do it using [Solidity language](https://solidity.readthedocs.io/en/v0.5.8/), [Truffle Framework](https://www.trufflesuite.com/) and [NPM](https://www.npmjs.com/).
Truffle framework offers some template projects that you can use to develop applications that use smart contracts. You can get more information [here](https://www.trufflesuite.com/boxes).
Assuming you already have your project up and running (if you don't, please follow [this link](https://github.com/money-on-chain/main-RBTC-contract/blob/master/README.md)) the only extra thing you need to do is to install our repo as a dependency in your NPM project. In order you need to do this you just need to run the following command.
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

​
Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some BitPros. The good news is that you can do this instantly just by minting them. The code necessary to do this is actually pretty simple.
​
You just have to import the contract
​

```js
import "money-on-chain/contracts/MoC.sol";
```

Receive the address in the constructor in order to be able to interact with it later

```js
constructor (MoC _mocContract, MoCInrate _mocInrateContract, rest of your params...) {
//....rest of your constructor....
}
​
```

```js
uint256 bproAmountInWei = 9000000;
moc.redeemBPro(bproAmountInWei);
```

​
You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following

```js
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
```

Receive the address in the constructor in order to be able to interact with it later

```js
constructor (MoC _mocContract, MoCInrate _mocInrateContract, rest of your params...) {
//....rest of your constructor....
}
```

You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following
​​

```js
pragma solidity 0.5.8;
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
    // rest of your variables
​
    constructor (MoC _moc, address _receiverAddress) public {
        moc = _moc;
        receiverAddress = _receiverAddress;
        // You could have more variables to initialize here
    }
​
    function doTask(uint256 _bproAmount) public {
        uint256 previousBalance = bpro.balanceOf(receiverAddress);
        moc.redeemBPro(_bproAmount);
        uint256 newBalance = bpro.balanceOf(receiverAddress);
    }
    // rest of your contract
}​
```

And that is it, the only thing left to do is to add in the [truffle migrations](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations) scripts the address to MoC and BPro when deploying YourContract and you are done.
​​

# Getting DOCs

A DOC, Dollar On Chain, is a bitcoin-collateralized stable-coin. Its value is pegged to one dollar.

That DOC is an _ERC20_ Token means that any user that has already some tokens can trade them to you in exchange for a service or for another token. You can find specific information about ERC-20 tokens [here](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md).

## Minting DOCs

DOC can only be minted in exchange for RBTC. Given an amount of RBTC paid to the contract, the system calculates the corresponding DOCs amount to mint, RBTC and DOC balances are added to the Money on Chain system and the new tokens are sent to the user.

In this tutorial the method(or function) that is of interest to us is `function mintDoc(uint256 btcToMint) public payable` As you can see this function is payable, this means that it is prepared to receive RBTCs.

### Parameters of the operation

#### The btcToMint parameter

It is the amount the contract will use to actually mint DOCs, i.e. it will not be used to pay commission, all of this funds will be transformed purely on DOCs.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and is defined in **MoCLibConnection** contract.
It could be the case, depending on the state of the contract, that a value less than btcToMint will be used to mint the DOCs. In that case, all the extra RBTCs will be sent to you.

#### The value sent

The amount sent in RBTCs to the contract can be considered as a parameter of the transaction, this is why it will be explained in this section. You have to take into consideration, that will be split in three.

- The first part will be used to mint some DOC, the size of this part depends directly on the **btcToMint**. For security reasons, the system allows to mint a maximum amount of DOCs that can be obtained by invoking the `absoluteMaxDoc()` function of the **MoCState** contract.
- The second part will be used to pay the commission, this part is a percentage of the previous part. The commission fees are explained in [this](#commission-fees-values) section.
- The third part is always returned, so if you have doubts of how much you should send, keep in mind that if you send too much RBTCs we will return everything that is not used for commissions or minting.
  In conclusion the amount sent has to be at least the btcToMint plus the commission (if paid in RBTC), the commission being btcToMint times the commission rate.

```
btcSent (msg.value) >= btcToMint + btcToMint * commissionRateInRbtc
```

#### Gas limit and gas price

This two values are a parameter of the transaction, which are not used in the contract and are usually managed by your wallet(you should read about them if you are developing and you don't know exactly what are they), but you should take them into account when trying to send all of your funds to mint some DOCs.

### Possible failures

This operation may fail if one of the following scenarios occurs:

#### The MoC contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more DOCs will be available for minting.
To know if the contract is liquidated you can ask the **MocState** for the **state**, this will return a 0 if liquidated(it is actually an enum).

#### The MoC contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. You can get more information about stoppables contracts [here](https://github.com/money-on-chain/Areopagus-Governance/blob/develop/contracts/Stopper/Stoppable.sol)
In that state, the contract doesn't allow minting any type of token.

To know if this is the case you can ask to **MoC** if it's **paused()**.

#### You sent too few funds:

If the funds you sent doesn't cover the amount you specified on btcToMint.

If this is the case the transaction will revert, all your funds will be returned (except the fee paid to the network). The error message will be "amount is not enough".

#### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

### How-to

In the following sections we will give some code on how this can be done through a Smart Contract or directly, with a console or with an app.
​

#### Smart Contract​

​
To create a new Smart Contract that uses the Money On Chain platform, you can use any language and IDE you want. In this tutorial, we will show you how to do it using [Solidity language](https://solidity.readthedocs.io/en/v0.5.8/), [Truffle Framework](https://www.trufflesuite.com/) and [NPM](https://www.npmjs.com/).
Truffle framework offers some template projects that you can use to develop applications that use smart contracts. You can get more information [here](https://www.trufflesuite.com/boxes).
Assuming you already have your project up and running (if you don't, please follow [this link](https://github.com/money-on-chain/main-RBTC-contract/blob/master/README.md)) the only extra thing you need to do is to install our repo as a dependency in your NPM project. In order you need to do this you just need to run the following command.
​

```
npm install --save -E git+https://git@github.com/money-on-chain/main-RBTC-contract.git
```

Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some DOCs. The good news is that you can do this instantly just by minting them. The code necessary to do this is actually pretty simple.
​
You just have to import the contract
​

```js
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
```

Receive the address in the constructor in order to be able to interact with it later

```js
constructor (MoC _mocContract, MoCInrate _mocInrateContract, rest of your params...) {
//....rest of your constructor....
}
```

​and, finally, when you receive a commission, exchange it for some BitPros
​

```js
uint8 transactionType = mocInrate.MINT_DOC_FEES_RBTC(); // or mocInrate.MINT_DOC_FEES_MOC();
uint256 commissionOfMoC = mocInrate.calcCommissionValue(msg.value, transactionType);
// If commission is paid in RBTC, substract it from value
moc.mintDoc.value(msg.value)(msg.value-commissionOfMoC);
```

​
You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following
​
​

```js
pragma solidity 0.5.8;
​
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
import "money-on-chain/contracts/token/DocToken.sol";
// Here you will import your own dependencies
​
contract YourMintingDocContract {
    // Address of the MoC contract
    MoC public moc;
    // Address of the MocInrate contract
    MoCInrate public mocInrate;
    // Address of the doc token
    DocToken public doc;
    // Address that will receive all the commissions
    address public receiverAddress;
    // rest of your variables
​
    constructor (MoC _moc, MoCInrate _mocInrate, DocToken _doc_, address _receiverAddress) public {
        moc = _moc;
        mocInrate = _mocInrate;
        doc = _doc;
        receiverAddress = _receiverAddress;
        // You could have more variables to initialize here
    }
​
    function doTask() public payable {
        //We set transaction type according to the way fees are paid
        uint8 transactionType = mocInrate.MINT_DOC_FEES_RBTC(); // or mocInrate.MINT_DOC_FEES_MOC();
        //We compute the commision.
​        uint256 commission = mocInrate.calcCommissionValue(msg.value, transactionType);
        //We compute the btcToMint. If commission is paid in RBTC, substract it from value
        uint256 btcToMint = msg.value - commission;
        // Mint some new DOC
        moc.mintDoc.value(msg.value)(btcToMint);
​        // Transfer it to your receiver account
        bpro.transfer(receiverAddress, bpro.balanceOf(address(this)));
        // Rest of the function to actually perform the task
    }
    // rest of your contract
}
```

And that is it, the only thing left to do is to add in the [truffle migrations](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations) scripts the address to MoC and BPro when deploying YourContract and you are done.

## Redeeming DOCs

**Settlements** is a time based recurring process that allows or rejects the processing of DOC redeem requests. The process runs in 90 days intervals.

There are three ways to redeem DOCs:

- On settlement: A DoC redeem request can be created to redeem any amount of DoCs, but this will be processed on the next settlement. The amount can be greater than the user's balance at request time, allowing to, for example, redeem all future user's DoCs regardless of whether their balance increases. The functions that interests us are: `function redeemDocRequest(uint256 docAmount) public` and `function alterRedeemRequestAmount(bool isAddition, uint256 delta) public`

- Outside of settlement: Only free DoCs can be redeemed outside of the settlement. Free DoCs are those that were not transferred to another to provide leverage. The function that interests us is: `function redeemFreeDoc(uint256 docAmount) public`.

- On Liquidation State: The user can redeem all his DoCs with the method: `function redeemAllDoc() public`

### Redeeming DOCs on Settlement: redeemDocRequest

`function redeemDocRequest(uint256 docAmount) public`
There is only one redeem request per user during a settlement. A new reedeem request is created if the user invokes it for the first time or has its value updated if it already exists.

#### Parameters of the operation

##### The docAmount parameter

It is the amount that the contract will use to create or update a DOCs redeem request.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and can be greater than user's balance at request time, allowing to, for example, redeem all future user's DoCs.

##### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some DOCs.

#### Possible failures

This operation may fail if one of the following scenarios occurs:

##### The contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. The condition is the same as that explained in [The MoC contract is paused](#the-MoC-contract-is-paused).

##### Settlement is not ready:

The function can only be invoked when the Settlement is finished executing. If called during execution, the transaction reverts with the error message: _Function can only be called when settlement is ready_.

##### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

##### Not active redeemer:

When a user tries to update a reedem request, but the system can not find its address as an active user for the current settlement. It is a very rare condition in which a transaction reverts with the error message: _This is not an active redeemer_.
If this situation occurs then you can contact the [Money on Chain team](https://moneyonchain.com/) to help you.

##### Not allowed redeemer:

When a user tries to update a reedem request and the system found its address as an active user but redeem request has a different address in the current settlement. It is a very rare condition in which a transaction reverts with the error message: _Not allowed redeemer_.
If this situation occurs then you can contact the [Money on Chain team](https://moneyonchain.com/) to help you.

#### Commissions

The redeemDocRequest operation has no commissions, but when the settlement runs, the total amount of
redeem requests will be used to pay the commission, this part is a percentage of the previous part. The commission fees are explained in [this](#commission-fees-values) section.

### Redeeming DOCs on Settlement: alterRedeemRequestAmount

`alterRedeemRequestAmount(bool isAddition, uint256 delta) public`
There is only at most one redeem request per user during a settlement. A new redeem request is created if the user invokes it for the first time or updates its value if it already exists.

#### Parameters of the operation

##### The isAddition parameter

**true** if you increase the amount of the redemption order amount, **false** otherwise.

##### The delta parameter

It is the amount that the contract will be used to update a DOCs redeem request amount.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and can be greater than user's balance at request time, allowing to, for example, redeem all future user's DOCs.
If isAddition is false and the **delta** param is greater than the total amount of the redeem request, then the total amount of the request will be set to 0.

##### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some DOCs.

#### Possible failures

This operation may fail if one of the following scenarios occurs:

##### The contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. The condition is the same as that explained in [The MoC contract is paused](#the-MoC-contract-is-paused).

##### Settlement is not ready:

The function can only be invoked when the Settlement is finished executing. If called during execution, the transaction reverts with the error message: _Function can only be called when settlement is ready_.

##### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

##### Not active redeemer:

When a user tries to update a redeem request, but the system cannot find its address as an active user for the current settlement. It is a rare condition in which a transaction reverts with the error message: _This is not an active redeemer_.
If this situation occurs then you can contact the [Money on Chain team](https://moneyonchain.com/) to help you.

##### Not allowed redeemer:

When a user tries to update a redeem request and the system found its address as an active user but redeem request has a different address in the current settlement. It is a very rare condition in which a transaction reverts with the error message: _Not allowed redeemer_.
If this situation occurs then you can contact the [Money on Chain team](https://moneyonchain.com/) to help you.

#### Commissions

The alterRedeemRequestAmount operation has no commissions, but when the settlement runs, the total amount of
redeem requests will be used to pay the commission, this part is a percentage of the previous part. The commission fees are explained in [this](#commission-fees-values) section.

### Redeeming DOCs on Settlement: redeemFreeDoc

`function redeemFreeDoc(uint256 docAmount) public`

Redeems the requested **docAmount** for the user or the max amount of free docs possible if **docAmount** is bigger than max.

#### Parameters of the operation

##### The docAmount parameter

It is the amount that the contract will use to redeem free DOCs.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and is defined in **MoCLibConnection** contract.
Money on Chain is a dynamic system that allows you to redeem a maximum amount of free DOCS and can be obtained by calling the `freeDoc()` view of the **MocState** contract.

The first part transforms the amount **docAmount** into an RBTC amount, but 3 things can happen:

- If the absolute maximum amount of allowed DOCs is bigger than the user's balance in DOCs, then the user's total balance will be used to transform it to RBTC.

```
      docAmountToRedeem = Math.min(mocState.freeDoc(), docToken.balanceOf(account));
```

- If the previous amount is greater than the docAmount value, then docAmount will be used to transform it to RBTC.

```
      finalDocAmount = Math.min(docAmount, docAmountToRedeem );
```

- If none of the above conditions are met, docAmount will be used to transform it to RBTC.

```
      docsBtcValue <= docsToBtc(finalDocAmount);
```

The second part will be used to compute and pay the interests of the operation that depends on the abundance of DOCs in the MOC system. The value can be obtained by invoking the function `calcDocRedInterestValues(finalDocAmount, docsBtcValue)` of the contract **MocInrate** and also has an accuracy of 18 decimal places.

The third part will be used to pay the commission, this part is a percentage of the previous part. The commission fees are explained in [this](#commission-fees-values) section.

The fourth part returns the amount in RBTC discounting the previously calculated commissions and interests. In conclusion, the user receives the amount of RBTC discounting the commissions (if paid in RBTC)

```
    btcReceived = finalBtcAmount - finalBtcAmount * commisionRateInRbtc;
```

##### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some DOCs.

#### Possible failures

This operation may fail if one of the following scenarios occurs:

##### The contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. The condition is the same as that explained in [The MoC contract is paused](#the-MoC-contract-is-paused).

##### The MoC contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more DOCs will be available for minting.
To know if the contract is liquidated you can ask the **MocState** for the **state**, this will return a 0 if liquidated(it is actually an enum).

##### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

### Redeeming DOCs on Liquidation State: redeemAllDoc

`function redeemAllDoc() public`

Allows redeeming on liquidation state, user DOCs get burned, and the user receives the equivalent RBTCs according to the liquidation price which is the relation between the DOCs total supply and the amount of RBTC available to distribute.
The liquidation price can be queried with the view `getLiquidationPrice()` of the contract **MocState**.
If sending RBTC fails then the system does not burn the DOC tokens.

#### Parameters of the operation

##### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some DOCs.

#### Possible failures

This operation may fail if one of the following scenarios occurs:

##### The MoC contract is not liquidated:

This operation can only be performed if the system is liquidated. If the MoC contract is in any other state then it fails and returns the following message: _Function cannot be called at this state_.

To know if the contract is liquidated you can ask the **MocState** for the **state**, this will return a 0 if liquidated(it is actually an enum).

##### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

### How-to

In the following sections we will give some code on how this can be done through a Smart Contract or directly, with a console or with an app.
​

#### Smart Contract​

To create a new Smart Contract that uses the Money On Chain platform, you can use any language and IDE you want. In this tutorial, we will show you how to do it using [Solidity language](https://solidity.readthedocs.io/en/v0.5.8/), [Truffle Framework](https://www.trufflesuite.com/) and [NPM](https://www.npmjs.com/).
Truffle framework offers some template projects that you can use to develop applications that use smart contracts. You can get more information [here](https://www.trufflesuite.com/boxes).
Assuming you already have your project up and running (if you don't, please follow [this link](https://github.com/money-on-chain/main-RBTC-contract/blob/master/README.md)) the only extra thing you need to do is to install our repo as a dependency in your NPM project. In order you need to do this you just need to run the following command.
​

```
npm install --save -E git+https://git@github.com/money-on-chain/main-RBTC-contract.git
```

Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some DOCs. The good news is that you can do this instantly just by redeeming them. The code necessary to do this is actually pretty simple.
​
You just have to import the contract
​

```js
import "money-on-chain/contracts/MoC.sol";
```

Receive the address in the constructor in order to be able to interact with it later

```js
constructor (MoC _mocContract, MoCInrate _mocInrateContract, rest of your params...) {
//....rest of your constructor....
}
```

```js
//Create a new redeem request
uint256 docAmount = 90;
moc.redeemDocRequest(docAmount);
```

```js
//Add 10 docs to a redeem request.
moc.alterRedeemRequestAmount(true, 10);
//Sustract 5 docs to a redeem request.
moc.alterRedeemRequestAmount(true, 5);
```

```js
//Trying to redeem All Docs.
uint256 docBalance = docToken.balanceOf(userAddress);
moc.redeemFreeDoc(docBalance);
```

You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the doc token.
​
This will leave you with a contract similar to the following

```js
import "money-on-chain/contracts/MoC.sol";
```

Receive the address in the constructor in order to be able to interact with it later

```js
constructor (MoC _mocContract, rest of your params...) {
//....rest of your constructor....
}
​
```

You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following
​​

```js
pragma solidity 0.5.8;
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/token/DocToken.sol";
// Here you will import your own dependencies

contract YourRedeemingDocContract {
    // Address of the MoC contract
    MoC public moc;
    // Address of the bitpro token
    DocToken public doc;
    // DOC Amount
    uint256 docAmount;
    // rest of your variables

    constructor (MoC _moc, DocToken _doc, uint256 _docAmount) public {
        moc = _moc;
        doc = _doc;
        docAmount = _docAmount;
        // You could have more variables to initialize here
    }
​
    function createRedeemRequest() public {
        uint256 previousBalance = doc.balanceOf(msg.sender);
        moc.redeemDocRequest(docAmount);
        uint256 newBalance = doc.balanceOf(msg.sender);
    }

    function addToRedeemRequest(uint256 _addValue) public {
        moc.alterRedeemRequestAmount(true, docAmount);
        uint256 newBalance = doc.balanceOf(msg.sender);
    }

    function sustractToRedeemRequest(uint256 _addValue) public {
        moc.alterRedeemRequestAmount(false, docAmount);
        uint256 newBalance = doc.balanceOf(msg.sender);
    }

    function redeemFreeDoc(uint256 _docAmount) public {
        uint256 previousBalance = doc.balanceOf(msg.sender);
        moc.redeemFreeDoc(_docAmount);
        uint256 newBalance = doc.balanceOf(msg.sender);
    }
    // rest of your contract
}​
```

And that is it, the only thing left to do is to add in the [truffle migrations](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations) scripts the address to MoC and BPro when deploying YourContract and you are done.

# Getting BTC2X

BTC2X is targeted towards users looking to profit from long positions in bitcoin, with two times the risk and reward. Leveraged instruments borrow capital from the base bucket (50% in a X2) and pay a daily rate to it as return.

There is a relation between DOCS and BTC2X. The more DOCs minted, the more BTC2X can be minted, since they are used for leverage.

The BTC2X token does not implement an ERC20 interface and can not be traded freely because leveraged instruments cannot change owner. BTC2X are assigned to the user BTCX positions can be canceled any time though.

The daily rate can be obtained invoking the `dailyInrate()` view of the **MocInrate** contract.

## Minting BTC2X

BTC2X can only be minted in exchange for RBTC.

In this tutorial the method(or function) that is of interest to us is `function mintBProx(bytes32 bucket, uint256 btcToMint) public payable` As you can see this function is payable, this means that it is prepared to receive RBTCs.

### Parameters of the operation

#### The bucket parameter

A bucket is a bag that stores the balances of the leveraged token holders. Currently, only the BTC2X bucket called _X2_ exists. The X2 must be passed as a hex value.

There is also a bucket named _C0_ but it should not be used to mint and redeem BTC2X.

In the following example you can see how to do it with javascript and the web3 library. For more detailed information about web3 you can read the [from outside blockchain](#from-outside-the-blockchain) section.

```js
const BUCKET_X2 = web3.utils.asciiToHex("X2", 32);
```

#### The btcToMint parameter

It is the amount the contract will use to actually mint BTC2X, i.e. it will not be used to pay commission, all of this funds will be transformed purely on BTC2X.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places is defined in **MoCLibConnection** contract.

#### The value sent

The amount sent in RBTCs to the contract can be considered as a parameter of the transaction, which is why it will be explained in this section. You have to take into consideration that it will be split in four.

- The first part will be used to mint some BTC2X, the size of this part depends directly on the btcToMint, and it may be smaller than btcToMint.

- The second part will be used to compute and pay interests that can be queried with the `calcMintInterestValues(bucket, finalBtcToMint)` of the **MocInrate** contract.

- The third part will be used to pay the commission, this part is a percentage of the first part. The commission fees are explained in [this](#commission-fees-values) section.

- The fourth part is always returned, so if you have doubts of how much you should send, keep in mind that if you send too much RBTCs we will return everything that it is not used for commissions or interests.
  In conclusion the amount sent has to be at least the btcToMint plus the interests, the commission being btcToMint times the commission rate (if paid in RBTC).

```
btcSent (msg.value) >= btcToMint + interests + btcToMint * commissionRateInRbtc
```

#### Gas limit and gas price

This two values are a parameter of the transaction, this is not used in the contract and it is usually managed by your wallet(you should read about them if you are developing and you don't know exactly what are they) but you should take them into account when trying to send all of your funds to mint some BTC2X.

### Possible failures

This operation may fail if one of the following scenarios occurs:

#### The MoC contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more BTC2X will be available for minting.
To know if the contract is liquidated you can ask the **MocState** for the **state**, this will return a 0 if liquidated(it is actually an enum).

#### The MoC contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. You can get more information about stoppables contracts [here](https://github.com/money-on-chain/Areopagus-Governance/blob/develop/contracts/Stopper/Stoppable.sol)
In that state, the contract doesn't allow minting any type of token.

To know if this is the case you can ask to **MoC** if it's **paused()**.

##### Settlement is not ready:

The function can only be invoked when the Settlement is finished executing. If called during execution, the transaction reverts with the error message: _Function can only be called when settlement is ready_.

##### Bucket is not available:

Currently, only the BTC2X bucket called 'X2' exists. If it is called with another bucket, the transaction reverts with the error message: _Bucket is not available_.

##### Bucket is not a base bucket:

Currently, only the BTC2X bucket called 'X2' exists. If you call the function with _C0_ bucket, the transaction reverts with the error message: _Bucket should not be a base type bucket_.

#### You sent too few funds:

If the funds you sent doesn't cover the amount you specified on btcToMint.

If this is the case the transaction will revert, all your funds will be returned (except the fee paid to the network). The error message will be "amount is not enough".

#### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

### How-to

In the following sections we will give some code on how this can be done through a Smart Contract or directly, with a console or with an app.
​

#### Smart Contract​

​
To create a new Smart Contract that uses the Money On Chain platform, you can use any language and IDE you want. In this tutorial, we will show you how to do it using [Solidity language](https://solidity.readthedocs.io/en/v0.5.8/), [Truffle Framework](https://www.trufflesuite.com/) and [NPM](https://www.npmjs.com/).
Truffle framework offers some template projects that you can use to develop applications that use smart contracts. You can get more information [here](https://www.trufflesuite.com/boxes).
Assuming you already have your project up and running (if you don't, please follow [this link](https://github.com/money-on-chain/main-RBTC-contract/blob/master/README.md)) the only extra thing you need to do is to install our repo as a dependency in your NPM project. In order you need to do this you just need to run the following command.
​

```
npm install --save -E git+https://git@github.com/money-on-chain/main-RBTC-contract.git
```

Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some BitPros. The good news is that you can do this instantly just by minting them. The code necessary to do this is actually pretty simple.
​
You just have to import the contract
​

```js
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
```

Receive the address in the constructor in order to be able to interact with it later

```js
constructor (MoC _mocContract, MoCInrate _mocInrateContract, rest of your params...) {
//....rest of your constructor....
}
```

​and, finally, when you receive a commission, exchange it for some BitPros
​

```js
bytes32 constant public BUCKET_X2 = "X2";
uint8 transactionType = mocInrate.MINT_BTCX_FEES_RBTC(); // or mocInrate.MINT_BTCX_FEES_MOC();
uint256 commissionOfMoC = mocInrate.calcCommissionValue(msg.value, transactionType);
// If commission is paid in RBTC, substract it from value
moc.mintBProx.value(msg.value)(BUCKET_X2, msg.value-commissionOfMoC);
```

​
You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following
​
​

```js
pragma solidity 0.5.8;
​
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
// Here you will import your own dependencies
​
contract YourMintingBtc2xContract {
    // Address of the MoC contract
    MoC public moc;
    // Address of the MocInrate contract
    MoCInrate public mocInrate;
    // Define a constant to call bucket X2
​    bytes32 constant public BUCKET_X2 = "X2";

    constructor (MoC _moc, MoCInrate _mocInrate) public {
        moc = _moc;
        mocInrate = _mocInrate;
        // You could have more variables to initialize here
    }
​
    function doTask() public payable {
        //We set transaction type according to the way fees are paid
        uint8 transactionType = mocInrate.MINT_BTCX_FEES_RBTC(); // or mocInrate.MINT_BTCX_FEES_MOC();
        //We compute the commision.
​        uint256 commission = mocInrate.calcCommissionValue(msg.value, transactionType);
        //We compute the btcToMint. If commission is paid in RBTC, substract it from value
        uint256 btcToMint = msg.value - commission;
        // Mint some new BitPro
        moc.mintBProx.value(msg.value)(BUCKET_X2, btcToMint);
        // Rest of the function to actually perform the task
    }
    // rest of your contract
}
```

​
​​

## Redeeming BTC2X

The Money On Chain's Smart Contract suite is in control of redeeming its tokens, including the BTC2X token. This means that the return of BTC2X is controlled programmatically by said suite. ​A user can "sell" their BTC2X back to the contract and have RBTC deposited are sent back to the user, alongside the refunded interests (waiting in inrateBag) for the remaining time until the settlement (not yet charged).

In this tutorial the method(or function) that is of interest to us is `function redeemBProx(bytes32 bucket, uint256 bproxAmount) public`.

### Parameters of the operation

#### The bucket parameter

A bucket is a bag that stores the balances of the leveraged token holders. Currently, only the BTC2X bucket called _X2_ exists. The X2 must be passed as an hex value.

There is also a bucket named _C0_ but it should not be used to mint and redeem BTC2X.

In the following example you can see how to do it with javascript and the web3 library. For more detailed information about web3 you can read the [From outside the blockchain](#from-outside-the-blockchain) section.

```js
const BUCKET_X2 = web3.utils.asciiToHex("X2", 32);
```

#### The bproxAmount parameter

It is the amount that the contract will use to redeem BTC2X and will be used to calculate commissions. All of these funds will be transformed exclusively into RBTC.
This parameter uses a precision of the type **reservePrecision** that contains 18 decimal places and is defined in **MoCLibConnection** contract.

The redeeming process is divided into 4 parts:
The first part transforms the amount **bproxAmount** into an RBTC amount, but 2 things can happen:

- The amount entered in bproAmount must not exceed the user's balance in BPROs. If this occurs then the user’s balance will be used to calculate the value in RBTC.

```js
    userBalance = bproxBalanceOf(bucket, user);
    bproxToRedeem = Math.min(bproxAmount, userBalance);
    rbtcToRedeem = bproxToBtc(bproxToRedeem, bucket);
```

The second part computes interests to be paid to the user.

The third part will be used to pay the commission, this part is a percentage of the first part. The commission fees are explained in [this](#commission-fees-values) section.

The fourth part returns the amount in RBTC adding the computed interest and discounting the previously calculated commissions (if paid in RBTC).

```
btcReceived = totalBtc + interests - totalBtc * commissionRateInRbtc
```

#### Gas limit and gas price

These two values are a parameter of the transaction, this is not used in the contract and is generally managed by your wallet (you should read about them if you are developing and do not know exactly what they are), but you should take them into account when trying to redeem some BTC2X.

### Possible failures

This operation may fail if one of the following scenarios occurs:

#### The MoC contract is liquidated:

In the extraneous case where a coverage that barely covers the stable tokens funds is reached, the contract will liquidate all of its assets. If this state occurs, no more BTC2X will be available for redeeming.
To know if the contract is liquidated you can ask the **MocState** for the **state**, this will return a 0 if liquidated(it is actually an enum).

#### The MoC contract is paused:

If the system suffers some type of attack, the contract can be paused so that operations cannot be done and the risk of the users losing their funds with the operation can be minimized. You can get more information about stoppables contracts [here](https://github.com/money-on-chain/Areopagus-Governance/blob/develop/contracts/Stopper/Stoppable.sol)
In that state, the contract doesn't allow minting any type of token.

To know if this is the case you can ask to **MoC** if it's **paused()**.

##### Settlement is not ready:

The function can only be invoked when the Settlement has finished executing. If called during execution, the transaction reverts with the error message: _Function can only be called when settlement is ready_.

##### Bucket is not available:

Currently, only the BTC2X bucket called 'X2' exists. If it is called with another bucket, the transaction reverts with the error message: _Bucket is not available_.

##### Bucket is not a base bucket:

Currently, only the BTC2X bucket called 'X2' exists. If you call the function with _C0_ bucket, the transaction reverts with the error message: _Bucket should not be a base type bucket_.

#### Not enough gas:

If the gas limit sent is not enough to run all the code needed to execute the transaction, the transaction will revert(again, returning all your funds except the fee paid to the network). This may return an "out of gas" error or simply a "revert" error because of the usage of the proxy pattern.

### How-to

In the following sections we will give some code on how this can be done through a Smart Contract or directly, with a console or with an app.
​

#### Smart Contract​

​
To create a new Smart Contract that uses the Money On Chain platform, you can use any language and IDE you want. In this tutorial, we will show you how to do it using [Solidity language](https://solidity.readthedocs.io/en/v0.5.8/), [Truffle Framework](https://www.trufflesuite.com/) and [NPM](https://www.npmjs.com/).
Truffle framework offers some template projects that you can use to develop applications that use smart contracts. You can get more information [here](https://www.trufflesuite.com/boxes).
Assuming you already have your project up and running (if you don't, please follow [this link](https://github.com/money-on-chain/main-RBTC-contract/blob/master/README.md)) the only extra thing you need to do is to install our repo as a dependency in your NPM project. In order you need to do this you just need to run the following command.
​

```
npm install --save -E git+https://git@github.com/money-on-chain/main-RBTC-contract.git
```

Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some BitPros. The good news is that you can do this instantly just by minting them. The code necessary to do this is actually pretty simple.
​
You just have to import the contract
​

```js
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
```

Receive the address in the constructor in order to be able to interact with it later

```js
constructor (MoC _mocContract, MoCInrate _mocInrateContract, rest of your params...) {
//....rest of your constructor....
}
```

​and, finally, when you receive a commission, exchange it for some BitPros
​

```js
uint256 bproxAmountToRedeem = 2;
bytes32 constant public BUCKET_X2 = "X2";
moc.redeemBProx.(BUCKET_X2, bproxAmountToRedeem);
```

​
You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following
​
​

```js
pragma solidity 0.5.8;
​
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/MoCInrate.sol";
// Here you will import your own dependencies
​
contract YourRedeemingBtc2xContract {
    // Address of the MoC contract
    MoC public moc;
    // Define a constant to call bucket X2
​    bytes32 constant public BUCKET_X2 = "X2";

    constructor (MoC _moc) public {
        moc = _moc;
        // You could have more variables to initialize here
    }
​
    function doTask(uint256 _bproxAmount) public {
        uint256 prevRbtcBalance = moc.bproxBalanceOf(BUCKET_X2, msg.sender);
        // Mint some new BTC2X
        moc.redeemBProx.(BUCKET_X2, _bproxAmount);
        uint256 newRbtcBalance = moc.bproxBalanceOf(BUCKET_X2, msg.sender);
        // Rest of the function to actually perform the task
    }
    // rest of your contract
}
```


# Commission fees values
 Depending on the desired operation and the token used to pay commissions, this value is calculated according the following table. Keep in mind that if the account has balance and allowance of MoC token, commissions will be paid with this token; otherwise commissions will be paid in RBTC. The exact percentage of the commission is set in the variable **commissionRatesByTxType** (which maps a transaction type with its commission) of the **MocInrate** contract. The transactions types are constants defined in the same contract and are detailed next. The current commission fees are yet to be defined. The different valid transaction types are the following:
| Transaction Type | Description | Value |
| --- | --- | --- |
| `MINT_BPRO_FEES_RBTC` | Mint BPRO with fees in RBTC | mbpr% |
| `REDEEM_BPRO_FEES_RBTC` | Redeem BPRO with fees in RBTC | rbpr% |
| `MINT_DOC_FEES_RBTC` | Mint DOC with fees in RBTC | mdcr% |
| `REDEEM_DOC_FEES_RBTC` | Redeem DOC with fees in RBTC | rdcr% |
| `MINT_BTCX_FEES_RBTC` | Mint BTCx with fees in RBTC | mbxr% |
| `REDEEM_BTCX_FEES_RBTC` | Redeem BTCx with fees in RBTC | rbxr% |
| `MINT_BPRO_FEES_MOC` | Mint BPRO with fees in MoC | mbpm% |
| `REDEEM_BPRO_FEES_MOC` | Redeem BPRO with fees in MoC | rbpm% |
| `MINT_DOC_FEES_MOC` | Mint DOC with fees in MoC | mdcm% |
| `REDEEM_DOC_FEES_MOC` | Redeem DOC with fees in MoC | rdcm% |
| `MINT_BTCX_FEES_MOC` | Mint BTCx with fees in MoC | mbxm% |
| `REDEEM_BTCX_FEES_MOC` | Redeem BTCx with fees in MoC | rbxm% |

Note that these commissions have also a precision of 18 decimals, i.e. a 1 \* 10^15 in that parameter means that 0.1% is being charged as a commission).


# From outside the blockchain

The logic of the Money on Chain platform is developed with smart contracts that run on the RSK blockchain. To interact with this kind of technology, we developed a dApp (decentralized application), which is a web or mobile application that invokes the functions of the smart contracts.

You can find tutorials about developing dApps in the following resources:

- [The Ultimate Ethereum Dapp Tutorial (How to Build a Full Stack Decentralized Application Step-By-Step)](https://www.dappuniversity.com/articles/the-ultimate-ethereum-dapp-tutorial)

- [ETHEREUM PET SHOP -- YOUR FIRST DAPP](https://www.trufflesuite.com/tutorials/pet-shop)

- [RSK Truffle Boxes](https://developers.rsk.co/tools/truffle/boxes/)

  The web3 library is one of the most popular to invoke the functions of smart contracts and there are different projects to use them with

- [javascript](https://web3js.readthedocs.io/)
- [Python](https://web3py.readthedocs.io/en/stable/)
- [Java and Android](https://docs.web3j.io/)
- [.NET](https://nethereum.readthedocs.io/en/latest/)
- [Swift](https://web3swift.io/)

We use **web3.js** in this tutorial.

An RSK smart contract is bytecode implemented on the RSK blockchain. When a smart contract is compiled, an ABI (application binary interface) is generated and it is required so that you can specify which contract function to invoke, as well as get a guarantee that the function will return the data in the format you expect.
The ABI in JSON format must be provided to web3 to build decentralized applications.

​

## Using RSK nodes

Money on Chain contracts are executed on the RSK blockchain whose public nodes are testnet (testing environment) and mainnet (production environment). You can use a public node or install a node in your own server.

### Public node: RSK Testnet

- URL: https://public-node.testnet.rsk.co
- chainID: 31
- Cryptocurrency symbol: RBTC
- Explorer: https://explorer.testnet.rsk.co/

### Public node: RSK Mainnet

- URL: https://public-node.rsk.co
- chainID: 30
- Cryptocurrency symbol: RBTC
- Explorer: https://explorer.rsk.co/

### Installing your own node

The RSK node can be installed on different operating systems such as Linux, Windows and Mac. It is also possible to run them in environments running docker and in cloud service providers such as AWS, Azure and Google. For more information check the [official RSK documentation](https://developers.rsk.co/rsk/node/install/)

## Using web3

You can use the technology that suits you best for your project to integrate with the Money on Chain platform, but you must use web3 to invoke the functions of smart contracts. You can learn how to use it with the following tutorials:

- javascript: [Intro to Web3.js · Ethereum Blockchain Developer Crash Course](https://www.dappuniversity.com/articles/web3-js-intro)
- python: [Intro to Web3.py · Ethereum For Python Developers](https://www.dappuniversity.com/articles/web3-py-intro)
- Java an Android: [web3j Getting Started](https://docs.web3j.io/getting_started/)
- .NET: [Getting Started with Nethereum](http://docs.nethereum.com/en/latest/getting-started/)
- Swift: [Web3Swift README.md](https://github.com/zeriontech/web3swift)

​

## Official Money on Chain ABIS

In the Money on Chain repository you can find the [official ABIs of the platform](https://github.com/money-on-chain/web-billfold-app/tree/develop/contracts/moc). You can use them to build your own decentralized applications to invoke the functions of smart contracts.

## Example code minting BPROS

In the following example we will show how to invoke the mintBpro function of the Money on Chain contract in testnet.

First we create a new node project.

````

mkdir example-mint-bpro
node init

```

Then we add the necessary dependencies to run the project

```

npm install --save bignumber.js
npm install --save web3
npm install --save truffle-hdwallet-provider

````

```js
const HDWalletProvider = require("truffle-hdwallet-provider");
const BigNumber = require("bignumber.js");
const Web3 = require("web3");
//You must compile the smart contracts or use the official ABIs of the //repository
const MocAbi = require("./contracts/moc/MoC.json");
const MoCInrateAbi = require("./contracts/moc/MoCInrate.json");
const MoCStateAbi = require("./contracts/moc/MoCState.json");

//Config params to TestNet
const endpoint = "https://public-node.testnet.rsk.co";
//a mnemonic is 12 words instead of a single private key to sign the //transactions
const mnemonic =
  "chase chair crew elbow uncle awful cover asset cradle pet loud puzzle";
const provider = new HDWalletProvider(mnemonic, endpoint);
const web3 = new Web3(provider);

//Contract addresses on testnet
const mocContractAddress = "0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F";
const mocInrateAddress = "0x76790f846FAAf44cf1B2D717d0A6c5f6f5152B60";
const mocStateAddress = "0x0adb40132cB0ffcEf6ED81c26A1881e214100555";
const gasPrice = 60000000;

const execute = async () => {
  /**
   * Loads an specified contract
   * @param {json ABI} abi
   * @param {localhost/testnet/mainnet} contractAddress
   */
  const getContract = async (abi, contractAddress) =>
    new web3.eth.Contract(abi, contractAddress);

  /**
   * Transforms BigNumbers into
   * @param {*} number
   */
  const toContract = number => new BigNumber(number).toFixed(0);

  // Loading moc contract
  const moc = await getContract(MocAbi.abi, mocContractAddress);
  if (!moc) {
    throw Error("Can not find MoC contract.");
  }

  // Loading mocInrate contract. It is necessary to compute commissions
  const mocInrate = await getContract(MoCInrateAbi.abi, mocInrateAddress);
  if (!mocInrate) {
    throw Error("Can not find MoC Inrate contract.");
  }

  // Loading mocState contract. It is necessary to compute max BPRO available to mint
  const mocState = await getContract(MoCStateAbi.abi, mocStateAddress);
  if (!mocState) {
    throw Error("Can not find MoCState contract.");
  }

  const mintBpro = async btcAmount => {
    web3.eth.getAccounts().then(console.log);
    const from = "0x088f4B1313D161D83B4D8A5EB90905C263ce0DbD";
    const weiAmount = web3.utils.toWei(btcAmount, "ether");
    // Computes commision value
    const transactionType = mocInrate.MINT_BPRO_FEES_RBTC(); // or mocInrate.MINT_BPRO_FEES_MOC();
    const commissionValue = new BigNumber(
      await mocInrate.methods.calcCommissionValue(weiAmount, transactionType).call()
    );
    // Computes totalBtcAmount to call mintBpro. If commission is paid in RBTC, add it to value
    const totalBtcAmount = toContract(commissionValue.plus(weiAmount));
    console.log(
      `Calling Bpro minting with account: ${from} and amount: ${weiAmount}.`
    );
    const tx = moc.methods
      .mintBPro(weiAmount)
      .send({ from, value: totalBtcAmount, gasPrice }, function(
        error,
        transactionHash
      ) {
        if (error) console.log(error);
        if (transactionHash) console.log("txHash: ".concat(transactionHash));
      });

    return tx;
  };

  function logEnd() {
    console.log("End Example");
  }

  // Gets max BPRO available to mint
  const maxBproAvailable = await mocState.methods.maxMintBProAvalaible().call();
  console.log("Max Available BPRO: ".concat(maxBproAvailable.toString()));
  const btcAmount = "0.00005";

  // Call mint
  await mintBpro(btcAmount, logEnd);
};

execute()
  .then(() => console.log("Completed"))
  .catch(err => {
    console.log("Error", err);
  });
```


