---
id: version-0.1.12-MoCInrate
title: MoCInrate
original_id: MoCInrate
---

# MoCInrate.sol

View Source: [contracts/MoCInrate.sol](../../contracts/MoCInrate.sol)

**↗ Extends: [MoCInrateEvents](MoCInrateEvents.md), [MoCInrateStructs](MoCInrateStructs.md), [MoCBase](MoCBase.md), [MoCLibConnection](MoCLibConnection.md), [Governed](Governed.md), [IMoCInrate](IMoCInrate.md)**

**MoCInrate** - version: 0.1.12

## Structs
### InrateParams

```js
struct InrateParams {
 uint256 tMax,
 uint256 tMin,
 uint256 power
}
```

### InitializeParams

```js
struct InitializeParams {
 address connectorAddress,
 address governor,
 uint256 btcxTmin,
 uint256 btcxPower,
 uint256 btcxTmax,
 uint256 bitProRate,
 uint256 blockSpanBitPro,
 address payable bitProInterestTargetAddress,
 address payable commissionsAddressTarget,
 uint256 docTmin,
 uint256 docPower,
 uint256 docTmax
}
```

## Contract Members
**Constants & Variables**

```js
struct MoCInrateStructs.InrateParams internal btcxParams;
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
contract MoCBProxManager internal bproxManager;
```
---

```js
uint256 public lastDailyPayBlock;
```
---

```js
uint256 public bitProRate;
```
---

```js
address payable public bitProInterestAddress;
```
---

```js
uint256 public lastBitProInterestBlock;
```
---

```js
uint256 public bitProInterestBlockSpan;
```
---

```js
address payable public commissionsAddress;
```
---

```js
uint256 public DEPRECATED_commissionRate;
```
---

```js
uint256 public docTmin;
```
---

```js
uint256 public docPower;
```
---

```js
uint256 public docTmax;
```
---

```js
uint8 public constant MINT_BPRO_FEES_RBTC;
```
---

```js
uint8 public constant REDEEM_BPRO_FEES_RBTC;
```
---

```js
uint8 public constant MINT_DOC_FEES_RBTC;
```
---

```js
uint8 public constant REDEEM_DOC_FEES_RBTC;
```
---

```js
uint8 public constant MINT_BTCX_FEES_RBTC;
```
---

```js
uint8 public constant REDEEM_BTCX_FEES_RBTC;
```
---

```js
uint8 public constant MINT_BPRO_FEES_MOC;
```
---

```js
uint8 public constant REDEEM_BPRO_FEES_MOC;
```
---

```js
uint8 public constant MINT_DOC_FEES_MOC;
```
---

```js
uint8 public constant REDEEM_DOC_FEES_MOC;
```
---

```js
uint8 public constant MINT_BTCX_FEES_MOC;
```
---

```js
uint8 public constant REDEEM_BTCX_FEES_MOC;
```
---

```js
mapping(uint8 => uint256) public commissionRatesByTxType;
```
---

```js
uint256[50] private upgradeGap;
```
---

## InrateDailyPay

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| amount | uint256 |  | 
| daysToSettlement | uint256 |  | 
| nReserveBucketC0 | uint256 |  | 

## RiskProHoldersInterestPay

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| amount | uint256 |  | 
| nReserveBucketC0BeforePay | uint256 |  | 

## Modifiers

