---
id: version-0.1.12-UpgradeDelegator
title: UpgradeDelegator
original_id: UpgradeDelegator
---

# UpgradeDelegator (UpgradeDelegator.sol)

View Source: [moc-governance/contracts/Upgradeability/UpgradeDelegator.sol](../../moc-governance/contracts/Upgradeability/UpgradeDelegator.sol)

**↗ Extends: [Governed](Governed.md)**
**↘ Derived Contracts: [MockUpgradeDelegator](MockUpgradeDelegator.md)**

**UpgradeDelegator** - version: 0.1.12

Dispatches to the proxyAdmin any call made through the governance systemAdapter between our governance system and the zeppelinOS proxyAdmin. This is
needed to be able to upgrade governance through the same system

## Contract Members
**Constants & Variables**

```js
contract ProxyAdmin public proxyAdmin;
```
---

## Functions

- [initialize(IGovernor _governor, ProxyAdmin _proxyAdmin)](#initialize)
- [getProxyImplementation(AdminUpgradeabilityProxy proxy)](#getproxyimplementation)
- [getProxyAdmin(AdminUpgradeabilityProxy proxy)](#getproxyadmin)
- [changeProxyAdmin(AdminUpgradeabilityProxy proxy, address newAdmin)](#changeproxyadmin)
- [upgrade(AdminUpgradeabilityProxy proxy, address implementation)](#upgrade)
- [upgradeAndCall(AdminUpgradeabilityProxy proxy, address implementation, bytes data)](#upgradeandcall)

### initialize

Initialize the contract with the basic settingsThis initialize replaces the constructor but it is not called automatically.
It is necessary because of the upgradeability of the contracts

```js
function initialize(IGovernor _governor, ProxyAdmin _proxyAdmin) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _governor | IGovernor | Governor address of this system | 
| _proxyAdmin | ProxyAdmin | ProxyAdmin that we will forward the call to | 

### getProxyImplementation

Returns the current implementation of a proxy.
This is needed because only the proxy admin can query it.

```js
function getProxyImplementation(AdminUpgradeabilityProxy proxy) public view
returns(address)
```

**Returns**

The address of the current implementation of the proxy.

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| proxy | AdminUpgradeabilityProxy |  | 

### getProxyAdmin

Returns the admin of a proxy. Only the admin can query it.

```js
function getProxyAdmin(AdminUpgradeabilityProxy proxy) public view
returns(address)
```

**Returns**

The address of the current admin of the proxy.

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| proxy | AdminUpgradeabilityProxy |  | 

### changeProxyAdmin

Changes the admin of a proxy.

```js
function changeProxyAdmin(AdminUpgradeabilityProxy proxy, address newAdmin) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| proxy | AdminUpgradeabilityProxy | Proxy to change admin. | 
| newAdmin | address | Address to transfer proxy administration to. | 

### upgrade

Upgrades a proxy to the newest implementation of a contract.

```js
function upgrade(AdminUpgradeabilityProxy proxy, address implementation) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| proxy | AdminUpgradeabilityProxy | Proxy to be upgraded. | 
| implementation | address | the address of the Implementation. | 

### upgradeAndCall

Upgrades a proxy to the newest implementation of a contract and forwards a function call to it.
This is useful to initialize the proxied contract.

```js
function upgradeAndCall(AdminUpgradeabilityProxy proxy, address implementation, bytes data) public payable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| proxy | AdminUpgradeabilityProxy | Proxy to be upgraded. | 
| implementation | address | Address of the Implementation. | 
| data | bytes | Data to send as msg.data in the low level call.It should include the signature and the parameters of the function to be called, as described inhttps://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding. | 

