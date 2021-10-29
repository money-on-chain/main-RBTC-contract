---
id: version-0.1.12-MoCStateMock
title: MoCStateMock
original_id: MoCStateMock
---

# MoCStateMock.sol

View Source: [contracts/mocks/MoCStateMock.sol](../../contracts/mocks/MoCStateMock.sol)

**↗ Extends: [MoCState](MoCState.md)**

**MoCStateMock** - version: 0.1.12

## Contract Members
**Constants & Variables**

```js
uint256 internal _daysToSettlement;
```
---

## Functions

- [()](#mocstatemocksol)
- [initialize(struct MoCState.InitializeParams params)](#initialize)
- [setDaysToSettlement(uint256 daysToSettl)](#setdaystosettlement)
- [daysToSettlement()](#daystosettlement)

### 

Constructor

```js
function () public nonpayable MoCState 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### initialize

⤾ overrides [MoCState.initialize](MoCState.md#initialize)

```js
function initialize(struct MoCState.InitializeParams params) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| params | struct MoCState.InitializeParams |  | 

### setDaysToSettlement

```js
function setDaysToSettlement(uint256 daysToSettl) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| daysToSettl | uint256 |  | 

### daysToSettlement

⤾ overrides [MoCState.daysToSettlement](MoCState.md#daystosettlement)

```js
function daysToSettlement() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

