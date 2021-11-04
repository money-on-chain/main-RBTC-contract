---
id: version-0.1.12-MoCBProxManager
title: MoCBProxManager
original_id: MoCBProxManager
---

# MoCBProxManager.sol

View Source: [contracts/MoCBProxManager.sol](../../contracts/MoCBProxManager.sol)

**↗ Extends: [MoCBucketContainer](MoCBucketContainer.md)**

**MoCBProxManager** - version: 0.1.12

## Contract Members
**Constants & Variables**

```js
uint256 internal constant MIN_ALLOWED_BALANCE;
```
---

```js
uint256[50] private upgradeGap;
```
---

## Functions

- [initialize(address connectorAddress, address _governor, uint256 _c0Cobj, uint256 _x2Cobj)](#initialize)
- [bproxBalanceOf(bytes32 bucket, address userAddress)](#bproxbalanceof)
- [hasValidBalance(bytes32 bucket, address userAddress, uint256 index)](#hasvalidbalance)
- [assignBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 totalCost)](#assignbprox)
- [removeBProx(bytes32 bucket, address payable userAddress, uint256 bproxAmount, uint256 totalCost)](#removebprox)
- [setBProxBalanceOf(bytes32 bucket, address payable userAddress, uint256 value)](#setbproxbalanceof)
- [initializeValues(address _governor)](#initializevalues)

### initialize

Initializes the contract

```js
function initialize(address connectorAddress, address _governor, uint256 _c0Cobj, uint256 _x2Cobj) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| connectorAddress | address | MoCConnector contract address | 
| _governor | address | Governor contract address | 
| _c0Cobj | uint256 | Bucket C0 objective coverage | 
| _x2Cobj | uint256 | Bucket X2 objective coverage | 

### bproxBalanceOf

returns user balance

```js
function bproxBalanceOf(bytes32 bucket, address userAddress) public view
returns(uint256)
```

**Returns**

total balance for the userAddress

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | BProx corresponding bucket to get balance from | 
| userAddress | address | user address to get balance from | 

### hasValidBalance

verifies that this user has assigned balance for the given bucket

```js
function hasValidBalance(bytes32 bucket, address userAddress, uint256 index) public view
returns(bool)
```

**Returns**

true if the user has assigned balance

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | corresponding Leveraged bucket to get balance from | 
| userAddress | address | user address to verify balance for | 
| index | uint256 | index, starting from 1, where the address of the user is being kept | 

### assignBProx

Assigns the amount of BProx

```js
function assignBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 totalCost) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | bucket from which the BProx will be removed | 
| account | address payable | user address to redeem for | 
| bproxAmount | uint256 | bprox amount to redeem [using mocPresicion] | 
| totalCost | uint256 | btc value of bproxAmount [using reservePrecision] | 

### removeBProx

Removes the amount of BProx and substract BTC cost from bucket

```js
function removeBProx(bytes32 bucket, address payable userAddress, uint256 bproxAmount, uint256 totalCost) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | bucket from which the BProx will be removed | 
| userAddress | address payable | user address to redeem for | 
| bproxAmount | uint256 | bprox amount to redeem [using mocPresicion] | 
| totalCost | uint256 | btc value of bproxAmount [using reservePrecision] | 

### setBProxBalanceOf

Sets the amount of BProx

```js
function setBProxBalanceOf(bytes32 bucket, address payable userAddress, uint256 value) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | bucket from which the BProx will be setted | 
| userAddress | address payable | user address to redeem for | 
| value | uint256 | bprox amount to redeem [using mocPresicion] | 

### initializeValues

intializes values of the contract

```js
function initializeValues(address _governor) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _governor | address | Governor contract address | 

