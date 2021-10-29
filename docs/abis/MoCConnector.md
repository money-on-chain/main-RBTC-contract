---
id: version-0.1.12-MoCConnector
title: MoCConnector
original_id: MoCConnector
---

# MoCConnector.sol

View Source: [contracts/base/MoCConnector.sol](../../contracts/base/MoCConnector.sol)

**↗ Extends: [MoCWhitelist](MoCWhitelist.md), [Initializable](Initializable.md)**

**MoCConnector** - version: 0.1.12

Provides access control between all MoC Contracts

## Contract Members
**Constants & Variables**

```js
address payable public moc;
```
---

```js
address public docToken;
```
---

```js
address public bproToken;
```
---

```js
address public bproxManager;
```
---

```js
address public mocState;
```
---

```js
address public DEPRECATED_mocConverter;
```
---

```js
address public mocSettlement;
```
---

```js
address public mocExchange;
```
---

```js
address public mocInrate;
```
---

```js
address public mocBurnout;
```
---

```js
bool internal initialized;
```
---

```js
uint256[50] private upgradeGap;
```
---

## Functions

- [initialize(address payable mocAddress, address docAddress, address bproAddress, address bproxAddress, address stateAddress, address settlementAddress, address exchangeAddress, address inrateAddress, address burnoutBookAddress)](#initialize)

### initialize

Initializes the contract

```js
function initialize(address payable mocAddress, address docAddress, address bproAddress, address bproxAddress, address stateAddress, address settlementAddress, address exchangeAddress, address inrateAddress, address burnoutBookAddress) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocAddress | address payable | MoC contract address | 
| docAddress | address | DoCToken contract address | 
| bproAddress | address | BProToken contract address | 
| bproxAddress | address | BProxManager contract address | 
| stateAddress | address | MoCState contract address | 
| settlementAddress | address | MoCSettlement contract address | 
| exchangeAddress | address | MoCExchange contract address | 
| inrateAddress | address | MoCInrate contract address | 
| burnoutBookAddress | address | (DEPRECATED) MoCBurnout contract address. DO NOT USE. | 

