---
id: version-0.1.12-MoCVendors
title: MoCVendors
original_id: MoCVendors
---

# MoCVendors.sol

View Source: [contracts/MoCVendors.sol](../../contracts/MoCVendors.sol)

**↗ Extends: [MoCVendorsEvents](MoCVendorsEvents.md), [MoCBase](MoCBase.md), [MoCLibConnection](MoCLibConnection.md), [Governed](Governed.md), [IMoCVendors](IMoCVendors.md)**

**MoCVendors** - version: 0.1.12

## Structs
### VendorDetails

```js
struct VendorDetails {
 bool isActive,
 uint256 markup,
 uint256 totalPaidInMoC,
 uint256 staking
}
```

## Contract Members
**Constants & Variables**

```js
contract IMoC internal moc;
```
---

```js
contract IMoCState internal mocState;
```
---

```js
contract IMoCExchange internal mocExchange;
```
---

```js
uint8 public constant VENDORS_LIST_ARRAY_MAX_LENGTH;
```
---

```js
uint256 public constant VENDOR_MAX_MARKUP;
```
---

```js
address public vendorGuardianAddress;
```
---

```js
mapping(address => struct MoCVendors.VendorDetails) public vendors;
```
---

```js
address[] public vendorsList;
```
---

```js
uint256[50] private upgradeGap;
```
---

## VendorRegistered

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| markup | uint256 |  | 

## VendorUpdated

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| markup | uint256 |  | 

## VendorUnregistered

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

## VendorStakeAdded

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| staking | uint256 |  | 

## VendorStakeRemoved

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| staking | uint256 |  | 

## TotalPaidInMoCReset

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

## VendorGuardianAddressChanged

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| vendorGuardianAddress | address |  | 

## VendorReceivedMarkup

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| vendorAdress | address |  | 
| paidMoC | uint256 |  | 
| paidRBTC | uint256 |  | 

## Modifiers

- [onlyActiveVendor](#onlyactivevendor)
- [onlyVendorGuardian](#onlyvendorguardian)

### onlyActiveVendor

Checks if vendor (msg.sender) is active

```js
modifier onlyActiveVendor() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### onlyVendorGuardian

Checks if address is allowed to call function

```js
modifier onlyVendorGuardian() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [initialize(address connectorAddress, address _governor, address _vendorGuardianAddress)](#initialize)
- [getVendorsCount()](#getvendorscount)
- [registerVendor(address account, uint256 markup)](#registervendor)
- [unregisterVendor(address account)](#unregistervendor)
- [addStake(uint256 staking)](#addstake)
- [removeStake(uint256 staking)](#removestake)
- [updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount)](#updatepaidmarkup)
- [getIsActive(address account)](#getisactive)
- [getMarkup(address account)](#getmarkup)
- [getTotalPaidInMoC(address account)](#gettotalpaidinmoc)
- [getStaking(address account)](#getstaking)
- [resetTotalPaidInMoC()](#resettotalpaidinmoc)
- [getVendorGuardianAddress()](#getvendorguardianaddress)
- [setVendorGuardianAddress(address _vendorGuardianAddress)](#setvendorguardianaddress)
- [initializeContracts()](#initializecontracts)
- [initializeValues(address _governor, address _vendorGuardianAddress)](#initializevalues)
- [setVendorGuardianAddressInternal(address _vendorGuardianAddress)](#setvendorguardianaddressinternal)

### initialize

Initializes the contract

```js
function initialize(address connectorAddress, address _governor, address _vendorGuardianAddress) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| connectorAddress | address | MoCConnector contract address | 
| _governor | address | Governor contract address | 
| _vendorGuardianAddress | address | Address which will be authorized to register and unregister vendors. | 

### getVendorsCount

Gets the count of active registered vendors

```js
function getVendorsCount() public view
returns(vendorsCount uint256)
```

**Returns**

Amount of active registered vendors

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### registerVendor

Allows to register a vendor

```js
function registerVendor(address account, uint256 markup) public nonpayable onlyVendorGuardian 
returns(isActive bool)
```

**Returns**

true if vendor was registered successfully; otherwise false

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 
| markup | uint256 | Markup which vendor will perceive from mint/redeem operations | 

### unregisterVendor

Allows to unregister a vendor

```js
function unregisterVendor(address account) public nonpayable onlyVendorGuardian 
returns(isActive bool)
```

**Returns**

false if vendor was unregistered successfully; otherwise false

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 

### addStake

Allows an active vendor (msg.sender) to add staking

```js
function addStake(uint256 staking) public nonpayable onlyActiveVendor 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| staking | uint256 | Staking the vendor wants to add | 

### removeStake

Allows an active vendor (msg.sender) to remove staking

```js
function removeStake(uint256 staking) public nonpayable onlyActiveVendor 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| staking | uint256 | Staking the vendor wants to remove | 

### updatePaidMarkup

⤾ overrides IMoCVendors.updatePaidMarkup

Allows to update paid markup to vendor

```js
function updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount) public nonpayable onlyWhitelisted 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 
| mocAmount | uint256 | paid markup in MoC | 
| rbtcAmount | uint256 | paid markup in RBTC | 

### getIsActive

⤾ overrides IMoCVendors.getIsActive

Gets if a vendor is active

```js
function getIsActive(address account) public view
returns(bool)
```

**Returns**

true if vendor is active; false otherwise

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 

### getMarkup

⤾ overrides IMoCVendors.getMarkup

Gets vendor markup

```js
function getMarkup(address account) public view
returns(uint256)
```

**Returns**

Vendor markup

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 

### getTotalPaidInMoC

⤾ overrides IMoCVendors.getTotalPaidInMoC

Gets vendor total paid in MoC

```js
function getTotalPaidInMoC(address account) public view
returns(uint256)
```

**Returns**

Vendor total paid in MoC

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 

### getStaking

⤾ overrides IMoCVendors.getStaking

Gets vendor staking

```js
function getStaking(address account) public view
returns(uint256)
```

**Returns**

Vendor staking

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 

### resetTotalPaidInMoC

⤾ overrides IMoCVendors.resetTotalPaidInMoC

Allows to reset all active vendor's total paid in MoC during settlement

```js
function resetTotalPaidInMoC() public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getVendorGuardianAddress

Returns the address is authorized to register and unregister vendors.

```js
function getVendorGuardianAddress() public view
returns(address)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setVendorGuardianAddress

Sets the address which will be authorized to register and unregister vendors.

```js
function setVendorGuardianAddress(address _vendorGuardianAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _vendorGuardianAddress | address | Address which will be authorized to register and unregister vendors. | 

### initializeContracts

```js
function initializeContracts() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### initializeValues

```js
function initializeValues(address _governor, address _vendorGuardianAddress) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _governor | address |  | 
| _vendorGuardianAddress | address |  | 

### setVendorGuardianAddressInternal

Sets the address which will be authorized to register and unregister vendors.

```js
function setVendorGuardianAddressInternal(address _vendorGuardianAddress) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _vendorGuardianAddress | address | Address which will be authorized to register and unregister vendors. | 

