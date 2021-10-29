---
id: version-0.1.12-Stoppable
title: Stoppable
original_id: Stoppable
---

# Stoppable (Stoppable.sol)

View Source: [moc-governance/contracts/Stopper/Stoppable.sol](../../moc-governance/contracts/Stopper/Stoppable.sol)

**↗ Extends: [Governed](Governed.md)**
**↘ Derived Contracts: [MoC](MoC.md), [MoCEvents](MoCEvents.md)**

**Stoppable** - version: 0.1.12

Allow a contract to be paused through the stopper subsystem. This contracts
is able to disable the stoppability feature through governance.This contract was heavily based on the _Pausable_ contract of openzeppelin-eth but
it was modified in order to being able to turn on and off its stopability

## Contract Members
**Constants & Variables**

```js
bool public stoppable;
```
---

```js
address public stopper;
```
---

```js
bool private _paused;
```
---

```js
string private constant UNSTOPPABLE;
```
---

```js
string private constant CONTRACT_IS_ACTIVE;
```
---

```js
string private constant CONTRACT_IS_PAUSED;
```
---

```js
string private constant NOT_STOPPER;
```
---

```js
uint256[50] private upgradeGap;
```
---

## Paused

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

## Unpaused

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

## Modifiers

- [whenStoppable](#whenstoppable)
- [whenNotPaused](#whennotpaused)
- [whenPaused](#whenpaused)
- [onlyPauser](#onlypauser)

### whenStoppable

Modifier to make a function callable only when the contract is enable
to be paused

```js
modifier whenStoppable() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### whenNotPaused

Modifier to make a function callable only when the contract is not paused

```js
modifier whenNotPaused() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### whenPaused

Modifier to make a function callable only when the contract is paused

```js
modifier whenPaused() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### onlyPauser

Modifier to make a function callable only by the pauser

```js
modifier onlyPauser() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [initialize(address _stopper, IGovernor _governor)](#initialize)
- [initialize(address _stopper, IGovernor _governor, bool _stoppable)](#initialize)
- [paused()](#paused)
- [pause()](#pause)
- [unpause()](#unpause)
- [makeUnstoppable()](#makeunstoppable)
- [makeStoppable()](#makestoppable)
- [setStopper(address newStopper)](#setstopper)

### initialize

Initialize the contract with the basic settingsThis initialize replaces the constructor but it is not called automatically.
It is necessary because of the upgradeability of the contracts. Either this function or the next can be used

```js
function initialize(address _stopper, IGovernor _governor) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _stopper | address | The address that is authorized to stop this contract | 
| _governor | IGovernor | The address that will define when a change contract is authorized to do this unstoppable/stoppable again | 

### initialize

Initialize the contract with the basic settingsThis initialize replaces the constructor but it is not called automatically.
It is necessary because of the upgradeability of the contracts. Either this function or the previous can be used

```js
function initialize(address _stopper, IGovernor _governor, bool _stoppable) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _stopper | address | The address that is authorized to stop this contract | 
| _governor | IGovernor | The address that will define when a change contract is authorized to do this unstoppable/stoppable again | 
| _stoppable | bool | Define if the contract starts being unstoppable or not | 

### paused

Returns true if paused

```js
function paused() public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### pause

Called by the owner to pause, triggers stopped stateShould only be called by the pauser and when it is stoppable

```js
function pause() public nonpayable whenStoppable onlyPauser whenNotPaused 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### unpause

Called by the owner to unpause, returns to normal state

```js
function unpause() public nonpayable onlyPauser whenPaused 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### makeUnstoppable

Switches OFF the stoppability of the contract; if the contract was paused
it will no longer be soShould be called through governance

```js
function makeUnstoppable() public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### makeStoppable

Switches ON the stoppability of the contract; if the contract was paused
before making it unstoppable it will be paused again after calling this functionShould be called through governance

```js
function makeStoppable() public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setStopper

Changes the address which is enable to stop this contractShould be called through governance

```js
function setStopper(address newStopper) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newStopper | address | Address of the newStopper | 

