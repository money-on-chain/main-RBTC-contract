---
id: version-0.1.10-MoCConverter
title: MoCConverter
original_id: MoCConverter
---

# MoCConverter.sol

View Source: [contracts/MoCConverter.sol](../contracts/MoCConverter.sol)

**↗ Extends: [MoCBase](MoCBase.md), [MoCLibConnection](MoCLibConnection.md)**

**MoCConverter** - version: 0.1.10

## Contract Members
**Constants & Variables**

```js
//internal members
contract MoCState internal mocState;

//private members
uint256[50] private upgradeGap;

```

## Functions

- [initialize(address connectorAddress)](#initialize)
- [bproToBtc(uint256 amount)](#bprotobtc)
- [btcToBPro(uint256 btcAmount)](#btctobpro)
- [bproDiscToBtc(uint256 amount)](#bprodisctobtc)
- [btcToBProDisc(uint256 btcAmount)](#btctobprodisc)
- [docsToBtc(uint256 docAmount)](#docstobtc)
- [docsToBtcWithPrice(uint256 docAmount, uint256 btcPrice)](#docstobtcwithprice)
- [btcToDoc(uint256 btcAmount)](#btctodoc)
- [bproxToBtc(uint256 bproxAmount, bytes32 bucket)](#bproxtobtc)
- [bproxToBtcHelper(uint256 bproxAmount, bytes32 bucket)](#bproxtobtchelper)
- [btcToBProx(uint256 btcAmount, bytes32 bucket)](#btctobprox)
- [btcToBProWithPrice(uint256 btcAmount, uint256 price)](#btctobprowithprice)
- [bproToBtcWithPrice(uint256 bproAmount, uint256 bproPrice)](#bprotobtcwithprice)
- [mocToBtc(uint256 mocAmount)](#moctobtc)
- [btcToMoC(uint256 btcAmount)](#btctomoc)
- [mocToBtcWithPrice(uint256 mocAmount, uint256 btcPrice, uint256 mocPrice)](#moctobtcwithprice)
- [btcToMoCWithPrice(uint256 btcAmount, uint256 btcPrice, uint256 mocPrice)](#btctomocwithprice)

### initialize

```js
function initialize(address connectorAddress) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| connectorAddress | address |  | 

### bproToBtc

BTC equivalent for the amount of bpros given

```js
function bproToBtc(uint256 amount) public view
returns(uint256)
```

**Returns**

total BTC Price of the amount BPros [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| amount | uint256 | Amount of BPro to calculate the total price | 

### btcToBPro

Converts BTC to BPro

```js
function btcToBPro(uint256 btcAmount) public view
returns(uint256)
```

**Returns**

BPro amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 | BTC amount | 

### bproDiscToBtc

BTC equivalent for the amount of bpro given applying the spotDiscountRate

```js
function bproDiscToBtc(uint256 amount) public view
returns(uint256)
```

**Returns**

BTC amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| amount | uint256 | amount of BPro [using mocPrecision] | 

### btcToBProDisc

```js
function btcToBProDisc(uint256 btcAmount) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 |  | 

### docsToBtc

```js
function docsToBtc(uint256 docAmount) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmount | uint256 |  | 

### docsToBtcWithPrice

```js
function docsToBtcWithPrice(uint256 docAmount, uint256 btcPrice) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmount | uint256 |  | 
| btcPrice | uint256 |  | 

### btcToDoc

```js
function btcToDoc(uint256 btcAmount) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 |  | 

### bproxToBtc

```js
function bproxToBtc(uint256 bproxAmount, bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproxAmount | uint256 |  | 
| bucket | bytes32 |  | 

### bproxToBtcHelper

```js
function bproxToBtcHelper(uint256 bproxAmount, bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproxAmount | uint256 |  | 
| bucket | bytes32 |  | 

### btcToBProx

```js
function btcToBProx(uint256 btcAmount, bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 |  | 
| bucket | bytes32 |  | 

### btcToBProWithPrice

```js
function btcToBProWithPrice(uint256 btcAmount, uint256 price) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 |  | 
| price | uint256 |  | 

### bproToBtcWithPrice

```js
function bproToBtcWithPrice(uint256 bproAmount, uint256 bproPrice) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproAmount | uint256 |  | 
| bproPrice | uint256 |  | 

### mocToBtc

```js
function mocToBtc(uint256 mocAmount) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocAmount | uint256 |  | 

### btcToMoC

```js
function btcToMoC(uint256 btcAmount) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 |  | 

### mocToBtcWithPrice

```js
function mocToBtcWithPrice(uint256 mocAmount, uint256 btcPrice, uint256 mocPrice) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocAmount | uint256 |  | 
| btcPrice | uint256 |  | 
| mocPrice | uint256 |  | 

### btcToMoCWithPrice

```js
function btcToMoCWithPrice(uint256 btcAmount, uint256 btcPrice, uint256 mocPrice) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 |  | 
| btcPrice | uint256 |  | 
| mocPrice | uint256 |  | 

