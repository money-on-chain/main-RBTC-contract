---
id: version-0.1.12-MoCBucketContainer
title: MoCBucketContainer
original_id: MoCBucketContainer
---

# MoCBucketContainer.sol

View Source: [contracts/MoCBucketContainer.sol](../../contracts/MoCBucketContainer.sol)

**↗ Extends: [MoCBase](MoCBase.md), [Governed](Governed.md)**
**↘ Derived Contracts: [MoCBProxManager](MoCBProxManager.md)**

**MoCBucketContainer** - version: 0.1.12

## Structs
### BProxBalance

```js
struct BProxBalance {
 uint256 value,
 uint256 index
}
```

### MoCBucket

```js
struct MoCBucket {
 bytes32 name,
 bool isBase,
 uint256 nDoc,
 uint256 nBPro,
 uint256 nBTC,
 uint256 cobj,
 mapping(address => struct MoCBucketContainer.BProxBalance) bproxBalances,
 address payable[] activeBalances,
 uint256 activeBalancesLength,
 uint256 inrateBag,
 bool available
}
```

## Contract Members
**Constants & Variables**

```js
mapping(bytes32 => struct MoCBucketContainer.MoCBucket) internal mocBuckets;
```
---

```js
uint256[50] private upgradeGap;
```
---

## BucketMovement

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| from | bytes32 |  | 
| to | bytes32 |  | 
| reserves | uint256 |  | 
| stableTokens | uint256 |  | 

## BucketCreation

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| name | bytes32 |  | 
| cobj | uint256 |  | 

## BucketStateUpdate

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| name | bytes32 |  | 
| nReserve | uint256 |  | 
| nStable | uint256 |  | 
| nRiskProx | uint256 |  | 
| inrateBag | uint256 |  | 

## Modifiers

