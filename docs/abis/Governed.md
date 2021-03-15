---
id: version-0.1.10-Governed
title: Governed
original_id: Governed
---

# Governed (Governed.sol)

View Source: [moc-governance/contracts/Governance/Governed.sol](../../moc-governance/contracts/Governance/Governed.sol)

**↗ Extends: [Initializable](Initializable.md)**
**↘ Derived Contracts: [CommissionSplitter](CommissionSplitter.md), [MoCBucketContainer](MoCBucketContainer.md), [MoCEMACalculator](MoCEMACalculator.md), [MoCInrate](MoCInrate.md), [MoCInrateEvents](MoCInrateEvents.md), [MoCInrateStructs](MoCInrateStructs.md), [MoCSettlement](MoCSettlement.md), [MoCSettlementEvents](MoCSettlementEvents.md), [MoCVendors](MoCVendors.md), [MoCVendorsEvents](MoCVendorsEvents.md), [Stoppable](Stoppable.md), [UpgradeDelegator](UpgradeDelegator.md)**

**Governed** - version: 0.1.10

Base contract to be inherited by governed contracts

## Contract Members
**Constants & Variables**

```js
//public members
contract IGovernor public governor;

//private members
string private constant NOT_AUTHORIZED_CHANGER;
uint256[50] private upgradeGap;

```

## Modifiers

- [onlyAuthorizedChanger](#onlyauthorizedchanger)

### onlyAuthorizedChanger

Modifier that protects the function

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

Initialize the contract with the basic settings

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

