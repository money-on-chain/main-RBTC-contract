---
id: version-0.1.10-MoCWhitelist
title: MoCWhitelist
original_id: MoCWhitelist
---

# MoCWhitelist.sol

View Source: [contracts/base/MoCWhitelist.sol](../../contracts/base/MoCWhitelist.sol)

**↘ Derived Contracts: [MoCConnector](MoCConnector.md)**

**MoCWhitelist** - version: 0.1.10

Provides access control between all MoC Contracts

## Contract Members
**Constants & Variables**

```js
//internal members
mapping(address => bool) internal whitelist;

//private members
uint256[50] private upgradeGap;

```

## Functions

- [isWhitelisted(address account)](#iswhitelisted)
- [add(address account)](#add)
- [remove(address account)](#remove)

### isWhitelisted

Check if an account is whitelisted

```js
function isWhitelisted(address account) public view
returns(bool)
```

**Returns**

Bool

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

### add

Add account to whitelist

```js
function add(address account) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

### remove

Remove account from whitelist

```js
function remove(address account) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