- [onlyOnceADay](#onlyonceaday)
- [onlyWhenBitProInterestsIsEnabled](#onlywhenbitprointerestsisenabled)

### onlyOnceADay

```js
modifier onlyOnceADay() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### onlyWhenBitProInterestsIsEnabled

```js
modifier onlyWhenBitProInterestsIsEnabled() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [setDoCTmin(uint256 _docTmin)](#setdoctmin)
- [setDoCTmax(uint256 _docTmax)](#setdoctmax)
- [setDoCPower(uint256 _docPower)](#setdocpower)
- [getDoCTmin()](#getdoctmin)
- [getDoCTmax()](#getdoctmax)
- [getDoCPower()](#getdocpower)
- [docInrateAvg(uint256 docRedeem)](#docinrateavg)
- [initialize(struct MoCInrateStructs.InitializeParams params)](#initialize)
- [getBtcxTmin()](#getbtcxtmin)
- [getBtcxTmax()](#getbtcxtmax)
- [getBtcxPower()](#getbtcxpower)
- [getBitProInterestBlockSpan()](#getbitprointerestblockspan)
- [setBtcxTmin(uint256 _btxcTmin)](#setbtcxtmin)
- [setBtcxTmax(uint256 _btxcTax)](#setbtcxtmax)
- [setBtcxPower(uint256 _btxcPower)](#setbtcxpower)
- [getBitProRate()](#getbitprorate)
- [setBitProRate(uint256 newBitProRate)](#setbitprorate)
- [setBitProInterestBlockSpan(uint256 newBitProBlockSpan)](#setbitprointerestblockspan)
- [getBitProInterestAddress()](#getbitprointerestaddress)
- [setBitProInterestAddress(address payable newBitProInterestAddress)](#setbitprointerestaddress)
- [setCommissionsAddress(address payable newCommissionsAddress)](#setcommissionsaddress)
- [spotInrate()](#spotinrate)
- [btcxInrateAvg(bytes32 bucket, uint256 btcAmount, bool onMinting)](#btcxinrateavg)
- [dailyInrate()](#dailyinrate)
- [calcMintInterestValues(bytes32 bucket, uint256 rbtcAmount)](#calcmintinterestvalues)
- [calcDocRedInterestValues(uint256 docAmount, uint256 rbtcAmount)](#calcdocredinterestvalues)
- [calcFinalRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem)](#calcfinalredeeminterestvalue)
- [calcCommissionValue(uint256 rbtcAmount, uint8 txType)](#calccommissionvalue)
- [calcCommissionValue(uint256 rbtcAmount)](#calccommissionvalue)
- [calculateVendorMarkup(address vendorAccount, uint256 amount)](#calculatevendormarkup)
- [calcRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem)](#calcredeeminterestvalue)
- [dailyInratePayment()](#dailyinratepayment)
- [isDailyEnabled()](#isdailyenabled)
- [isBitProInterestEnabled()](#isbitprointerestenabled)
- [calculateBitProHoldersInterest()](#calculatebitproholdersinterest)
- [payBitProHoldersInterestPayment()](#paybitproholdersinterestpayment)
- [setCommissionRateByTxType(uint8 txType, uint256 value)](#setcommissionratebytxtype)
- [inrateToSettlement(uint256 inrate, bool countAllDays)](#inratetosettlement)
- [calcProportionalInterestValue(bytes32 bucket, uint256 redeemInterest)](#calcproportionalinterestvalue)
- [calcFullRedeemInterestValue(bytes32 bucket)](#calcfullredeeminterestvalue)
- [simulateDocMovement(bytes32 bucket, uint256 btcAmount, bool onMinting)](#simulatedocmovement)
- [inrateDayCount(bool countAllDays)](#inratedaycount)
- [initializeContracts()](#initializecontracts)
- [initializeValues(address _governor, uint256 btcxMin, uint256 btcxPower, uint256 btcxMax, uint256 _bitProRate, address payable commissionsAddressTarget, uint256 blockSpanBitPro, address payable bitProInterestsTarget, uint256 _docTmin, uint256 _docPower, uint256 _docTmax)](#initializevalues)

### setDoCTmin

```js
function setDoCTmin(uint256 _docTmin) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _docTmin | uint256 |  | 

### setDoCTmax

```js
function setDoCTmax(uint256 _docTmax) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _docTmax | uint256 |  | 

### setDoCPower

```js
function setDoCPower(uint256 _docPower) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _docPower | uint256 |  | 

### getDoCTmin

```js
function getDoCTmin() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getDoCTmax

```js
function getDoCTmax() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getDoCPower

```js
function getDoCPower() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### docInrateAvg

Calculates an average interest rate between after and before free doc Redemption

```js
function docInrateAvg(uint256 docRedeem) public view
returns(uint256)
```

**Returns**

Interest rate value [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docRedeem | uint256 | Docs to redeem [using mocPrecision] | 

### initialize

Initializes the contract

```js
function initialize(struct MoCInrateStructs.InitializeParams params) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| params | struct MoCInrateStructs.InitializeParams | Params defined in InitializeParams struct | 

### getBtcxTmin

gets tMin param of BTCX tokens

```js
function getBtcxTmin() public view
returns(uint256)
```

**Returns**

returns tMin of BTCX

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getBtcxTmax

gets tMax param of BTCX tokens

```js
function getBtcxTmax() public view
returns(uint256)
```

**Returns**

returns tMax of BTCX

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getBtcxPower

gets power param of BTCX tokens

```js
function getBtcxPower() public view
returns(uint256)
```

**Returns**

returns power of BTCX

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getBitProInterestBlockSpan

⤾ overrides IMoCInrate.getBitProInterestBlockSpan

Gets the blockspan of BPRO that represents the frecuency of BitPro holders intereset payment

```js
function getBitProInterestBlockSpan() public view
returns(uint256)
```

**Returns**

returns power of bitProInterestBlockSpan

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setBtcxTmin

sets tMin param of BTCX tokens

```js
function setBtcxTmin(uint256 _btxcTmin) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _btxcTmin | uint256 | tMin of BTCX | 

### setBtcxTmax

sets tMax param of BTCX tokens

```js
function setBtcxTmax(uint256 _btxcTax) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _btxcTax | uint256 | tMax of BTCX | 

### setBtcxPower

sets power param of BTCX tokens

```js
function setBtcxPower(uint256 _btxcPower) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _btxcPower | uint256 | power of BTCX | 

### getBitProRate

⤾ overrides IMoCInrate.getBitProRate

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

### setBitProRate

Sets BitPro Holders rate

```js
function setBitProRate(uint256 newBitProRate) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newBitProRate | uint256 | New BitPro rate | 

### setBitProInterestBlockSpan

⤾ overrides IMoCInrate.setBitProInterestBlockSpan

Sets the blockspan BitPro Intereset rate payment is enable to be executed

```js
function setBitProInterestBlockSpan(uint256 newBitProBlockSpan) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newBitProBlockSpan | uint256 | New BitPro Block span | 

### getBitProInterestAddress

⤾ overrides IMoCInrate.getBitProInterestAddress

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

### setBitProInterestAddress

Sets the target address to transfer BitPro Holders rate

```js
function setBitProInterestAddress(address payable newBitProInterestAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newBitProInterestAddress | address payable | New BitPro rate | 

### setCommissionsAddress

Sets the target address to transfer commissions of Mint/Redeem transactions

```js
function setCommissionsAddress(address payable newCommissionsAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newCommissionsAddress | address payable | New commisions address | 

### spotInrate

Calculates interest rate for BProx Minting, redeem and Free Doc Redeem

```js
function spotInrate() public view
returns(uint256)
```

**Returns**

Interest rate value [using RatePrecsion]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### btcxInrateAvg

Calculates an average interest rate between after and before mint/redeem

```js
function btcxInrateAvg(bytes32 bucket, uint256 btcAmount, bool onMinting) public view
returns(uint256)
```

**Returns**

Interest rate value [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket involved in the operation | 
| btcAmount | uint256 | Value of the operation from which calculates the inrate [using reservePrecision] | 
| onMinting | bool | Value that represents if the calculation is based on mint or on redeem | 

### dailyInrate

returns the amount of BTC to pay in concept of interest to bucket C0

```js
function dailyInrate() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### calcMintInterestValues

⤾ overrides IMoCInrate.calcMintInterestValues

Extract the inrate from the passed RBTC value for Bprox minting operation

```js
function calcMintInterestValues(bytes32 bucket, uint256 rbtcAmount) public view
returns(uint256)
```

**Returns**

RBTC to pay in concept of interests [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket to use to calculate interés | 
| rbtcAmount | uint256 | Total value from which extract the interest rate [using reservePrecision] | 

### calcDocRedInterestValues

⤾ overrides IMoCInrate.calcDocRedInterestValues

Extract the inrate from the passed RBTC value for the Doc Redeem operation

```js
function calcDocRedInterestValues(uint256 docAmount, uint256 rbtcAmount) public view
returns(uint256)
```

**Returns**

RBTC to pay in concept of interests [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmount | uint256 | Doc amount of the redemption [using mocPrecision] | 
| rbtcAmount | uint256 | Total value from which extract the interest rate [using reservePrecision] | 

### calcFinalRedeemInterestValue

⤾ overrides IMoCInrate.calcFinalRedeemInterestValue

This function calculates the interest to return to the user
in a BPRox redemption. It uses a mechanism to counteract the effect
of free docs redemption. It will be replaced with FreeDoC redemption
interests in the future

```js
function calcFinalRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) public view
returns(uint256)
```

**Returns**

RBTC to recover in concept of interests [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket to use to calculate interest | 
| rbtcToRedeem | uint256 | Total value from which calculate interest [using reservePrecision] | 

### calcCommissionValue

⤾ overrides IMoCInrate.calcCommissionValue

calculates the Commission rate from the passed RBTC amount and the transaction type for mint/redeem operations

```js
function calcCommissionValue(uint256 rbtcAmount, uint8 txType) public view
returns(uint256)
```

**Returns**

finalCommissionAmount [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| rbtcAmount | uint256 | Total value from which apply the Commission rate [using reservePrecision] | 
| txType | uint8 | Transaction type according to constant values defined in this contract | 

### calcCommissionValue

DEPRECATED calculates the Commission rate from the passed RBTC amount for mint/redeem operations

```js
function calcCommissionValue(uint256 rbtcAmount) external view
returns(uint256)
```

**Returns**

finalCommissionAmount [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| rbtcAmount | uint256 | Total value from which apply the Commission rate [using reservePrecision] | 

### calculateVendorMarkup

⤾ overrides IMoCInrate.calculateVendorMarkup

calculates the vendor markup rate from the passed vendor account and amount

```js
function calculateVendorMarkup(address vendorAccount, uint256 amount) public view
returns(markup uint256)
```

**Returns**

finalCommissionAmount [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| vendorAccount | address | Vendor address | 
| amount | uint256 | Total value from which apply the vendor markup rate [using reservePrecision] | 

### calcRedeemInterestValue

Calculates RBTC value to return to the user in concept of interests

```js
function calcRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) public view
returns(uint256)
```

**Returns**

RBTC to recover in concept of interests [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket to use to calculate interest | 
| rbtcToRedeem | uint256 | Total value from which calculate interest [using reservePrecision] | 

### dailyInratePayment

⤾ overrides IMoCInrate.dailyInratePayment

Moves the daily amount of interest rate to C0 bucket

```js
function dailyInratePayment() public nonpayable onlyWhitelisted onlyOnceADay 
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### isDailyEnabled

⤾ overrides IMoCInrate.isDailyEnabled

```js
function isDailyEnabled() public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### isBitProInterestEnabled

⤾ overrides IMoCInrate.isBitProInterestEnabled

```js
function isBitProInterestEnabled() public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### calculateBitProHoldersInterest

⤾ overrides IMoCInrate.calculateBitProHoldersInterest

Calculates BitPro Holders interest rates

```js
function calculateBitProHoldersInterest() public view
returns(uint256, uint256)
```

**Returns**

toPay interest in RBTC [using RBTCPrecsion]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### payBitProHoldersInterestPayment

⤾ overrides IMoCInrate.payBitProHoldersInterestPayment

Pays the BitPro Holders interest rates

```js
function payBitProHoldersInterestPayment() public nonpayable onlyWhitelisted onlyWhenBitProInterestsIsEnabled 
returns(uint256)
```

**Returns**

interest payed in RBTC [using RBTCPrecsion]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setCommissionRateByTxType

Sets the commission rate to a particular transaction type

```js
function setCommissionRateByTxType(uint8 txType, uint256 value) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| txType | uint8 | Transaction type according to constant values defined in this contract | 
| value | uint256 | Commission rate | 

### inrateToSettlement

Calculates the interest rate to pay until the settlement day

```js
function inrateToSettlement(uint256 inrate, bool countAllDays) internal view
returns(uint256)
```

**Returns**

Interest rate value [using RatePrecsion]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| inrate | uint256 | Spot interest rate | 
| countAllDays | bool | Value that represents if the calculation will use all days or one day less | 

### calcProportionalInterestValue

This function calculates the interest to return to a user redeeming
BTCx as a proportion of the amount in the interestBag.

```js
function calcProportionalInterestValue(bytes32 bucket, uint256 redeemInterest) internal view
returns(uint256)
```

**Returns**

InterestsInBag * (RedeemInterests / FullRedeemInterest) [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket to use to calculate interest | 
| redeemInterest | uint256 | Total value from which calculate interest [using reservePrecision] | 

### calcFullRedeemInterestValue

This function calculates the interest to return if a user redeem all Btcx in existance

```js
function calcFullRedeemInterestValue(bytes32 bucket) internal view
returns(uint256)
```

**Returns**

Interests [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket to use to calculate interest | 

### simulateDocMovement

Calculates the final amount of Bucket 0 DoCs on BProx mint/redeem

```js
function simulateDocMovement(bytes32 bucket, uint256 btcAmount, bool onMinting) internal view
returns(uint256)
```

**Returns**

Final bucket 0 Doc amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket involved in the operation | 
| btcAmount | uint256 | Value of the operation from which calculates the inrate [using reservePrecision] | 
| onMinting | bool |  | 

### inrateDayCount

Returns the days to use for interests calculation

```js
function inrateDayCount(bool countAllDays) internal view
returns(uint256)
```

**Returns**

days [using dayPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| countAllDays | bool | Value that represents if the calculation is based on mint or on redeem | 

### initializeContracts

Initialize the contracts with which it interacts

```js
function initializeContracts() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### initializeValues

Initialize the parameters of the contract

```js
function initializeValues(address _governor, uint256 btcxMin, uint256 btcxPower, uint256 btcxMax, uint256 _bitProRate, address payable commissionsAddressTarget, uint256 blockSpanBitPro, address payable bitProInterestsTarget, uint256 _docTmin, uint256 _docPower, uint256 _docTmax) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _governor | address | the address of the IGovernor contract | 
| btcxMin | uint256 | Minimum interest rate [using mocPrecision] | 
| btcxPower | uint256 | Power is a parameter for interest rate calculation [using noPrecision] | 
| btcxMax | uint256 | Maximun interest rate [using mocPrecision] | 
| _bitProRate | uint256 | BitPro holder interest rate [using mocPrecision] | 
| commissionsAddressTarget | address payable |  | 
| blockSpanBitPro | uint256 | BitPro blockspan to configure payments periods[using mocPrecision] | 
| bitProInterestsTarget | address payable | Target address to transfer the weekly BitPro holders interest | 
| _docTmin | uint256 |  | 
| _docPower | uint256 |  | 
| _docTmax | uint256 |  | 

