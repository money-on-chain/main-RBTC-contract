---
id: version-0.1.12-MoCState
title: MoCState
original_id: MoCState
---

# MoCState.sol

View Source: [contracts/MoCState.sol](../../contracts/MoCState.sol)

**↗ Extends: [MoCLibConnection](MoCLibConnection.md), [MoCBase](MoCBase.md), [MoCEMACalculator](MoCEMACalculator.md), [IMoCState](IMoCState.md)**
**↘ Derived Contracts: [MoCStateMock](MoCStateMock.md)**

**MoCState** - version: 0.1.12

## Structs
### InitializeParams

```js
struct InitializeParams {
 address connectorAddress,
 address governor,
 address btcPriceProvider,
 uint256 liq,
 uint256 utpdu,
 uint256 maxDiscRate,
 uint256 dayBlockSpan,
 uint256 ema,
 uint256 smoothFactor,
 uint256 emaBlockSpan,
 uint256 maxMintBPro,
 address mocPriceProvider,
 address mocTokenAddress,
 address mocVendorsAddress,
 bool liquidationEnabled,
 uint256 protected
}
```

## Contract Members
**Constants & Variables**

```js
enum IMoCState.States public state;
```
---

```js
uint256 public dayBlockSpan;
```
---

```js
uint256 public peg;
```
---

```js
uint256 public bproMaxDiscountRate;
```
---

```js
uint256 public liq;
```
---

```js
uint256 public utpdu;
```
---

```js
uint256 public rbtcInSystem;
```
---

```js
uint256 public liquidationPrice;
```
---

```js
bool public liquidationEnabled;
```
---

```js
uint256 public protected;
```
---

```js
uint256 public maxMintBPro;
```
---

```js
contract PriceProvider internal btcPriceProvider;
```
---

```js
contract IMoCSettlement internal mocSettlement;
```
---

```js
address internal DEPRECATED_mocConverter;
```
---

```js
contract DocToken internal docToken;
```
---

```js
contract BProToken internal bproToken;
```
---

```js
contract MoCBProxManager internal bproxManager;
```
---

```js
contract PriceProvider internal mocPriceProvider;
```
---

```js
contract MoCToken internal mocToken;
```
---

```js
address internal mocVendors;
```
---

```js
uint256[50] private upgradeGap;
```
---

## StateTransition

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newState | enum IMoCState.States |  | 

## BtcPriceProviderUpdated

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| oldAddress | address |  | 
| newAddress | address |  | 

## MoCPriceProviderUpdated

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| oldAddress | address |  | 
| newAddress | address |  | 

## MoCTokenChanged

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocTokenAddress | address |  | 

## MoCVendorsChanged

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocVendorsAddress | address |  | 

## Functions

