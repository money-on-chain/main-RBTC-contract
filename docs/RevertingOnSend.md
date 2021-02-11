---
id: version-0.1.10-RevertingOnSend
title: RevertingOnSend
original_id: RevertingOnSend
---

# RevertingOnSend.sol

View Source: [contracts/test-contracts/RevertingOnSend.sol](../contracts/test-contracts/RevertingOnSend.sol)

**RevertingOnSend** - version: 0.1.10

## Contract Members
**Constants & Variables**

```js
contract MoC internal moc;
bool internal acceptMoney;

```

## Functions

- [(address payable mocAddress)](#)
- [()](#)
- [setAcceptingMoney(bool accepting)](#setacceptingmoney)
- [mintBProx(bytes32 bucket, uint256 bproxAmountToMint, address vendorAccount)](#mintbprox)
- [mintDoc(uint256 docAmountToMint, address vendorAccount)](#mintdoc)
- [redeemDoCRequest(uint256 docAmount)](#redeemdocrequest)

### 

Constructor

```js
function (address payable mocAddress) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocAddress | address payable | MoC contract address | 

### 

```js
function () external payable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setAcceptingMoney

```js
function setAcceptingMoney(bool accepting) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| accepting | bool |  | 

### mintBProx

```js
function mintBProx(bytes32 bucket, uint256 bproxAmountToMint, address vendorAccount) public payable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 
| bproxAmountToMint | uint256 |  | 
| vendorAccount | address |  | 

### mintDoc

```js
function mintDoc(uint256 docAmountToMint, address vendorAccount) public payable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmountToMint | uint256 |  | 
| vendorAccount | address |  | 

### redeemDoCRequest

```js
function redeemDoCRequest(uint256 docAmount) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmount | uint256 |  | 

