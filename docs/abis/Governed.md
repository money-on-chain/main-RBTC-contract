---
id: version-0.1.12-Governed
title: Governed
original_id: Governed
---

# Governed (Governed.sol)

View Source: [moc-governance/contracts/Governance/Governed.sol](../../moc-governance/contracts/Governance/Governed.sol)

**↗ Extends: [Initializable](Initializable.md)**
**↘ Derived Contracts: [CommissionSplitter](CommissionSplitter.md), [MoCBucketContainer](MoCBucketContainer.md), [MoCEMACalculator](MoCEMACalculator.md), [MoCInrate](MoCInrate.md), [MoCInrateEvents](MoCInrateEvents.md), [MoCInrateStructs](MoCInrateStructs.md), [MoCSettlement](MoCSettlement.md), [MoCSettlementEvents](MoCSettlementEvents.md), [MoCVendors](MoCVendors.md), [MoCVendorsEvents](MoCVendorsEvents.md), [Stoppable](Stoppable.md), [UpgradeDelegator](UpgradeDelegator.md)**

**Governed** - version: 0.1.12

Base contract to be inherited by governed contractsThis contract is not usable on its own since it does not have any _productive useful_ behaviour
The only purpose of this contract is to define some useful modifiers and functions to be used on the
governance aspect of the child contract

## Contract Members
**Constants & Variables**

```js
contract IGovernor public governor;
```
---

```js
string private constant NOT_AUTHORIZED_CHANGER;
```
---

```js
uint256[50] private upgradeGap;
```
---

## Modifiers

- [onlyAuthorizedChanger](#onlyauthorizedchanger)

### onlyAuthorizedChanger

Modifier that protects the functionYou should use this modifier in any function that should be called through
the governance system

```js
modifier onlyAuthorizedChanger() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [initialize(IGovernor _governor)](#initialize)
- [changeIGovernor(IGovernor newIGovernor)](#changeigovernor)

### initialize

Initialize the contract with the basic settingsThis initialize replaces the constructor but it is not called automatically.
It is necessary because of the upgradeability of the contracts

```js
function initialize(IGovernor _governor) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _governor | IGovernor | Governor address | 

### changeIGovernor

Change the contract's governor. Should be called through the old governance system

```js
function changeIGovernor(IGovernor newIGovernor) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newIGovernor | IGovernor | New governor address | 

