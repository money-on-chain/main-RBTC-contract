---
id: version-0.1.12-IERC20
title: IERC20
original_id: IERC20
---

# IERC20.sol

View Source: [openzeppelin-solidity/contracts/token/ERC20/IERC20.sol](../../openzeppelin-solidity/contracts/token/ERC20/IERC20.sol)

**↘ Derived Contracts: [ERC20](ERC20.md), [ERC20Detailed](ERC20Detailed.md)**

**IERC20** - version: 0.1.12

Interface of the ERC20 standard as defined in the EIP. Does not include
the optional functions; to access them see `ERC20Detailed`.

## Transfer

Emitted when `value` tokens are moved from one account (`from`) to
another (`to`).
     * Note that `value` may be zero.

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| from | address |  | 
| to | address |  | 
| value | uint256 |  | 

## Approval

Emitted when the allowance of a `spender` for an `owner` is set by
a call to `approve`. `value` is the new allowance.

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| owner | address |  | 
| spender | address |  | 
| value | uint256 |  | 

## Functions

- [totalSupply()](#totalsupply)
- [balanceOf(address account)](#balanceof)
- [transfer(address recipient, uint256 amount)](#transfer)
- [allowance(address owner, address spender)](#allowance)
- [approve(address spender, uint256 amount)](#approve)
- [transferFrom(address sender, address recipient, uint256 amount)](#transferfrom)

### totalSupply

⤿ Overridden Implementation(s): [ERC20.totalSupply](ERC20.md#totalsupply)

Returns the amount of tokens in existence.

```js
function totalSupply() external view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### balanceOf

⤿ Overridden Implementation(s): [ERC20.balanceOf](ERC20.md#balanceof)

Returns the amount of tokens owned by `account`.

```js
function balanceOf(address account) external view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

### transfer

⤿ Overridden Implementation(s): [ERC20.transfer](ERC20.md#transfer),[ERC20Pausable.transfer](ERC20Pausable.md#transfer)

Moves `amount` tokens from the caller's account to `recipient`.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a `Transfer` event.

```js
function transfer(address recipient, uint256 amount) external nonpayable
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| recipient | address |  | 
| amount | uint256 |  | 

### allowance

⤿ Overridden Implementation(s): [ERC20.allowance](ERC20.md#allowance)

Returns the remaining number of tokens that `spender` will be
allowed to spend on behalf of `owner` through `transferFrom`. This is
zero by default.
     * This value changes when `approve` or `transferFrom` are called.

```js
function allowance(address owner, address spender) external view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| owner | address |  | 
| spender | address |  | 

### approve

⤿ Overridden Implementation(s): [ERC20.approve](ERC20.md#approve),[ERC20Pausable.approve](ERC20Pausable.md#approve)

Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     * > Beware that changing an allowance with this method brings the risk
that someone may use both the old and the new allowance by unfortunate
transaction ordering. One possible solution to mitigate this race
condition is to first reduce the spender's allowance to 0 and set the
desired value afterwards:
https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * Emits an `Approval` event.

```js
function approve(address spender, uint256 amount) external nonpayable
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| spender | address |  | 
| amount | uint256 |  | 

### transferFrom

⤿ Overridden Implementation(s): [ERC20.transferFrom](ERC20.md#transferfrom),[ERC20Pausable.transferFrom](ERC20Pausable.md#transferfrom)

Moves `amount` tokens from `sender` to `recipient` using the
allowance mechanism. `amount` is then deducted from the caller's
allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a `Transfer` event.

```js
function transferFrom(address sender, address recipient, uint256 amount) external nonpayable
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| sender | address |  | 
| recipient | address |  | 
| amount | uint256 |  | 

