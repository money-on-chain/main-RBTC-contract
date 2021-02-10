---
id: version-0.1.10-UpgraderTemplate
title: UpgraderTemplate
original_id: UpgraderTemplate
---

# UpgraderTemplate (UpgraderTemplate.sol)

View Source: [moc-governance/contracts/ChangersTemplates/UpgraderTemplate.sol](../moc-governance/contracts/ChangersTemplates/UpgraderTemplate.sol)

**↗ Extends: [ChangeContract](ChangeContract.md)**
**↘ Derived Contracts: [MoCBProxManagerUpdater](MoCBProxManagerUpdater.md), [MockUpgraderTemplate](MockUpgraderTemplate.md)**

**UpgraderTemplate** - version: 0.1.10

This contract is a ChangeContract intended to be used when
upgrading any contract upgradeable through the zos-lib upgradeability
system. This doesn't initialize the upgraded contract, that should be done extending
this one or taking it as a guide

## Contract Members
**Constants & Variables**

```js
contract AdminUpgradeabilityProxy public proxy;
contract UpgradeDelegator public upgradeDelegator;
address public newImplementation;

```

## Functions

- [(AdminUpgradeabilityProxy _proxy, UpgradeDelegator _upgradeDelegator, address _newImplementation)](#)
- [execute()](#execute)
- [_upgrade()](#_upgrade)
- [_beforeUpgrade()](#_beforeupgrade)
- [_afterUpgrade()](#_afterupgrade)

### 

Constructor

```js
function (AdminUpgradeabilityProxy _proxy, UpgradeDelegator _upgradeDelegator, address _newImplementation) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _proxy | AdminUpgradeabilityProxy | Address of the proxy to be upgraded | 
| _upgradeDelegator | UpgradeDelegator | Address of the upgradeDelegator in charge of that proxy | 
| _newImplementation | address | Address of the contract the proxy will delegate to | 

### execute

⤾ overrides ChangeContract.execute

Execute the changes.

```js
function execute() external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### _upgrade

Upgrade the proxy to the newImplementation

```js
function _upgrade() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### _beforeUpgrade

Intended to prepare the system for the upgrade

```js
function _beforeUpgrade() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### _afterUpgrade

Intended to do the final tweaks after the upgrade, for example initialize the contract

```js
function _afterUpgrade() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

