---
id: version-0.1.12-PriceFeederAdder
title: PriceFeederAdder
original_id: PriceFeederAdder
---

# PriceFeederAdder.sol

View Source: [contracts/changers/productive/PriceFeederAdder.sol](../../contracts/changers/productive/PriceFeederAdder.sol)

**↗ Extends: [ChangeContract](ChangeContract.md)**

**PriceFeederAdder** - version: 0.1.12

## Contract Members
**Constants & Variables**

```js
contract PriceFactory public priceFactory;
```
---

```js
contract Medianizer public medianizer;
```
---

```js
address public priceFeedOwner;
```
---

## Functions

- [setOwner(address newOwner)](#setowner)
- [create()](#create)
- [set(address priceFeed)](#set)
- [(PriceFactory _priceFactory, Medianizer _medianizer, address _priceFeedOwner)](#pricefeederaddersol)
- [execute()](#execute)

### setOwner

```js
function setOwner(address newOwner) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newOwner | address |  | 

### create

```js
function create() external nonpayable
returns(contract DSAuth)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### set

```js
function set(address priceFeed) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| priceFeed | address |  | 

### 

Constructor

```js
function (PriceFactory _priceFactory, Medianizer _medianizer, address _priceFeedOwner) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _priceFactory | PriceFactory |  | 
| _medianizer | Medianizer |  | 
| _priceFeedOwner | address |  | 

### execute

⤾ overrides ChangeContract.execute

```js
function execute() external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