- [initialize(struct MoCState.InitializeParams params)](#initialize)
- [setMaxDiscountRate(uint256 rate)](#setmaxdiscountrate)
- [getMaxDiscountRate()](#getmaxdiscountrate)
- [setDayBlockSpan(uint256 blockSpan)](#setdayblockspan)
- [setBtcPriceProvider(address btcProviderAddress)](#setbtcpriceprovider)
- [getBtcPriceProvider()](#getbtcpriceprovider)
- [getDayBlockSpan()](#getdayblockspan)
- [subtractRbtcFromSystem(uint256 btcAmount)](#subtractrbtcfromsystem)
- [addToRbtcInSystem(uint256 btcAmount)](#addtorbtcinsystem)
- [bproTotalSupply()](#bprototalsupply)
- [docTotalSupply()](#doctotalsupply)
- [cobj()](#cobj)
- [collateralRbtcInSystem()](#collateralrbtcinsystem)
- [globalCoverage()](#globalcoverage)
- [lockedBitcoin(bytes32 bucket)](#lockedbitcoin)
- [getRbtcInBitPro(bytes32 bucket)](#getrbtcinbitpro)
- [getRbtcRemainder()](#getrbtcremainder)
- [coverage(bytes32 bucket)](#coverage)
- [abundanceRatio(uint256 doc0)](#abundanceratio)
- [currentAbundanceRatio()](#currentabundanceratio)
- [leverage(bytes32 bucket)](#leverage)
- [globalMaxDoc()](#globalmaxdoc)
- [freeDoc()](#freedoc)
- [maxDoc(bytes32 bucket)](#maxdoc)
- [globalMaxBPro()](#globalmaxbpro)
- [absoluteMaxDoc()](#absolutemaxdoc)
- [maxBPro(bytes32 bucket)](#maxbpro)
- [maxBProx(bytes32 bucket)](#maxbprox)
- [maxBProxBtcValue(bytes32 bucket)](#maxbproxbtcvalue)
- [absoluteMaxBPro()](#absolutemaxbpro)
- [maxBProWithDiscount()](#maxbprowithdiscount)
- [globalLockedBitcoin()](#globallockedbitcoin)
- [bproTecPrice()](#bprotecprice)
- [bucketBProTecPrice(bytes32 bucket)](#bucketbprotecprice)
- [bucketBProTecPriceHelper(bytes32 bucket)](#bucketbprotecpricehelper)
- [bproDiscountPrice()](#bprodiscountprice)
- [bproUsdPrice()](#bprousdprice)
- [maxBProxBProValue(bytes32 bucket)](#maxbproxbprovalue)
- [bproxBProPrice(bytes32 bucket)](#bproxbproprice)
- [bproSpotDiscountRate()](#bprospotdiscountrate)
- [daysToSettlement()](#daystosettlement)
- [blocksToSettlement()](#blockstosettlement)
- [isLiquidationReached()](#isliquidationreached)
- [getLiquidationPrice()](#getliquidationprice)
- [getBucketNBTC(bytes32 bucket)](#getbucketnbtc)
- [getBucketNBPro(bytes32 bucket)](#getbucketnbpro)
- [getBucketNDoc(bytes32 bucket)](#getbucketndoc)
- [getBucketCobj(bytes32 bucket)](#getbucketcobj)
- [getInrateBag(bytes32 bucket)](#getinratebag)
- [getBcons()](#getbcons)
- [getBitcoinPrice()](#getbitcoinprice)
- [calculateBitcoinMovingAverage()](#calculatebitcoinmovingaverage)
- [getLiq()](#getliq)
- [setLiq(uint256 _liq)](#setliq)
- [getUtpdu()](#getutpdu)
- [setUtpdu(uint256 _utpdu)](#setutpdu)
- [getPeg()](#getpeg)
- [setPeg(uint256 _peg)](#setpeg)
- [getProtected()](#getprotected)
- [setProtected(uint256 _protected)](#setprotected)
- [getLiquidationEnabled()](#getliquidationenabled)
- [setLiquidationEnabled(bool _liquidationEnabled)](#setliquidationenabled)
- [nextState()](#nextstate)
- [setMaxMintBPro(uint256 _maxMintBPro)](#setmaxmintbpro)
- [getMaxMintBPro()](#getmaxmintbpro)
- [setMoCPriceProvider(address mocProviderAddress)](#setmocpriceprovider)
- [getMoCPriceProvider()](#getmocpriceprovider)
- [getMoCPrice()](#getmocprice)
- [bproToBtc(uint256 amount)](#bprotobtc)
- [docsToBtc(uint256 docAmount)](#docstobtc)
- [btcToDoc(uint256 btcAmount)](#btctodoc)
- [bproxToBtc(uint256 bproxAmount, bytes32 bucket)](#bproxtobtc)
- [bproxToBtcHelper(uint256 bproxAmount, bytes32 bucket)](#bproxtobtchelper)
- [btcToBProx(uint256 btcAmount, bytes32 bucket)](#btctobprox)
- [setMoCToken(address mocTokenAddress)](#setmoctoken)
- [getMoCToken()](#getmoctoken)
- [setMoCVendors(address mocVendorsAddress)](#setmocvendors)
- [getMoCVendors()](#getmocvendors)
- [setMoCTokenInternal(address mocTokenAddress)](#setmoctokeninternal)
- [setMoCVendorsInternal(address mocVendorsAddress)](#setmocvendorsinternal)
- [setLiquidationPrice()](#setliquidationprice)
- [initializeValues(address _governor, address _btcPriceProvider, uint256 _liq, uint256 _utpdu, uint256 _maxDiscRate, uint256 _dayBlockSpan, uint256 _maxMintBPro, address _mocPriceProvider, bool _liquidationEnabled, uint256 _protected)](#initializevalues)
- [initializeContracts(address _mocTokenAddress, address _mocVendorsAddress)](#initializecontracts)

### initialize

⤿ Overridden Implementation(s): [MoCStateMock.initialize](MoCStateMock.md#initialize)

Initializes the contract

```js
function initialize(struct MoCState.InitializeParams params) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| params | struct MoCState.InitializeParams | Params defined in InitializeParams struct | 

### setMaxDiscountRate

Sets the max discount rate.

```js
function setMaxDiscountRate(uint256 rate) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| rate | uint256 | Discount rate at liquidation level [using mocPrecision] | 

### getMaxDiscountRate

Returns the value of the BPro max discount rate configuration param

```js
function getMaxDiscountRate() public view
returns(uint256)
```

**Returns**

bproMaxDiscountRate BPro max discount rate

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setDayBlockSpan

Defines how many blocks there are in a day

```js
function setDayBlockSpan(uint256 blockSpan) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| blockSpan | uint256 | blocks there are in a day | 

### setBtcPriceProvider

Sets a new BTCProvider contract

```js
function setBtcPriceProvider(address btcProviderAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcProviderAddress | address | address of the BTC price provider contract | 

### getBtcPriceProvider

Gets the BTCPriceProviderAddress

```js
function getBtcPriceProvider() public view
returns(address)
```

**Returns**

address of the BTC price provider contract

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getDayBlockSpan

Gets how many blocks there are in a day

```js
function getDayBlockSpan() public view
returns(uint256)
```

**Returns**

blocks there are in a day

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### subtractRbtcFromSystem

⤾ overrides IMoCState.subtractRbtcFromSystem

Subtract the btc amount passed by parameter to the total Bitcoin Amount

```js
function subtractRbtcFromSystem(uint256 btcAmount) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 | Amount that will be subtract to rbtcInSystem | 

### addToRbtcInSystem

⤾ overrides IMoCState.addToRbtcInSystem

btcAmount Add the btc amount passed by parameter to the total Bitcoin Amount

```js
function addToRbtcInSystem(uint256 btcAmount) public nonpayable onlyWhitelisted 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 | Amount that will be added to rbtcInSystem | 

### bproTotalSupply

All BPros in circulation

```js
function bproTotalSupply() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### docTotalSupply

All docs in circulation

```js
function docTotalSupply() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### cobj

Target coverage for complete system

```js
function cobj() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### collateralRbtcInSystem

Amount of Bitcoins in the system excluding BTCx values and interests holdings

```js
function collateralRbtcInSystem() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### globalCoverage

⤾ overrides IMoCState.globalCoverage

GLOBAL Coverage

```js
function globalCoverage() public view
returns(uint256)
```

**Returns**

coverage [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### lockedBitcoin

BUCKET lockedBitcoin

```js
function lockedBitcoin(bytes32 bucket) public view
returns(uint256)
```

**Returns**

lockedBitcoin amount [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### getRbtcInBitPro

Gets RBTC in BitPro within specified bucket

```js
function getRbtcInBitPro(bytes32 bucket) public view
returns(uint256)
```

**Returns**

Bitcoin amount of BitPro in Bucket [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### getRbtcRemainder

⤾ overrides IMoCState.getRbtcRemainder

Gets the RBTC in the contract that not corresponds to Doc collateral

```js
function getRbtcRemainder() public view
returns(uint256)
```

**Returns**

RBTC remainder [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### coverage

⤾ overrides IMoCState.coverage

BUCKET Coverage

```js
function coverage(bytes32 bucket) public view
returns(uint256)
```

**Returns**

coverage [using coveragePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### abundanceRatio

⤾ overrides IMoCState.abundanceRatio

Abundance ratio, receives tha amount of doc to use the value of doc0 and Doc total supply

```js
function abundanceRatio(uint256 doc0) public view
returns(uint256)
```

**Returns**

abundance ratio [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| doc0 | uint256 |  | 

### currentAbundanceRatio

⤾ overrides IMoCState.currentAbundanceRatio

Relation between docs in bucket 0 and Doc total supply

```js
function currentAbundanceRatio() public view
returns(uint256)
```

**Returns**

abundance ratio [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### leverage

⤾ overrides IMoCState.leverage

BUCKET Leverage

```js
function leverage(bytes32 bucket) public view
returns(uint256)
```

**Returns**

coverage [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### globalMaxDoc

GLOBAL maxDoc

```js
function globalMaxDoc() public view
returns(uint256)
```

**Returns**

abundance ratio [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### freeDoc

⤾ overrides IMoCState.freeDoc

Returns the amount of DoCs in bucket 0, that can be redeemed outside of settlement

```js
function freeDoc() public view
returns(uint256)
```

**Returns**

amount of docs in bucket 0, that can be redeemed outside of settlement [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### maxDoc

BUCKET maxDoc

```js
function maxDoc(bytes32 bucket) public view
returns(uint256)
```

**Returns**

abundance ratio [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### globalMaxBPro

GLOBAL maxBPro

```js
function globalMaxBPro() public view
returns(uint256)
```

**Returns**

maxBPro for redeem [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### absoluteMaxDoc

⤾ overrides IMoCState.absoluteMaxDoc

ABSOLUTE maxDoc

```js
function absoluteMaxDoc() public view
returns(uint256)
```

**Returns**

maxDoc to issue [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### maxBPro

BUCKET maxBPro to redeem / mint

```js
function maxBPro(bytes32 bucket) public view
returns(uint256)
```

**Returns**

maxBPro for redeem [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### maxBProx

GLOBAL max bprox to mint

```js
function maxBProx(bytes32 bucket) public view
returns(uint256)
```

**Returns**

maxBProx [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### maxBProxBtcValue

⤾ overrides IMoCState.maxBProxBtcValue

GLOBAL max bprox to mint

```js
function maxBProxBtcValue(bytes32 bucket) public view
returns(uint256)
```

**Returns**

maxBProx BTC value to mint [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### absoluteMaxBPro

⤾ overrides IMoCState.absoluteMaxBPro

ABSOLUTE maxBPro

```js
function absoluteMaxBPro() public view
returns(uint256)
```

**Returns**

maxDoc to issue [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### maxBProWithDiscount

⤾ overrides IMoCState.maxBProWithDiscount

DISCOUNT maxBPro

```js
function maxBProWithDiscount() public view
returns(uint256)
```

**Returns**

maxBPro for mint with discount [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### globalLockedBitcoin

GLOBAL lockedBitcoin

```js
function globalLockedBitcoin() public view
returns(uint256)
```

**Returns**

lockedBitcoin amount [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### bproTecPrice

⤾ overrides IMoCState.bproTecPrice

BTC price of BPro

```js
function bproTecPrice() public view
returns(uint256)
```

**Returns**

the BPro Tec Price [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### bucketBProTecPrice

⤾ overrides IMoCState.bucketBProTecPrice

BUCKET BTC price of BPro

```js
function bucketBProTecPrice(bytes32 bucket) public view
returns(uint256)
```

**Returns**

the BPro Tec Price [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### bucketBProTecPriceHelper

⤾ overrides IMoCState.bucketBProTecPriceHelper

BUCKET BTC price of BPro (helper)

```js
function bucketBProTecPriceHelper(bytes32 bucket) public view
returns(uint256)
```

**Returns**

the BPro Tec Price [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### bproDiscountPrice

⤾ overrides IMoCState.bproDiscountPrice

BTC price of BPro with spot discount applied

```js
function bproDiscountPrice() public view
returns(uint256)
```

**Returns**

the BPro Tec Price [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### bproUsdPrice

BPro USD PRICE

```js
function bproUsdPrice() public view
returns(uint256)
```

**Returns**

the BPro USD Price [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### maxBProxBProValue

GLOBAL max bprox to mint

```js
function maxBProxBProValue(bytes32 bucket) public view
returns(uint256)
```

**Returns**

max BPro allowed to be spent to mint BProx [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### bproxBProPrice

BUCKET BProx price in BPro

```js
function bproxBProPrice(bytes32 bucket) public view
returns(uint256)
```

**Returns**

BProx BPro Price [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Name of the bucket used | 

### bproSpotDiscountRate

⤾ overrides IMoCState.bproSpotDiscountRate

GLOBAL BTC Discount rate to apply to BProPrice.

```js
function bproSpotDiscountRate() public view
returns(uint256)
```

**Returns**

BPro discount rate [using DISCOUNT_PRECISION].

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### daysToSettlement

⤾ overrides IMoCState.daysToSettlement

⤿ Overridden Implementation(s): [MoCStateMock.daysToSettlement](MoCStateMock.md#daystosettlement)

Calculates the number of days to next settlement based dayBlockSpan

```js
function daysToSettlement() public view
returns(uint256)
```

**Returns**

days to next settlement

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### blocksToSettlement

Calculates the number of blocks to settlement

```js
function blocksToSettlement() public view
returns(uint256)
```

**Returns**

Number of blocks to settlement

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### isLiquidationReached

Verifies if forced liquidation is reached checking if globalCoverage <= liquidation (currently 1.04)
and if liquidation is enabled

```js
function isLiquidationReached() public view
returns(bool)
```

**Returns**

true if liquidation state is reached, false otherwise

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getLiquidationPrice

⤾ overrides IMoCState.getLiquidationPrice

Gets the price to use for doc redeem in a liquidation event

```js
function getLiquidationPrice() public view
returns(uint256)
```

**Returns**

price to use for doc redeem in a liquidation event

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getBucketNBTC

⤾ overrides IMoCState.getBucketNBTC

```js
function getBucketNBTC(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getBucketNBPro

```js
function getBucketNBPro(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getBucketNDoc

```js
function getBucketNDoc(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getBucketCobj

```js
function getBucketCobj(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getInrateBag

```js
function getInrateBag(bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 

### getBcons

```js
function getBcons() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getBitcoinPrice

⤾ overrides IMoCState.getBitcoinPrice

```js
function getBitcoinPrice() public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### calculateBitcoinMovingAverage

```js
function calculateBitcoinMovingAverage() public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getLiq

return the value of the liq threshold configuration param

```js
function getLiq() public view
returns(uint256)
```

**Returns**

liq threshold, currently 1.04

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setLiq

sets the value of the liq threshold configuration param

```js
function setLiq(uint256 _liq) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _liq | uint256 | liquidation threshold | 

### getUtpdu

return the value of the utpdu threshold configuration param

```js
function getUtpdu() public view
returns(uint256)
```

**Returns**

utpdu Universal TPro discount sales coverage threshold

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setUtpdu

sets the value of the utpdu threshold configuration param

```js
function setUtpdu(uint256 _utpdu) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _utpdu | uint256 | Universal TPro discount sales coverage threshold | 

### getPeg

returns the relation between DOC and dollar. By default it is 1.

```js
function getPeg() public view
returns(uint256)
```

**Returns**

peg relation between DOC and dollar

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setPeg

sets the relation between DOC and dollar. By default it is 1.

```js
function setPeg(uint256 _peg) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _peg | uint256 | relation between DOC and dollar | 

### getProtected

⤾ overrides IMoCState.getProtected

return the value of the protected threshold configuration param

```js
function getProtected() public view
returns(uint256)
```

**Returns**

protected threshold, currently 1.5

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setProtected

sets the value of the protected threshold configuration param

```js
function setProtected(uint256 _protected) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _protected | uint256 | protected threshold | 

### getLiquidationEnabled

returns if is liquidation enabled.

```js
function getLiquidationEnabled() public view
returns(bool)
```

**Returns**

liquidationEnabled is liquidation enabled

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setLiquidationEnabled

returns if is liquidation enabled.

```js
function setLiquidationEnabled(bool _liquidationEnabled) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _liquidationEnabled | bool | is liquidation enabled | 

### nextState

⤾ overrides IMoCState.nextState

Transitions to next state.

```js
function nextState() public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setMaxMintBPro

Sets max mint BPro value

```js
function setMaxMintBPro(uint256 _maxMintBPro) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _maxMintBPro | uint256 | [using mocPrecision] | 

### getMaxMintBPro

return Max value posible to mint of BPro

```js
function getMaxMintBPro() public view
returns(uint256)
```

**Returns**

maxMintBPro

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setMoCPriceProvider

Sets a new MoCProvider contract

```js
function setMoCPriceProvider(address mocProviderAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocProviderAddress | address | MoC price provider address | 

### getMoCPriceProvider

Gets the MoCPriceProviderAddress

```js
function getMoCPriceProvider() public view
returns(address)
```

**Returns**

MoC price provider address

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### getMoCPrice

⤾ overrides IMoCState.getMoCPrice

Gets the MoCPrice

```js
function getMoCPrice() public view
returns(uint256)
```

**Returns**

MoC price

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### bproToBtc

BTC equivalent for the amount of bpros given

```js
function bproToBtc(uint256 amount) public view
returns(uint256)
```

**Returns**

total BTC Price of the amount BPros [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| amount | uint256 | Amount of BPro to calculate the total price | 

### docsToBtc

⤾ overrides IMoCState.docsToBtc

```js
function docsToBtc(uint256 docAmount) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| docAmount | uint256 |  | 

### btcToDoc

⤾ overrides IMoCState.btcToDoc

```js
function btcToDoc(uint256 btcAmount) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 |  | 

### bproxToBtc

⤾ overrides IMoCState.bproxToBtc

```js
function bproxToBtc(uint256 bproxAmount, bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproxAmount | uint256 |  | 
| bucket | bytes32 |  | 

### bproxToBtcHelper

```js
function bproxToBtcHelper(uint256 bproxAmount, bytes32 bucket) internal view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproxAmount | uint256 |  | 
| bucket | bytes32 |  | 

### btcToBProx

⤾ overrides IMoCState.btcToBProx

```js
function btcToBProx(uint256 btcAmount, bytes32 bucket) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| btcAmount | uint256 |  | 
| bucket | bytes32 |  | 

### setMoCToken

Sets the MoC token contract address

```js
function setMoCToken(address mocTokenAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocTokenAddress | address | MoC token contract address | 

### getMoCToken

⤾ overrides IMoCState.getMoCToken

Gets the MoC token contract address

```js
function getMoCToken() public view
returns(address)
```

**Returns**

MoC token contract address

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setMoCVendors

Sets the MoCVendors contract address

```js
function setMoCVendors(address mocVendorsAddress) public nonpayable onlyAuthorizedChanger 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocVendorsAddress | address | MoCVendors contract address | 

### getMoCVendors

⤾ overrides IMoCState.getMoCVendors

Gets the MoCVendors contract addfress

```js
function getMoCVendors() public view
returns(address)
```

**Returns**

MoCVendors contract address

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setMoCTokenInternal

Sets the MoC token contract address (internal function)

```js
function setMoCTokenInternal(address mocTokenAddress) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocTokenAddress | address | MoC token contract address | 

### setMoCVendorsInternal

Sets the MoCVendors contract address (internal function)

```js
function setMoCVendorsInternal(address mocVendorsAddress) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocVendorsAddress | address | MoCVendors contract address | 

### setLiquidationPrice

Calculates price at liquidation event as the relation between
the doc total supply and the amount of RBTC available to distribute

```js
function setLiquidationPrice() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### initializeValues

```js
function initializeValues(address _governor, address _btcPriceProvider, uint256 _liq, uint256 _utpdu, uint256 _maxDiscRate, uint256 _dayBlockSpan, uint256 _maxMintBPro, address _mocPriceProvider, bool _liquidationEnabled, uint256 _protected) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _governor | address |  | 
| _btcPriceProvider | address |  | 
| _liq | uint256 |  | 
| _utpdu | uint256 |  | 
| _maxDiscRate | uint256 |  | 
| _dayBlockSpan | uint256 |  | 
| _maxMintBPro | uint256 |  | 
| _mocPriceProvider | address |  | 
| _liquidationEnabled | bool |  | 
| _protected | uint256 |  | 

### initializeContracts

```js
function initializeContracts(address _mocTokenAddress, address _mocVendorsAddress) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _mocTokenAddress | address |  | 
| _mocVendorsAddress | address |  | 

