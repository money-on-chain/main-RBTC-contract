---
id: version-0.1.12-MoC
title: MoC
original_id: MoC
---

# MoC.sol

View Source: [contracts/MoC.sol](../../contracts/MoC.sol)

**↗ Extends: [MoCEvents](MoCEvents.md), [MoCLibConnection](MoCLibConnection.md), [MoCBase](MoCBase.md), [Stoppable](Stoppable.md), [IMoC](IMoC.md)**

**MoC** - version: 0.1.12

## Contract Members
**Constants & Variables**

```js
address internal docToken;
```
---

```js
address internal bproToken;
```
---

```js
contract MoCBProxManager internal bproxManager;
```
---

```js
contract IMoCState internal mocState;
```
---

```js
address internal DEPRECATED_mocConverter;
```
---

```js
contract IMoCSettlement internal settlement;
```
---

```js
contract IMoCExchange internal mocExchange;
```
---

```js
contract IMoCInrate internal mocInrate;
```
---

```js
bool internal liquidationExecuted;
```
---

```js
address public DEPRECATED_mocBurnout;
```
---

```js
uint256[50] private upgradeGap;
```
---

## BucketLiquidation

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

## ContractLiquidated

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocAddress | address |  | 

## Modifiers

- [whenSettlementReady](#whensettlementready)
- [atState](#atstate)
- [atLeastState](#atleaststate)
- [atMostState](#atmoststate)
- [notInProtectionMode](#notinprotectionmode)
- [bucketStateTransition](#bucketstatetransition)
- [availableBucket](#availablebucket)
- [notBaseBucket](#notbasebucket)
- [transitionState](#transitionstate)

### whenSettlementReady

```js
modifier whenSettlementReady() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### atState

```js
modifier atState(enum IMoCState.States _state) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _state | enum IMoCState.States |  | 

### atLeastState

```js
modifier atLeastState(enum IMoCState.States _state) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _state | enum IMoCState.States |  | 

### atMostState

```js
modifier atMostState(enum IMoCState.States _state) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _state | enum IMoCState.States |  | 

### notInProtectionMode

```js
modifier notInProtectionMode() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### bucketStateTransition

```js
modifier bucketStateTransition(bytes32 bucket) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### availableBucket

```js
modifier availableBucket(bytes32 bucket) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### notBaseBucket

```js
modifier notBaseBucket(bytes32 bucket) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### transitionState

```js
modifier transitionState() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [()](#mocsol)
- [initialize(address connectorAddress, address governorAddress, address stopperAddress, bool startStoppable)](#initialize)
- [bproxBalanceOf(bytes32 bucket, address account)](#bproxbalanceof)
- [getRedeemRequestAt(uint256 index)](#getredeemrequestat)
- [redeemQueueSize()](#redeemqueuesize)
- [docAmountToRedeem(address redeemer)](#docamounttoredeem)
- [redeemDocRequest(uint256 docAmount)](#redeemdocrequest)
- [alterRedeemRequestAmount(bool isAddition, uint256 delta)](#alterredeemrequestamount)
- [mintBPro(uint256 btcToMint)](#mintbpro)
- [mintBProVendors(uint256 btcToMint, address payable vendorAccount)](#mintbprovendors)
- [redeemBPro(uint256 bproAmount)](#redeembpro)
- [redeemBProVendors(uint256 bproAmount, address payable vendorAccount)](#redeembprovendors)
- [mintDoc(uint256 btcToMint)](#mintdoc)
- [mintDocVendors(uint256 btcToMint, address payable vendorAccount)](#mintdocvendors)
- [redeemBProx(bytes32 bucket, uint256 bproxAmount)](#redeembprox)
- [redeemBProxVendors(bytes32 bucket, uint256 bproxAmount, address payable vendorAccount)](#redeembproxvendors)
- [mintBProx(bytes32 bucket, uint256 btcToMint)](#mintbprox)
- [mintBProxVendors(bytes32 bucket, uint256 btcToMint, address payable vendorAccount)](#mintbproxvendors)
- [redeemFreeDoc(uint256 docAmount)](#redeemfreedoc)
- [redeemFreeDocVendors(uint256 docAmount, address payable vendorAccount)](#redeemfreedocvendors)
- [redeemAllDoc()](#redeemalldoc)
- [dailyInratePayment()](#dailyinratepayment)
- [payBitProHoldersInterestPayment()](#paybitproholdersinterestpayment)
- [calculateBitProHoldersInterest()](#calculatebitproholdersinterest)
- [getBitProInterestAddress()](#getbitprointerestaddress)
- [getBitProRate()](#getbitprorate)
- [getBitProInterestBlockSpan()](#getbitprointerestblockspan)
- [isDailyEnabled()](#isdailyenabled)
- [isBitProInterestEnabled()](#isbitprointerestenabled)
- [isSettlementEnabled()](#issettlementenabled)
- [isBucketLiquidationReached(bytes32 bucket)](#isbucketliquidationreached)
- [evalBucketLiquidation(bytes32 bucket)](#evalbucketliquidation)
- [evalLiquidation()](#evalliquidation)
- [runSettlement(uint256 steps)](#runsettlement)
- [sendToAddress(address payable receiver, uint256 btcAmount)](#sendtoaddress)
- [liquidate()](#liquidate)
- [transferCommissions(address payable sender, uint256 value, uint256 totalBtcSpent, uint256 btcCommission, uint256 mocCommission, address payable vendorAccount, uint256 btcMarkup, uint256 mocMarkup)](#transfercommissions)
- [transferMocCommission(address sender, uint256 mocCommission, address vendorAccount, uint256 mocMarkup)](#transfermoccommission)
- [redeemWithCommission(address payable sender, uint256 btcAmount, uint256 btcCommission, uint256 mocCommission, address payable vendorAccount, uint256 btcMarkup, uint256 mocMarkup)](#redeemwithcommission)
- [transferBtcCommission(address payable vendorAccount, uint256 btcCommission, uint256 btcMarkup)](#transferbtccommission)
- [doTransfer(address payable receiver, uint256 btcAmount)](#dotransfer)
- [doSend(address payable receiver, uint256 btcAmount)](#dosend)

### 

⤾ overrides IMoC.

Fallback function

```js
function () external payable whenNotPaused transitionState 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### initialize

Initializes the contract

```js
function initialize(address connectorAddress, address governorAddress, address stopperAddress, bool startStoppable) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| connectorAddress | address | MoCConnector contract address | 
| governorAddress | address | Governor contract address | 
| stopperAddress | address | Stopper contract address | 
| startStoppable | bool | Indicates if the contract starts being unstoppable or not | 

### bproxBalanceOf

Gets the BProx balance of an address

```js
function bproxBalanceOf(bytes32 bucket, address account) public view
returns(uint256)
```

**Returns**

BProx balance of the address

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket | 
| account | address | Address | 

### getRedeemRequestAt

Gets the RedeemRequest at the queue index position

```js
function getRedeemRequestAt(uint256 index) public view
returns(address, uint256)
```

**Returns**

redeemer's address and amount he submitted

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| index | uint256 | queue position to get | 

### redeemQueueSize

Returns current redeem queue size

```js
function redeemQueueSize() public view
returns(uint256)
```

**Returns**

redeem queue size

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### docAmountToRedeem

Returns the total amount of Docs in the redeem queue for redeemer

```js
function docAmountToRedeem(address redeemer) public view
returns(uint256)
```

**Returns**

total amount of Docs in the redeem queue for redeemer

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| redeemer | address | address for which ^ is computed | 

### redeemDocRequest

Creates or updates the amount of a Doc redeem Request from the msg.sender

```js
function redeemDocRequest(uint256 docAmount) public nonpayable whenNotPaused whenSettlementReady 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmount | uint256 | Amount of Docs to redeem on settlement [using mocPrecision] | 

### alterRedeemRequestAmount

Alters the redeem amount position for the redeemer

```js
function alterRedeemRequestAmount(bool isAddition, uint256 delta) public nonpayable whenNotPaused whenSettlementReady 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| isAddition | bool | true if adding amount to redeem, false to substract. | 
| delta | uint256 | the amount to add/substract to current position | 

### mintBPro

Mints BPRO and pays the comissions of the operation (retrocompatible function).

```js
function mintBPro(uint256 btcToMint) public payable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcToMint | uint256 | Amount in BTC to mint | 

### mintBProVendors

Mints BPRO and pays the comissions of the operation.

```js
function mintBProVendors(uint256 btcToMint, address payable vendorAccount) public payable whenNotPaused transitionState notInProtectionMode 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcToMint | uint256 | Amount in BTC to mint | 
| vendorAccount | address payable | Vendor address | 

### redeemBPro

Redeems Bpro Tokens and pays the comissions of the operation (retrocompatible function).

```js
function redeemBPro(uint256 bproAmount) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproAmount | uint256 | Amount in Bpro | 

### redeemBProVendors

Redeems Bpro Tokens and pays the comissions of the operation

```js
function redeemBProVendors(uint256 bproAmount, address payable vendorAccount) public nonpayable whenNotPaused transitionState atLeastState 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproAmount | uint256 | Amount in Bpro | 
| vendorAccount | address payable | Vendor address | 

### mintDoc

Mint Doc tokens and pays the commisions of the operation (retrocompatible function).

```js
function mintDoc(uint256 btcToMint) public payable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcToMint | uint256 | Amount in RBTC to mint | 

### mintDocVendors

Mint Doc tokens and pays the commisions of the operation

```js
function mintDocVendors(uint256 btcToMint, address payable vendorAccount) public payable whenNotPaused transitionState atLeastState 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcToMint | uint256 | Amount in RBTC to mint | 
| vendorAccount | address payable | Vendor address | 

### redeemBProx

Redeems Bprox Tokens and pays the comissions of the operation in RBTC (retrocompatible function).

```js
function redeemBProx(bytes32 bucket, uint256 bproxAmount) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket to reedem, for example X2 | 
| bproxAmount | uint256 | Amount in Bprox | 

### redeemBProxVendors

Redeems Bprox Tokens and pays the comissions of the operation in RBTC

```js
function redeemBProxVendors(bytes32 bucket, uint256 bproxAmount, address payable vendorAccount) public nonpayable whenNotPaused whenSettlementReady availableBucket notBaseBucket transitionState bucketStateTransition 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket to reedem, for example X2 | 
| bproxAmount | uint256 | Amount in Bprox | 
| vendorAccount | address payable | Vendor address | 

### mintBProx

BUCKET bprox minting (retrocompatible function).

```js
function mintBProx(bytes32 bucket, uint256 btcToMint) public payable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 
| btcToMint | uint256 | amount to mint on RBTC | 

### mintBProxVendors

BUCKET bprox minting

```js
function mintBProxVendors(bytes32 bucket, uint256 btcToMint, address payable vendorAccount) public payable whenNotPaused whenSettlementReady availableBucket notBaseBucket transitionState bucketStateTransition 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 
| btcToMint | uint256 | amount to mint on RBTC | 
| vendorAccount | address payable | Vendor address | 

### redeemFreeDoc

Redeems the requested amount for the msg.sender, or the max amount of free docs possible (retrocompatible function).

```js
function redeemFreeDoc(uint256 docAmount) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmount | uint256 | Amount of Docs to redeem. | 

### redeemFreeDocVendors

Redeems the requested amount for the msg.sender, or the max amount of free docs possible.

```js
function redeemFreeDocVendors(uint256 docAmount, address payable vendorAccount) public nonpayable whenNotPaused transitionState notInProtectionMode 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmount | uint256 | Amount of Docs to redeem. | 
| vendorAccount | address payable | Vendor address | 

### redeemAllDoc

Allow redeem on liquidation state, user DoCs get burned and he receives
the equivalent BTCs if can be covered, or the maximum available

```js
function redeemAllDoc() public nonpayable atState 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### dailyInratePayment

Moves the daily amount of interest rate to C0 bucket

```js
function dailyInratePayment() public nonpayable whenNotPaused 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### payBitProHoldersInterestPayment

Pays the BitPro interest and transfers it to the address mocInrate.bitProInterestAddress
BitPro interests = Nb (bucket 0) * bitProRate.

```js
function payBitProHoldersInterestPayment() public nonpayable whenNotPaused 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### calculateBitProHoldersInterest

Calculates BitPro holders holder interest by taking the total amount of RBTCs available on Bucket 0.
BitPro interests = Nb (bucket 0) * bitProRate.

```js
function calculateBitProHoldersInterest() public view
returns(uint256, uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getBitProInterestAddress

Gets the target address to transfer BitPro Holders rate

```js
function getBitProInterestAddress() public view
returns(address payable)
```

**Returns**

Target address to transfer BitPro Holders interest

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getBitProRate

Gets the rate for BitPro Holders

```js
function getBitProRate() public view
returns(uint256)
```

**Returns**

BitPro Rate

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getBitProInterestBlockSpan

Gets the blockspan of BPRO that represents the frecuency of BitPro holders interest payment

```js
function getBitProInterestBlockSpan() public view
returns(uint256)
```

**Returns**

returns power of bitProInterestBlockSpan

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### isDailyEnabled

```js
function isDailyEnabled() public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### isBitProInterestEnabled

```js
function isBitProInterestEnabled() public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### isSettlementEnabled

Indicates if settlement is enabled

```js
function isSettlementEnabled() public view
returns(bool)
```

**Returns**

Returns true if blockSpan number of blocks has passed since last execution; otherwise false

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### isBucketLiquidationReached

Checks if bucket liquidation is reached.

```js
function isBucketLiquidationReached(bytes32 bucket) public view
returns(bool)
```

**Returns**

true if bucket liquidation is reached, false otherwise

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of bucket. | 

### evalBucketLiquidation

```js
function evalBucketLiquidation(bytes32 bucket) public nonpayable availableBucket notBaseBucket whenSettlementReady 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### evalLiquidation

Evaluates if liquidation state has been reached and runs liq if that's the case

```js
function evalLiquidation() public nonpayable transitionState 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### runSettlement

Runs all settlement process

```js
function runSettlement(uint256 steps) public nonpayable whenNotPaused transitionState 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| steps | uint256 | Number of steps | 

### sendToAddress

⤾ overrides IMoC.sendToAddress

Send RBTC to a user and update RbtcInSystem in MoCState

```js
function sendToAddress(address payable receiver, uint256 btcAmount) public nonpayable onlyWhitelisted 
returns(bool)
```

**Returns**

result of the transaction

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| receiver | address payable | address of receiver | 
| btcAmount | uint256 | amount to transfer | 

### liquidate

```js
function liquidate() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### transferCommissions

Transfer mint operation fees (commissions + vendor markup)

```js
function transferCommissions(address payable sender, uint256 value, uint256 totalBtcSpent, uint256 btcCommission, uint256 mocCommission, address payable vendorAccount, uint256 btcMarkup, uint256 mocMarkup) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| sender | address payable | address of msg.sender | 
| value | uint256 | amount of msg.value | 
| totalBtcSpent | uint256 | amount in RBTC spent | 
| btcCommission | uint256 | commission amount in RBTC | 
| mocCommission | uint256 | commission amount in MoC | 
| vendorAccount | address payable | address of vendor | 
| btcMarkup | uint256 | vendor markup in RBTC | 
| mocMarkup | uint256 | vendor markup in MoC | 

### transferMocCommission

Transfer operation fees in MoC (commissions + vendor markup)

```js
function transferMocCommission(address sender, uint256 mocCommission, address vendorAccount, uint256 mocMarkup) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| sender | address | address of msg.sender | 
| mocCommission | uint256 | commission amount in MoC | 
| vendorAccount | address | address of vendor | 
| mocMarkup | uint256 | vendor markup in MoC | 

### redeemWithCommission

Transfer redeem operation fees (commissions + vendor markup)

```js
function redeemWithCommission(address payable sender, uint256 btcAmount, uint256 btcCommission, uint256 mocCommission, address payable vendorAccount, uint256 btcMarkup, uint256 mocMarkup) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| sender | address payable | address of msg.sender | 
| btcAmount | uint256 |  | 
| btcCommission | uint256 | commission amount in RBTC | 
| mocCommission | uint256 | commission amount in MoC | 
| vendorAccount | address payable | address of vendor | 
| btcMarkup | uint256 | vendor markup in RBTC | 
| mocMarkup | uint256 | vendor markup in MoC | 

### transferBtcCommission

Transfer operation fees in RBTC (commissions + vendor markup)

```js
function transferBtcCommission(address payable vendorAccount, uint256 btcCommission, uint256 btcMarkup) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| vendorAccount | address payable | address of vendor | 
| btcCommission | uint256 | commission amount in RBTC | 
| btcMarkup | uint256 | vendor markup in RBTC | 

### doTransfer

Transfer using transfer function and updates global RBTC register in MoCState

```js
function doTransfer(address payable receiver, uint256 btcAmount) private nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| receiver | address payable | address of receiver | 
| btcAmount | uint256 | amount in RBTC | 

### doSend

Transfer using send function and updates global RBTC register in MoCState

```js
function doSend(address payable receiver, uint256 btcAmount) private nonpayable
returns(bool)
```

**Returns**

Execution result

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| receiver | address payable | address of receiver | 
| btcAmount | uint256 | amount in RBTC | 

