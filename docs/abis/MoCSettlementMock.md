---
id: version-0.1.12-MoCSettlementMock
title: MoCSettlementMock
original_id: MoCSettlementMock
---

# MoCSettlementMock.sol

View Source: [contracts/mocks/MoCSettlementMock.sol](../../contracts/mocks/MoCSettlementMock.sol)

**↗ Extends: [MoCSettlement](MoCSettlement.md)**

**MoCSettlementMock** - version: 0.1.12

## Contract Members
**Constants & Variables**

```js
uint256 internal constant STEPS;
```
---

## Functions

- [()](#mocsettlementmocksol)
- [()](#mocsettlementmocksol)
- [pubRunDeleveraging()](#pubrundeleveraging)
- [pubRunRedeemDoc()](#pubrunredeemdoc)
- [setBlockSpan(uint256 _blockSpan)](#setblockspan)
- [docRedemptionStepCountForTest()](#docredemptionstepcountfortest)

### 

Constructor

```js
function () public nonpayable MoCSettlement 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### 

```js
function () external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### pubRunDeleveraging

```js
function pubRunDeleveraging() public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### pubRunRedeemDoc

```js
function pubRunRedeemDoc() public nonpayable
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setBlockSpan

⤾ overrides [?]

Sets the number of blocks settlement will be allowed to run

```js
function setBlockSpan(uint256 _blockSpan) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _blockSpan | uint256 | number of blocks | 

### docRedemptionStepCountForTest

Returns the amount of steps for the Doc Redemption task
which is the amount of redeem requests in the queue. (Used in tests only)

```js
function docRedemptionStepCountForTest() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

