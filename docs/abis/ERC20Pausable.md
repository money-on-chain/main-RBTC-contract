---
id: version-0.1.12-ERC20Pausable
title: ERC20Pausable
original_id: ERC20Pausable
---

# Pausable token (ERC20Pausable.sol)

View Source: [openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol](../../openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol)

**↗ Extends: [ERC20](ERC20.md), [Pausable](Pausable.md)**
**↘ Derived Contracts: [BProToken](BProToken.md)**

**ERC20Pausable** - version: 0.1.12

ERC20 modified with pausable transfers.

## Functions

- [transfer(address to, uint256 value)](#transfer)
- [transferFrom(address from, address to, uint256 value)](#transferfrom)
- [approve(address spender, uint256 value)](#approve)
- [increaseAllowance(address spender, uint256 addedValue)](#increaseallowance)
- [decreaseAllowance(address spender, uint256 subtractedValue)](#decreaseallowance)

### transfer

⤾ overrides [ERC20.transfer](ERC20.md#transfer)

```js
function transfer(address to, uint256 value) public nonpayable whenNotPaused 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| to | address |  | 
| value | uint256 |  | 

### transferFrom

⤾ overrides [ERC20.transferFrom](ERC20.md#transferfrom)

```js
function transferFrom(address from, address to, uint256 value) public nonpayable whenNotPaused 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| from | address |  | 
| to | address |  | 
| value | uint256 |  | 

### approve

⤾ overrides [ERC20.approve](ERC20.md#approve)

```js
function approve(address spender, uint256 value) public nonpayable whenNotPaused 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| spender | address |  | 
| value | uint256 |  | 

### increaseAllowance

⤾ overrides [ERC20.increaseAllowance](ERC20.md#increaseallowance)

```js
function increaseAllowance(address spender, uint256 addedValue) public nonpayable whenNotPaused 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| spender | address |  | 
| addedValue | uint256 |  | 

### decreaseAllowance

⤾ overrides [ERC20.decreaseAllowance](ERC20.md#decreaseallowance)

```js
function decreaseAllowance(address spender, uint256 subtractedValue) public nonpayable whenNotPaused 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| spender | address |  | 
| subtractedValue | uint256 |  | 

