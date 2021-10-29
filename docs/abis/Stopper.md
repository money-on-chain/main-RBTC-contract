---
id: version-0.1.12-Stopper
title: Stopper
original_id: Stopper
---

# Stopper (Stopper.sol)

View Source: [moc-governance/contracts/Stopper/Stopper.sol](../../moc-governance/contracts/Stopper/Stopper.sol)

**↗ Extends: [Ownable](Ownable.md)**
**↘ Derived Contracts: [MockStopper](MockStopper.md)**

**Stopper** - version: 0.1.12

The contract in charge of handling the stoppability of the contract
that define this contract as its stopper

## Contract Members
**Constants & Variables**

```js
uint256[50] private upgradeGap;
```
---

## Functions

- [pause(Stoppable activeContract)](#pause)
- [unpause(Stoppable pausedContract)](#unpause)

### pause

Pause activeContract if it is stoppable

```js
function pause(Stoppable activeContract) external nonpayable onlyOwner 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| activeContract | Stoppable | Contract to be paused | 

### unpause

Unpause pausedContract if it is stoppable

```js
function unpause(Stoppable pausedContract) external nonpayable onlyOwner 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| pausedContract | Stoppable | Contract to be unpaused | 

