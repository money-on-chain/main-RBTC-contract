---
id: version-0.1.12-BtcPriceProviderMock
title: BtcPriceProviderMock
original_id: BtcPriceProviderMock
---

# BtcPriceProviderMock.sol

View Source: [contracts/mocks/BtcPriceProviderMock.sol](../../contracts/mocks/BtcPriceProviderMock.sol)

**↗ Extends: [PriceFeed](PriceFeed.md), [PriceProvider](PriceProvider.md)**

**BtcPriceProviderMock** - version: 0.1.12

## Contract Members
**Constants & Variables**

```js
bytes32 internal btcPrice;
```
---

```js
bool internal has;
```
---

## Functions

- [(uint256 price)](#btcpriceprovidermocksol)
- [peek()](#peek)
- [poke(uint128 val_, uint32 )](#poke)
- [post(uint128 val_, uint32 , address )](#post)

### 

Constructor

```js
function (uint256 price) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| price | uint256 | BTC price for mock contract | 

### peek

⤾ overrides [PriceProvider.peek](PriceProvider.md#peek)

```js
function peek() external view
returns(bytes32, bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### poke

⤾ overrides [PriceFeed.poke](PriceFeed.md#poke)

```js
function poke(uint128 val_, uint32 ) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| val_ | uint128 |  | 
|  | uint32 |  | 

### post

⤾ overrides [PriceFeed.post](PriceFeed.md#post)

```js
function post(uint128 val_, uint32 , address ) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| val_ | uint128 |  | 
|  | uint32 |  | 
|  | address |  | 

