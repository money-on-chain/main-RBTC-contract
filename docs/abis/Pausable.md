---
id: version-0.1.12-Pausable
title: Pausable
original_id: Pausable
---

# Pausable.sol

View Source: [openzeppelin-solidity/contracts/lifecycle/Pausable.sol](../../openzeppelin-solidity/contracts/lifecycle/Pausable.sol)

**↗ Extends: [PauserRole](PauserRole.md)**
**↘ Derived Contracts: [ERC20Pausable](ERC20Pausable.md)**

**Pausable** - version: 0.1.12

Contract module which allows children to implement an emergency stop
mechanism that can be triggered by an authorized account.
 * This module is used through inheritance. It will make available the
modifiers `whenNotPaused` and `whenPaused`, which can be applied to
the functions of your contract. Note that they will not be pausable by
simply including this module, only once the modifiers are put in place.

## Contract Members
**Constants & Variables**

```js
bool private _paused;
```
---

## Paused

Emitted when the pause is triggered by a pauser (`account`).

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

## Unpaused

Emitted when the pause is lifted by a pauser (`account`).

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

## Modifiers

- [whenNotPaused](#whennotpaused)
- [whenPaused](#whenpaused)

### whenNotPaused

Modifier to make a function callable only when the contract is not paused.

```js
modifier whenNotPaused() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### whenPaused

Modifier to make a function callable only when the contract is paused.

```js
modifier whenPaused() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [()](#pausablesol)
- [paused()](#paused)
- [pause()](#pause)
- [unpause()](#unpause)

### 

Initializes the contract in unpaused state. Assigns the Pauser role
to the deployer.

```js
function () internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### paused

Returns true if the contract is paused, and false otherwise.

```js
function paused() public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### pause

Called by a pauser to pause, triggers stopped state.

```js
function pause() public nonpayable onlyPauser whenNotPaused 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### unpause

Called by a pauser to unpause, returns to normal state.

```js
function unpause() public nonpayable onlyPauser whenPaused 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

