---
id: version-0.1.10-MoCLibConnection
title: MoCLibConnection
original_id: MoCLibConnection
---

# MoCLibConnection.sol

View Source: [contracts/MoCLibConnection.sol](../contracts/MoCLibConnection.sol)

**↘ Derived Contracts: [MoC](MoC.md), [MoCConverter](MoCConverter.md), [MoCEvents](MoCEvents.md), [MoCExchange](MoCExchange.md), [MoCExchangeEvents](MoCExchangeEvents.md), [MoCHelperLibHarness](MoCHelperLibHarness.md), [MoCInrate](MoCInrate.md), [MoCInrateEvents](MoCInrateEvents.md), [MoCInrateStructs](MoCInrateStructs.md), [MoCState](MoCState.md), [MoCVendors](MoCVendors.md), [MoCVendorsEvents](MoCVendorsEvents.md)**

**MoCLibConnection** - version: 0.1.10

Interface with MocHelperLib

## Contract Members
**Constants & Variables**

```js
//internal members
struct MoCHelperLib.MocLibConfig internal mocLibConfig;

//private members
uint256[50] private upgradeGap;

```

## Functions

- [getMocPrecision()](#getmocprecision)
- [getReservePrecision()](#getreserveprecision)
- [getDayPrecision()](#getdayprecision)
- [initializePrecisions()](#initializeprecisions)

### getMocPrecision

```js
function getMocPrecision() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getReservePrecision

```js
function getReservePrecision() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getDayPrecision

```js
function getDayPrecision() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### initializePrecisions

```js
function initializePrecisions() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

