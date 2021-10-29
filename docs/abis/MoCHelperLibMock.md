---
id: version-0.1.12-MoCHelperLibMock
title: MoCHelperLibMock
original_id: MoCHelperLibMock
---

# MoCHelperLibMock.sol

View Source: [contracts/mocks/MoCHelperLibMock.sol](../../contracts/mocks/MoCHelperLibMock.sol)

**MoCHelperLibMock** - version: 0.1.12

## Contract Members
**Constants & Variables**

```js
struct MoCHelperLib.MocLibConfig internal mocLibConfig;
```
---

## MethodCalled

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| name | bytes32 |  | 

## Functions

- [()](#mochelperlibmocksol)
- [spotInrate(uint256 tMin, uint256 tMax, uint256 doc0, uint256 doct)](#spotinrate)
- [maxBProWithDiscount(uint256 nB, uint256 nDoc, uint256 utpdu, uint256 peg, uint256 btcPrice, uint256 bproUsdPrice, uint256 spotDiscount)](#maxbprowithdiscount)
- [inrateAvg(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat1, uint256 abRat2)](#inrateavg)
- [avgInt(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat1, uint256 abRat2)](#avgint)
- [potential(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat)](#potential)
- [integral(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat)](#integral)
- [bproSpotDiscountRate(uint256 bproLiqDiscountRate, uint256 liq, uint256 utpdu, uint256 cov)](#bprospotdiscountrate)
- [bucketTransferAmountInfiniteLeverage(uint256 nB, uint256 delta)](#buckettransferamountinfiniteleverage)
- [bucketTransferAmount(uint256 nB, uint256 lev)](#buckettransferamount)
- [coverage(uint256 nB, uint256 lB)](#coverage)
- [leverageFromCoverage(uint256 cov)](#leveragefromcoverage)
- [leverage(uint256 nB, uint256 lB)](#leverage)
- [maxBProxBtcValue(uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 lev)](#maxbproxbtcvalue)
- [maxBProxBtcValueInfiniteLeverage(uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 delta)](#maxbproxbtcvalueinfiniteleverage)

### 

Constructor

```js
function () public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### spotInrate

```js
function spotInrate(uint256 tMin, uint256 tMax, uint256 doc0, uint256 doct) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| tMin | uint256 |  | 
| tMax | uint256 |  | 
| doc0 | uint256 |  | 
| doct | uint256 |  | 

### maxBProWithDiscount

```js
function maxBProWithDiscount(uint256 nB, uint256 nDoc, uint256 utpdu, uint256 peg, uint256 btcPrice, uint256 bproUsdPrice, uint256 spotDiscount) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| nB | uint256 |  | 
| nDoc | uint256 |  | 
| utpdu | uint256 |  | 
| peg | uint256 |  | 
| btcPrice | uint256 |  | 
| bproUsdPrice | uint256 |  | 
| spotDiscount | uint256 |  | 

### inrateAvg

```js
function inrateAvg(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat1, uint256 abRat2) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| tMax | uint256 |  | 
| fact | uint256 |  | 
| tMin | uint256 |  | 
| abRat1 | uint256 |  | 
| abRat2 | uint256 |  | 

### avgInt

```js
function avgInt(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat1, uint256 abRat2) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| tMax | uint256 |  | 
| fact | uint256 |  | 
| tMin | uint256 |  | 
| abRat1 | uint256 |  | 
| abRat2 | uint256 |  | 

### potential

```js
function potential(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| tMax | uint256 |  | 
| fact | uint256 |  | 
| tMin | uint256 |  | 
| abRat | uint256 |  | 

### integral

```js
function integral(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| tMax | uint256 |  | 
| fact | uint256 |  | 
| tMin | uint256 |  | 
| abRat | uint256 |  | 

### bproSpotDiscountRate

```js
function bproSpotDiscountRate(uint256 bproLiqDiscountRate, uint256 liq, uint256 utpdu, uint256 cov) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproLiqDiscountRate | uint256 |  | 
| liq | uint256 |  | 
| utpdu | uint256 |  | 
| cov | uint256 |  | 

### bucketTransferAmountInfiniteLeverage

```js
function bucketTransferAmountInfiniteLeverage(uint256 nB, uint256 delta) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| nB | uint256 |  | 
| delta | uint256 |  | 

### bucketTransferAmount

```js
function bucketTransferAmount(uint256 nB, uint256 lev) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| nB | uint256 |  | 
| lev | uint256 |  | 

### coverage

```js
function coverage(uint256 nB, uint256 lB) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| nB | uint256 |  | 
| lB | uint256 |  | 

### leverageFromCoverage

```js
function leverageFromCoverage(uint256 cov) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| cov | uint256 |  | 

### leverage

```js
function leverage(uint256 nB, uint256 lB) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| nB | uint256 |  | 
| lB | uint256 |  | 

### maxBProxBtcValue

```js
function maxBProxBtcValue(uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 lev) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| nDoc | uint256 |  | 
| peg | uint256 |  | 
| btcPrice | uint256 |  | 
| lev | uint256 |  | 

### maxBProxBtcValueInfiniteLeverage

```js
function maxBProxBtcValueInfiniteLeverage(uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 delta) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| nDoc | uint256 |  | 
| peg | uint256 |  | 
| btcPrice | uint256 |  | 
| delta | uint256 |  | 