- [onlyBaseBucket](#onlybasebucket)
- [bucketStateUpdate](#bucketstateupdate)

### onlyBaseBucket

```js
modifier onlyBaseBucket(bytes32 bucket) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### bucketStateUpdate

```js
modifier bucketStateUpdate(bytes32 bucket) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

## Functions

- [getBucketNBTC(bytes32 bucket)](#getbucketnbtc)
- [getBucketNBPro(bytes32 bucket)](#getbucketnbpro)
- [getBucketNDoc(bytes32 bucket)](#getbucketndoc)
- [getBucketCobj(bytes32 bucket)](#getbucketcobj)
- [getInrateBag(bytes32 bucket)](#getinratebag)
- [setBucketCobj(bytes32 _bucket, uint256 _cobj)](#setbucketcobj)
- [isBucketBase(bytes32 bucket)](#isbucketbase)
- [isBucketEmpty(bytes32 bucket)](#isbucketempty)
- [getActiveAddresses(bytes32 bucket)](#getactiveaddresses)
- [getActiveAddressesCount(bytes32 bucket)](#getactiveaddressescount)
- [addValuesToBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox)](#addvaluestobucket)
- [substractValuesFromBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox)](#substractvaluesfrombucket)
- [deliverInrate(bytes32 bucketName, uint256 amount)](#deliverinrate)
- [recoverInrate(bytes32 bucketName, uint256 amount)](#recoverinrate)
- [payInrate(bytes32 bucketName, uint256 btcAmount)](#payinrate)
- [moveBtcAndDocs(bytes32 from, bytes32 to, uint256 btc, uint256 docs)](#movebtcanddocs)
- [liquidateBucket(bytes32 toLiquidate, bytes32 destination)](#liquidatebucket)
- [emptyBucket(bytes32 origin, bytes32 destination)](#emptybucket)
- [isAvailableBucket(bytes32 bucket)](#isavailablebucket)
- [clearBucketBalances(bytes32 bucketName)](#clearbucketbalances)
- [createBucket(bytes32 name, uint256 cobj, bool isBase)](#createbucket)

### getBucketNBTC

```js
function getBucketNBTC(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getBucketNBPro

```js
function getBucketNBPro(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getBucketNDoc

```js
function getBucketNDoc(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getBucketCobj

```js
function getBucketCobj(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getInrateBag

```js
function getInrateBag(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### setBucketCobj

Sets the objective coverage (cobj) on an specficied bucket.

```js
function setBucketCobj(bytes32 _bucket, uint256 _cobj) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _bucket | bytes32 |  | 
| _cobj | uint256 |  | 

### isBucketBase

returns true if the bucket is a base bucket

```js
function isBucketBase(bytes32 bucket) public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket | 

### isBucketEmpty

returns true if the bucket have docs in it

```js
function isBucketEmpty(bytes32 bucket) public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket | 

### getActiveAddresses

Returns all the address that currently have bprox position for this bucket

```js
function getActiveAddresses(bytes32 bucket) public view
returns(address payable[])
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | bucket of the active address | 

### getActiveAddressesCount

Returns all the address that currently have bprox position for this bucket

```js
function getActiveAddressesCount(bytes32 bucket) public view
returns(count uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | bucket of the active address | 

### addValuesToBucket

Add values to all variables of the bucket

```js
function addValuesToBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucketName | bytes32 | Name of the bucket | 
| btc | uint256 | BTC amount [using reservePrecision] | 
| doc | uint256 | Doc amount [using mocPrecision] | 
| bprox | uint256 | BPro amount [using mocPrecision] | 

### substractValuesFromBucket

Substract values to all variables of the bucket

```js
function substractValuesFromBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucketName | bytes32 | Name of the bucket | 
| btc | uint256 | BTC amount [using reservePrecision] | 
| doc | uint256 | Doc amount [using mocPrecision] | 
| bprox | uint256 | BPro amount [using mocPrecision] | 

### deliverInrate

Moves BTC from inrateBag to main BTC bucket bag

```js
function deliverInrate(bytes32 bucketName, uint256 amount) public nonpayable onlyWhitelisted onlyBaseBucket bucketStateUpdate 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucketName | bytes32 | Name of the bucket to operate | 
| amount | uint256 | value to move from inrateBag to main bag [using reservePrecision] | 

### recoverInrate

Removes Interests rate from Inrate bag

```js
function recoverInrate(bytes32 bucketName, uint256 amount) public nonpayable onlyWhitelisted onlyBaseBucket bucketStateUpdate 
returns(uint256)
```

**Returns**

Retrieved value

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucketName | bytes32 | Name of the bucket to operate | 
| amount | uint256 | value to move from inrateBag to main bag [using reservePrecision] | 

### payInrate

Moves BTC from origin bucket to destination bucket inrateBag

```js
function payInrate(bytes32 bucketName, uint256 btcAmount) public nonpayable onlyWhitelisted onlyBaseBucket 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucketName | bytes32 | name of the bucket to from which takes | 
| btcAmount | uint256 | value to add to main bag [using reservePrecision] | 

### moveBtcAndDocs

Move Btcs and Docs from one bucket to another

```js
function moveBtcAndDocs(bytes32 from, bytes32 to, uint256 btc, uint256 docs) public nonpayable onlyWhitelisted bucketStateUpdate bucketStateUpdate 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| from | bytes32 | Name of bucket from where the BTCs will be removed | 
| to | bytes32 | Name of bucket from where the BTCs will be added | 
| btc | uint256 | BTCs amount [using reservePrecision] | 
| docs | uint256 | Docs amount [using mocPrecision] | 

### liquidateBucket

Clears completely the origin bucket, removing all Docs, RBTCs and bproxs

```js
function liquidateBucket(bytes32 toLiquidate, bytes32 destination) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| toLiquidate | bytes32 | Bucket to be cleared out | 
| destination | bytes32 | Bucket that will receive the Docs and RBTCs | 

### emptyBucket

Clears Docs and BTC from bucket origin and sends them to destination bucket

```js
function emptyBucket(bytes32 origin, bytes32 destination) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| origin | bytes32 | Bucket to clear out | 
| destination | bytes32 | Destination bucket | 

### isAvailableBucket

checks if a bucket exists

```js
function isAvailableBucket(bytes32 bucket) public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | name of the bucket | 

### clearBucketBalances

Put all bucket BProx balances in zero

```js
function clearBucketBalances(bytes32 bucketName) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucketName | bytes32 | Bucket to clear out | 

### createBucket

Creates bucket

```js
function createBucket(bytes32 name, uint256 cobj, bool isBase) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| name | bytes32 | Name of the bucket | 
| cobj | uint256 | Target Coverage of the bucket | 
| isBase | bool | Indicates if it is a base bucket (true) or not (false) | 

