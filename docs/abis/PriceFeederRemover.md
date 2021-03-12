---
id: version-0.1.10-PriceFeederRemover
title: PriceFeederRemover
original_id: PriceFeederRemover
---

# PriceFeederRemover.sol

View Source: [contracts/changers/productive/PriceFeederRemover.sol](../../contracts/changers/productive/PriceFeederRemover.sol)

**↗ Extends: [ChangeContract](ChangeContract.md)**

**PriceFeederRemover** - version: 0.1.10

## Contract Members
**Constants & Variables**

```js
contract Medianizer public medianizer;
address public priceFeed;

```

## Functions

- [unset(address priceFeed)](#unset)
- [(Medianizer _medianizer, address _priceFeed)](#)
- [execute()](#execute)

### unset

```js
function unset(address priceFeed) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| priceFeed | address |  | 

### 

Constructor

```js
function (Medianizer _medianizer, address _priceFeed) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _medianizer | Medianizer |  | 
| _priceFeed | address |  | 

### execute

⤾ overrides ChangeContract.execute

```js
function execute() external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

