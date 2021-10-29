---
id: version-0.1.12-CommissionSplitter
title: CommissionSplitter
original_id: CommissionSplitter
---

# CommissionSplitter.sol

View Source: [contracts/auxiliar/CommissionSplitter.sol](../../contracts/auxiliar/CommissionSplitter.sol)

**↗ Extends: [Governed](Governed.md), [ReentrancyGuard](ReentrancyGuard.md)**

**CommissionSplitter** - version: 0.1.12

Contract that split his balance between two addresses based on a
proportion defined by Governance. One of those addresses should
be a Money on Chain main contract.

## Contract Members
**Constants & Variables**

```js
uint256 public constant PRECISION;
```
---

```js
address payable public commissionsAddress;
```
---

```js
uint256 public mocProportion;
```
---

```js
contract IMoC public moc;
```
---

```js
contract IERC20 public mocToken;
```
---

```js
address public mocTokenCommissionsAddress;
```
---

## SplitExecuted

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| commissionAmount | uint256 |  | 
| mocAmount | uint256 |  | 
| mocTokenCommissionAmount | uint256 |  | 

## Functions

- [initialize(IMoC _mocAddress, address payable _commissionsAddress, uint256 _mocProportion, IGovernor _governor, IERC20 _mocToken, address _mocTokenCommissionsAddress)](#initialize)
- [split()](#split)
- [setCommissionAddress(address payable _commissionsAddress)](#setcommissionaddress)
- [setMocProportion(uint256 _mocProportion)](#setmocproportion)
- [setMocToken(address _mocToken)](#setmoctoken)
- [setMocTokenCommissionAddress(address _mocTokenCommissionsAddress)](#setmoctokencommissionaddress)
- [_setMocProportion(uint256 _mocProportion)](#_setmocproportion)
- [_sendReservesToMoC(uint256 amount)](#_sendreservestomoc)
- [_sendReserves(uint256 amount, address payable receiver)](#_sendreserves)
- [()](#commissionsplittersol)

### initialize

Initialize commission splitter contract

```js
function initialize(IMoC _mocAddress, address payable _commissionsAddress, uint256 _mocProportion, IGovernor _governor, IERC20 _mocToken, address _mocTokenCommissionsAddress) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _mocAddress | IMoC | the address of MoC contract | 
| _commissionsAddress | address payable | the address in which the remaining commissions (profit ones) are sent | 
| _mocProportion | uint256 | the proportion of commission that moc will keep, it should have PRECISION precision | 
| _governor | IGovernor | the address of the IGovernor contract | 
| _mocToken | IERC20 | the address of MoC Token contract | 
| _mocTokenCommissionsAddress | address | the address in which the Moc Token commissions are sent | 

### split

Split current balance of the contract, and sends one part
to destination address and the other to MoC Reserves.

```js
function split() public nonpayable nonReentrant 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setCommissionAddress

```js
function setCommissionAddress(address payable _commissionsAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _commissionsAddress | address payable |  | 

### setMocProportion

```js
function setMocProportion(uint256 _mocProportion) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _mocProportion | uint256 |  | 

### setMocToken

```js
function setMocToken(address _mocToken) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _mocToken | address |  | 

### setMocTokenCommissionAddress

```js
function setMocTokenCommissionAddress(address _mocTokenCommissionsAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _mocTokenCommissionsAddress | address |  | 

### _setMocProportion

```js
function _setMocProportion(uint256 _mocProportion) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _mocProportion | uint256 |  | 

### _sendReservesToMoC

Sends tokens to Money on chain reserves

```js
function _sendReservesToMoC(uint256 amount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| amount | uint256 |  | 

### _sendReserves

Sends reserves to address reserves

```js
function _sendReserves(uint256 amount, address payable receiver) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| amount | uint256 |  | 
| receiver | address payable |  | 

### 

```js
function () external payable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

