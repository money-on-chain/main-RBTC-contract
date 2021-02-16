---
id: version-0.1.10-MoCPriceProviderMock
title: MoCPriceProviderMock
original_id: MoCPriceProviderMock
---

# MoCPriceProviderMock.sol

View Source: [contracts/mocks/MoCPriceProviderMock.sol](../contracts/mocks/MoCPriceProviderMock.sol)

**↗ Extends: [TexPriceProvider](TexPriceProvider.md)**

**MoCPriceProviderMock** - version: 0.1.10

## Contract Members
**Constants & Variables**

```js
uint256 internal mocPrice;

```

## Functions

- [(uint256 price)](#)
- [setPrice(uint256 price)](#setprice)
- [getLastClosingPrice(address , address )](#getlastclosingprice)

### 

Constructor

```js
function (uint256 price) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| price | uint256 | MoC price for mock contract | 

### setPrice

```js
function setPrice(uint256 price) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| price | uint256 |  | 

### getLastClosingPrice

⤾ overrides [TexPriceProvider.getLastClosingPrice](TexPriceProvider.md#getlastclosingprice)

Getter for every value related to a pair

```js
function getLastClosingPrice(address , address ) public view
returns(lastClosingPrice uint256)
```

**Returns**

lastClosingPrice - the last price from a successful matching

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
|  | address |  | 
|  | address |  | 

