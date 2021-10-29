---
id: version-0.1.12-ERC20
title: ERC20
original_id: ERC20
---

# ERC20.sol

View Source: [openzeppelin-solidity/contracts/token/ERC20/ERC20.sol](../../openzeppelin-solidity/contracts/token/ERC20/ERC20.sol)

**↗ Extends: [IERC20](IERC20.md)**
**↘ Derived Contracts: [ERC20Mintable](ERC20Mintable.md), [ERC20Pausable](ERC20Pausable.md)**

**ERC20** - version: 0.1.12

Implementation of the `IERC20` interface.
 * This implementation is agnostic to the way tokens are created. This means
that a supply mechanism has to be added in a derived contract using `_mint`.
For a generic mechanism see `ERC20Mintable`.
 * *For a detailed writeup see our guide [How to implement supply
mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 * We have followed general OpenZeppelin guidelines: functions revert instead
of returning `false` on failure. This behavior is nonetheless conventional
and does not conflict with the expectations of ERC20 applications.
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
This allows applications to reconstruct the allowance for all accounts just
by listening to said events. Other implementations of the EIP may not emit
these events, as it isn't required by the specification.
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
functions have been added to mitigate the well-known issues around setting
allowances. See `IERC20.approve`.

## Contract Members
**Constants & Variables**

```js
mapping(address => uint256) private _balances;
```
---

```js
mapping(address => mapping(address => uint256)) private _allowances;
```
---

```js
uint256 private _totalSupply;
```
---

## Functions

- [totalSupply()](#totalsupply)
- [balanceOf(address account)](#balanceof)
- [transfer(address recipient, uint256 amount)](#transfer)
- [allowance(address owner, address spender)](#allowance)
- [approve(address spender, uint256 value)](#approve)
- [transferFrom(address sender, address recipient, uint256 amount)](#transferfrom)
- [increaseAllowance(address spender, uint256 addedValue)](#increaseallowance)
- [decreaseAllowance(address spender, uint256 subtractedValue)](#decreaseallowance)
- [_transfer(address sender, address recipient, uint256 amount)](#_transfer)
- [_mint(address account, uint256 amount)](#_mint)
- [_burn(address account, uint256 value)](#_burn)
- [_approve(address owner, address spender, uint256 value)](#_approve)
- [_burnFrom(address account, uint256 amount)](#_burnfrom)

### totalSupply

⤾ overrides [IERC20.totalSupply](IERC20.md#totalsupply)

See `IERC20.totalSupply`.

```js
function totalSupply() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### balanceOf

⤾ overrides [IERC20.balanceOf](IERC20.md#balanceof)

See `IERC20.balanceOf`.

```js
function balanceOf(address account) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

### transfer

⤾ overrides [IERC20.transfer](IERC20.md#transfer)

⤿ Overridden Implementation(s): [ERC20Pausable.transfer](ERC20Pausable.md#transfer)

See `IERC20.transfer`.
     * Requirements:
     * - `recipient` cannot be the zero address.
- the caller must have a balance of at least `amount`.

```js
function transfer(address recipient, uint256 amount) public nonpayable
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| recipient | address |  | 
| amount | uint256 |  | 

### allowance

⤾ overrides [IERC20.allowance](IERC20.md#allowance)

See `IERC20.allowance`.

```js
function allowance(address owner, address spender) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| owner | address |  | 
| spender | address |  | 

### approve

⤾ overrides [IERC20.approve](IERC20.md#approve)

⤿ Overridden Implementation(s): [ERC20Pausable.approve](ERC20Pausable.md#approve)

See `IERC20.approve`.
     * Requirements:
     * - `spender` cannot be the zero address.

```js
function approve(address spender, uint256 value) public nonpayable
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| spender | address |  | 
| value | uint256 |  | 

### transferFrom

⤾ overrides [IERC20.transferFrom](IERC20.md#transferfrom)

⤿ Overridden Implementation(s): [ERC20Pausable.transferFrom](ERC20Pausable.md#transferfrom)

See `IERC20.transferFrom`.
     * Emits an `Approval` event indicating the updated allowance. This is not
required by the EIP. See the note at the beginning of `ERC20`;
     * Requirements:
- `sender` and `recipient` cannot be the zero address.
- `sender` must have a balance of at least `value`.
- the caller must have allowance for `sender`'s tokens of at least
`amount`.

```js
function transferFrom(address sender, address recipient, uint256 amount) public nonpayable
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| sender | address |  | 
| recipient | address |  | 
| amount | uint256 |  | 

### increaseAllowance

⤿ Overridden Implementation(s): [ERC20Pausable.increaseAllowance](ERC20Pausable.md#increaseallowance)

Atomically increases the allowance granted to `spender` by the caller.
     * This is an alternative to `approve` that can be used as a mitigation for
problems described in `IERC20.approve`.
     * Emits an `Approval` event indicating the updated allowance.
     * Requirements:
     * - `spender` cannot be the zero address.

```js
function increaseAllowance(address spender, uint256 addedValue) public nonpayable
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| spender | address |  | 
| addedValue | uint256 |  | 

### decreaseAllowance

⤿ Overridden Implementation(s): [ERC20Pausable.decreaseAllowance](ERC20Pausable.md#decreaseallowance)

Atomically decreases the allowance granted to `spender` by the caller.
     * This is an alternative to `approve` that can be used as a mitigation for
problems described in `IERC20.approve`.
     * Emits an `Approval` event indicating the updated allowance.
     * Requirements:
     * - `spender` cannot be the zero address.
- `spender` must have allowance for the caller of at least
`subtractedValue`.

```js
function decreaseAllowance(address spender, uint256 subtractedValue) public nonpayable
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| spender | address |  | 
| subtractedValue | uint256 |  | 

### _transfer

Moves tokens `amount` from `sender` to `recipient`.
     * This is internal function is equivalent to `transfer`, and can be used to
e.g. implement automatic token fees, slashing mechanisms, etc.
     * Emits a `Transfer` event.
     * Requirements:
     * - `sender` cannot be the zero address.
- `recipient` cannot be the zero address.
- `sender` must have a balance of at least `amount`.

```js
function _transfer(address sender, address recipient, uint256 amount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| sender | address |  | 
| recipient | address |  | 
| amount | uint256 |  | 

### _mint

Creates `amount` tokens and assigns them to `account`, increasing
the total supply.
     * Emits a `Transfer` event with `from` set to the zero address.
     * Requirements
     * - `to` cannot be the zero address.

```js
function _mint(address account, uint256 amount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 

### _burn

Destoys `amount` tokens from `account`, reducing the
total supply.
     * Emits a `Transfer` event with `to` set to the zero address.
     * Requirements
     * - `account` cannot be the zero address.
- `account` must have at least `amount` tokens.

```js
function _burn(address account, uint256 value) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| value | uint256 |  | 

### _approve

Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     * This is internal function is equivalent to `approve`, and can be used to
e.g. set automatic allowances for certain subsystems, etc.
     * Emits an `Approval` event.
     * Requirements:
     * - `owner` cannot be the zero address.
- `spender` cannot be the zero address.

```js
function _approve(address owner, address spender, uint256 value) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| owner | address |  | 
| spender | address |  | 
| value | uint256 |  | 

### _burnFrom

Destoys `amount` tokens from `account`.`amount` is then deducted
from the caller's allowance.
     * See `_burn` and `_approve`.

```js
function _burnFrom(address account, uint256 amount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 

