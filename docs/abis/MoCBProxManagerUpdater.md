---
id: version-0.1.10-MoCBProxManagerUpdater
title: MoCBProxManagerUpdater
original_id: MoCBProxManagerUpdater
---

# MoCBProxManagerUpdater.sol

View Source: [contracts/changers/productive/MoCBProxManagerUpdater.sol](../../contracts/changers/productive/MoCBProxManagerUpdater.sol)

**↗ Extends: [UpgraderTemplate](UpgraderTemplate.md)**

**MoCBProxManagerUpdater** - version: 0.1.10

This contract is used to update the MoCBProxManager to fix the governor variable

## Contract Members
**Constants & Variables**

```js
contract AdminUpgradeabilityProxy public proxy;
contract UpgradeDelegator public upgradeDelegator;
address public newImplementation;

```

## Functions

- [(AdminUpgradeabilityProxy _proxy, UpgradeDelegator _upgradeDelegator, address _newImplementation)](#)

### 

Constructor

```js
function (AdminUpgradeabilityProxy _proxy, UpgradeDelegator _upgradeDelegator, address _newImplementation) public nonpayable UpgraderTemplate 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _proxy | AdminUpgradeabilityProxy | Address of the proxy to be upgraded | 
| _upgradeDelegator | UpgradeDelegator | Address of the upgradeDelegator in charge of that proxy | 
| _newImplementation | address | Address of the contract the proxy will delegate to | 

