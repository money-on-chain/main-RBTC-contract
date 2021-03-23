---
id: version-0.1.10-MoCVendors
title: MoCVendors
original_id: MoCVendors
---

# MoCVendors.sol

View Source: [contracts/MoCVendors.sol](../../contracts/MoCVendors.sol)

**↗ Extends: [MoCVendorsEvents](MoCVendorsEvents.md), [MoCBase](MoCBase.md), [MoCLibConnection](MoCLibConnection.md), [Governed](Governed.md)**

**MoCVendors** - version: 0.1.10

## Structs
### VendorDetails

```js
struct VendorDetails {
 bool isActive,
 uint256 markup,
 uint256 totalPaidInMoC,
 uint256 staking,
 uint256 paidMoC,
 uint256 paidRBTC
}
```

## Contract Members
**Constants & Variables**

```js
//internal members
contract MoC internal moc;
contract MoCState internal mocState;
contract MoCExchange internal mocExchange;

//public members
uint8 public constant VENDORS_LIST_ARRAY_MAX_LENGTH;
uint256 public constant VENDOR_MAX_MARKUP;
address public vendorGuardianAddress;
mapping(address => struct MoCVendors.VendorDetails) public vendors;
address[] public vendorsList;

//private members
uint256[50] private upgradeGap;

```

**Events**

```js
event VendorRegistered(address  account, uint256  markup);
event VendorUpdated(address  account, uint256  markup);
event VendorUnregistered(address  account);
event VendorStakeAdded(address  account, uint256  staking);
event VendorStakeRemoved(address  account, uint256  staking);
event TotalPaidInMoCReset(address  account);
event VendorGuardianAddressChanged(address  vendorGuardianAddress);
```

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
- [updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount, uint256 totalMoCAmount)](#updatepaidmarkup)
- [getIsActive(address account)](#getisactive)
- [getMarkup(address account)](#getmarkup)
- [getTotalPaidInMoC(address account)](#gettotalpaidinmoc)
- [getStaking(address account)](#getstaking)
- [getPaidMoC(address account)](#getpaidmoc)
- [getPaidRBTC(address account)](#getpaidrbtc)
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

Allows to update paid markup to vendor

```js
function updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount, uint256 totalMoCAmount) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 
| mocAmount | uint256 | paid markup in MoC | 
| rbtcAmount | uint256 | paid markup in RBTC | 
| totalMoCAmount | uint256 | total paid in MoC | 

### getIsActive

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

### getPaidMoC

Gets vendor paid in MoC

```js
function getPaidMoC(address account) public view
returns(uint256)
```

**Returns**

Vendor paid in MoC

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 

### getPaidRBTC

Gets vendor paid in RBTC

```js
function getPaidRBTC(address account) public view
returns(uint256)
```

**Returns**

Vendor total paid in RBTC

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Vendor address | 

### resetTotalPaidInMoC

Allows to reset all active vendor's total paid in MoC during settlement

```js
function resetTotalPaidInMoC() public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getVendorGuardianAddress

Returns the address which will receive the initial amount of MoC required for a vendor to register.

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

