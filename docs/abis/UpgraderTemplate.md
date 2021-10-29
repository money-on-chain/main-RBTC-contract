---
id: version-0.1.12-UpgraderTemplate
title: UpgraderTemplate
original_id: UpgraderTemplate
---

# UpgraderTemplate (UpgraderTemplate.sol)

View Source: [moc-governance/contracts/ChangersTemplates/UpgraderTemplate.sol](../../moc-governance/contracts/ChangersTemplates/UpgraderTemplate.sol)

**↗ Extends: [ChangeContract](ChangeContract.md)**
**↘ Derived Contracts: [MoCBProxManagerUpdater](MoCBProxManagerUpdater.md), [MockUpgraderTemplate](MockUpgraderTemplate.md)**

**UpgraderTemplate** - version: 0.1.12

This contract is a ChangeContract intended to be used when
upgrading any contract upgradeable through the zos-lib upgradeability
system. This doesn't initialize the upgraded contract, that should be done extending
this one or taking it as a guide

## Contract Members
**Constants & Variables**

```js
contract AdminUpgradeabilityProxy public proxy;
```
---

```js
contract UpgradeDelegator public upgradeDelegator;
```
---

```js
address public newImplementation;
```
---

## Functions

- [(AdminUpgradeabilityProxy _proxy, UpgradeDelegator _upgradeDelegator, address _newImplementation)](#upgradertemplatesol)
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

Execute the changes.Should be called by the governor, but this contract does not check that explicitly because it is not its responsability in
the current architecture
IMPORTANT: This function should not be overriden, you should only redefine the _beforeUpgrade and _afterUpgrade to use this template

```js
function execute() external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### _upgrade

Upgrade the proxy to the newImplementationIMPORTANT: This function should not be overriden

```js
function _upgrade() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### _beforeUpgrade

Intended to prepare the system for the upgradeThis function can be overriden by child changers to upgrade contracts that require some preparation before the upgrade

```js
function _beforeUpgrade() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### _afterUpgrade

Intended to do the final tweaks after the upgrade, for example initialize the contractThis function can be overriden by child changers to upgrade contracts that require some changes after the upgrade

```js
function _afterUpgrade() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

