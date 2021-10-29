---
id: version-0.1.12-MoCHelperLib
title: MoCHelperLib
original_id: MoCHelperLib
---

# MoCHelperLib.sol

View Source: [contracts/MoCHelperLib.sol](../../contracts/MoCHelperLib.sol)

**MoCHelperLib** - version: 0.1.12

## Structs
### MocLibConfig

```js
struct MocLibConfig {
 uint256 reservePrecision,
 uint256 dayPrecision,
 uint256 mocPrecision
}
```

## Contract Members
**Constants & Variables**

```js
uint256 internal constant UINT256_MAX;
```
---

## Functions

- [getMaxInt(struct MoCHelperLib.MocLibConfig )](#getmaxint)
- [inrateAvg(struct MoCHelperLib.MocLibConfig config, uint256 tMax, uint256 power, uint256 tMin, uint256 abRat1, uint256 abRat2)](#inrateavg)
- [spotInrate(struct MoCHelperLib.MocLibConfig config, uint256 tMax, uint256 power, uint256 tMin, uint256 abRatio)](#spotinrate)
- [potential(struct MoCHelperLib.MocLibConfig config, uint256 a, uint256 b, uint256 c, uint256 value)](#potential)
- [avgInt(struct MoCHelperLib.MocLibConfig config, uint256 a, uint256 b, uint256 c, uint256 value1, uint256 value2)](#avgint)
- [integral(struct MoCHelperLib.MocLibConfig config, uint256 a, uint256 b, uint256 c, uint256 value)](#integral)
- [abundanceRatio(struct MoCHelperLib.MocLibConfig config, uint256 doc0, uint256 doct)](#abundanceratio)
- [bproSpotDiscountRate(struct MoCHelperLib.MocLibConfig libConfig, uint256 bproLiqDiscountRate, uint256 liq, uint256 utpdu, uint256 cov)](#bprospotdiscountrate)
- [maxBProWithDiscount(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 nDoc, uint256 utpdu, uint256 peg, uint256 btcPrice, uint256 bproUsdPrice, uint256 spotDiscount)](#maxbprowithdiscount)
- [maxBProWithDiscountAux(struct MoCHelperLib.MocLibConfig libConfig, uint256 nbUsdValue, uint256 nDoc, uint256 utpdu, uint256 peg, uint256 bproDiscountPrice)](#maxbprowithdiscountaux)
- [lockedBitcoin(struct MoCHelperLib.MocLibConfig libConfig, uint256 btcPrice, uint256 nDoc, uint256 peg)](#lockedbitcoin)
- [liquidationPrice(struct MoCHelperLib.MocLibConfig libConfig, uint256 rbtcAmount, uint256 nDoc)](#liquidationprice)
- [bproTecPrice(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 lb, uint256 nTP)](#bprotecprice)
- [bproxBProPrice(struct MoCHelperLib.MocLibConfig libConfig, uint256 bproxTecPrice, uint256 bproPrice)](#bproxbproprice)
- [applyDiscountRate(struct MoCHelperLib.MocLibConfig libConfig, uint256 price, uint256 discountRate)](#applydiscountrate)
- [getInterestCost(struct MoCHelperLib.MocLibConfig libConfig, uint256 value, uint256 interestRate)](#getinterestcost)
- [coverage(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 lB)](#coverage)
- [leverageFromCoverage(struct MoCHelperLib.MocLibConfig libConfig, uint256 cov)](#leveragefromcoverage)
- [leverage(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 lB)](#leverage)
- [docsBtcValue(struct MoCHelperLib.MocLibConfig libConfig, uint256 amount, uint256 peg, uint256 btcPrice)](#docsbtcvalue)
- [bproBtcValue(struct MoCHelperLib.MocLibConfig libConfig, uint256 bproAmount, uint256 bproBtcPrice)](#bprobtcvalue)
- [maxDoc(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 cobj, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons)](#maxdoc)
- [maxDocAux(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 adjCobj, uint256 nDoc, uint256 peg, uint256 btcPrice)](#maxdocaux)
- [maxBPro(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 cobj, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons, uint256 bproUsdPrice)](#maxbpro)
- [totalBProInBtc(struct MoCHelperLib.MocLibConfig libConfig, uint256 amount, uint256 bproPrice)](#totalbproinbtc)
- [maxDocsWithBtc(struct MoCHelperLib.MocLibConfig libConfig, uint256 btcAmount, uint256 btcPrice)](#maxdocswithbtc)
- [maxBProWithBtc(struct MoCHelperLib.MocLibConfig libConfig, uint256 btcAmount, uint256 bproPrice)](#maxbprowithbtc)
- [bucketTransferAmount(struct MoCHelperLib.MocLibConfig libConfig, uint256 btcAmount, uint256 lev)](#buckettransferamount)
- [maxBProxBtcValue(struct MoCHelperLib.MocLibConfig libConfig, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 lev)](#maxbproxbtcvalue)
- [maxMoCWithBtc(struct MoCHelperLib.MocLibConfig , uint256 btcAmount, uint256 btcPrice, uint256 mocPrice)](#maxmocwithbtc)
- [mocBtcValue(struct MoCHelperLib.MocLibConfig , uint256 amount, uint256 btcPrice, uint256 mocPrice)](#mocbtcvalue)
- [getPayableAddress(struct MoCHelperLib.MocLibConfig , address account)](#getpayableaddress)
- [mulr(uint256 x, uint256 y, uint256 precision)](#mulr)
- [pow(uint256 x, uint256 n, uint256 precision)](#pow)

### getMaxInt

Returns max uint256 value constant.

```js
function getMaxInt(struct MoCHelperLib.MocLibConfig ) public pure
returns(uint256)
```

**Returns**

max uint256 value constant

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
|  | struct MoCHelperLib.MocLibConfig |  | 

### inrateAvg

Calculates average interest using integral function: T =  Rate = a * (x ** b) + c

```js
function inrateAvg(struct MoCHelperLib.MocLibConfig config, uint256 tMax, uint256 power, uint256 tMin, uint256 abRat1, uint256 abRat2) public view
returns(uint256)
```

**Returns**

average interest rate [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| config | struct MoCHelperLib.MocLibConfig |  | 
| tMax | uint256 | maxInterestRate [using mocPrecision] | 
| power | uint256 | factor [using noPrecision] | 
| tMin | uint256 | minInterestRate C0 doc amount [using mocPrecision] | 
| abRat1 | uint256 | initial abundance ratio [using mocPrecision] | 
| abRat2 | uint256 | final abundance ratio [using mocPrecision] | 

### spotInrate

Calculates spot interest rate that BProx owners should pay to BPro owners: Rate = tMax * (abRatio ** power) + tMin

```js
function spotInrate(struct MoCHelperLib.MocLibConfig config, uint256 tMax, uint256 power, uint256 tMin, uint256 abRatio) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| config | struct MoCHelperLib.MocLibConfig |  | 
| tMax | uint256 | max interest rate [using mocPrecision] | 
| power | uint256 | power to use in the formula [using NoPrecision] | 
| tMin | uint256 | min interest rate [using mocPrecision] | 
| abRatio | uint256 | bucket C0  abundance Ratio [using mocPrecision] | 

### potential

Calculates potential interests function with given parameters: Rate = a * (x ** b) + c

```js
function potential(struct MoCHelperLib.MocLibConfig config, uint256 a, uint256 b, uint256 c, uint256 value) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| config | struct MoCHelperLib.MocLibConfig |  | 
| a | uint256 | maxInterestRate [using mocPrecision] | 
| b | uint256 | factor [using NoPrecision] | 
| c | uint256 | minInterestRate C0 doc amount [using mocPrecision] | 
| value | uint256 | global doc amount [using mocPrecision] | 

### avgInt

Calculates average of the integral function:
T = (
(c * xf + ((a * (xf ** (b + 1))) / (b + 1))) -
(c * xi + ((a * (xi ** (b + 1))) / (b + 1)))
) / (xf - xi)

```js
function avgInt(struct MoCHelperLib.MocLibConfig config, uint256 a, uint256 b, uint256 c, uint256 value1, uint256 value2) public view
returns(uint256)
```

**Returns**

average interest rate [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| config | struct MoCHelperLib.MocLibConfig |  | 
| a | uint256 | maxInterestRate [using mocPrecision] | 
| b | uint256 | factor [using NoPrecision] | 
| c | uint256 | minInterestRate C0 doc amount [using mocPrecision] | 
| value1 | uint256 | value to put in the function [using mocPrecision] | 
| value2 | uint256 | value to put in the function [using mocPrecision] | 

### integral

Calculates integral of the exponential function: T = c * (value) + (a * value ** (b + 1)) / (b + 1))

```js
function integral(struct MoCHelperLib.MocLibConfig config, uint256 a, uint256 b, uint256 c, uint256 value) public view
returns(uint256)
```

**Returns**

integration result [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| config | struct MoCHelperLib.MocLibConfig |  | 
| a | uint256 | maxInterestRate [using mocPrecision] | 
| b | uint256 | factor [using NoPrecision] | 
| c | uint256 | minInterestRate C0 doc amount [using mocPrecision] | 
| value | uint256 | value to put in the function [using mocPrecision] | 

### abundanceRatio

Relation between docs in bucket 0 and Doc total supply

```js
function abundanceRatio(struct MoCHelperLib.MocLibConfig config, uint256 doc0, uint256 doct) public view
returns(uint256)
```

**Returns**

abundance ratio [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| config | struct MoCHelperLib.MocLibConfig |  | 
| doc0 | uint256 | doc count in bucket 0 [using mocPrecision] | 
| doct | uint256 | total doc supply [using mocPrecision] | 

### bproSpotDiscountRate

Returns the Ratio to apply to BPro Price in discount situations: SpotDiscountRate = TPD * (utpdu - cob) / (uptdu -liq)

```js
function bproSpotDiscountRate(struct MoCHelperLib.MocLibConfig libConfig, uint256 bproLiqDiscountRate, uint256 liq, uint256 utpdu, uint256 cov) public view
returns(uint256)
```

**Returns**

Spot discount rate [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| bproLiqDiscountRate | uint256 | Discount rate applied at Liquidation level coverage [using mocPrecision] | 
| liq | uint256 | Liquidation coverage threshold [using mocPrecision] | 
| utpdu | uint256 | Discount coverage threshold [using mocPrecision] | 
| cov | uint256 | Actual global Coverage threshold [using mocPrecision] | 

### maxBProWithDiscount

Max amount of BPro to available with discount: MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)

```js
function maxBProWithDiscount(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 nDoc, uint256 utpdu, uint256 peg, uint256 btcPrice, uint256 bproUsdPrice, uint256 spotDiscount) public view
returns(uint256)
```

**Returns**

Total BPro amount [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nB | uint256 | Total BTC amount [using reservePrecision] | 
| nDoc | uint256 | DOC amount [using mocPrecision] | 
| utpdu | uint256 | Discount coverage threshold [using mocPrecision] | 
| peg | uint256 | peg value | 
| btcPrice | uint256 | BTC price [using mocPrecision] | 
| bproUsdPrice | uint256 | bproUsdPrice [using mocPrecision] | 
| spotDiscount | uint256 | spot discount [using mocPrecision] | 

### maxBProWithDiscountAux

Max amount of BPro to available with discount: MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)

```js
function maxBProWithDiscountAux(struct MoCHelperLib.MocLibConfig libConfig, uint256 nbUsdValue, uint256 nDoc, uint256 utpdu, uint256 peg, uint256 bproDiscountPrice) internal view
returns(uint256)
```

**Returns**

Total BPro amount [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nbUsdValue | uint256 | Total amount of BTC in USD [using mocPrecision] | 
| nDoc | uint256 | DOC amount [using mocPrecision] | 
| utpdu | uint256 | Discount coverage threshold [using mocPrecision] | 
| peg | uint256 | peg value | 
| bproDiscountPrice | uint256 | bproUsdPrice with discount applied [using mocPrecision] | 

### lockedBitcoin

Calculates Locked bitcoin

```js
function lockedBitcoin(struct MoCHelperLib.MocLibConfig libConfig, uint256 btcPrice, uint256 nDoc, uint256 peg) public view
returns(uint256)
```

**Returns**

Locked bitcoin [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| btcPrice | uint256 | BTC price [using mocPrecision] | 
| nDoc | uint256 | Docs amount [using mocPrecision] | 
| peg | uint256 | peg value | 

### liquidationPrice

Calculates price at liquidation event as a relation between the doc total supply
and the amount of RBTC available to distribute

```js
function liquidationPrice(struct MoCHelperLib.MocLibConfig libConfig, uint256 rbtcAmount, uint256 nDoc) public view
returns(uint256)
```

**Returns**

Price at liquidation event [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| rbtcAmount | uint256 | RBTC to distribute [using reservePrecision] | 
| nDoc | uint256 | Docs amount [using mocPrecision] | 

### bproTecPrice

Calculates BPro BTC price: TPbtc = (nB-LB) / nTP

```js
function bproTecPrice(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 lb, uint256 nTP) public view
returns(uint256)
```

**Returns**

BPro BTC price [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nB | uint256 | Total BTC amount [using reservePrecision] | 
| lb | uint256 | Locked bitcoins amount [using reservePrecision] | 
| nTP | uint256 | BPro amount [using mocPrecision] | 

### bproxBProPrice

Calculates BPro BTC price: BProxInBPro = bproxTecPrice / bproPrice

```js
function bproxBProPrice(struct MoCHelperLib.MocLibConfig libConfig, uint256 bproxTecPrice, uint256 bproPrice) public view
returns(uint256)
```

**Returns**

BProx price in BPro [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| bproxTecPrice | uint256 | BProx BTC price [using reservePrecision] | 
| bproPrice | uint256 | Trog BTC price [using reservePrecision] | 

### applyDiscountRate

Returns a new value with the discountRate applied: TPbtc = (price)* (1 - discountRate)

```js
function applyDiscountRate(struct MoCHelperLib.MocLibConfig libConfig, uint256 price, uint256 discountRate) public view
returns(uint256)
```

**Returns**

Price with discount applied [using SomePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| price | uint256 | Price [using SomePrecision] | 
| discountRate | uint256 | Discount rate to apply [using mocPrecision] | 

### getInterestCost

Returns the amount of interest to pay: TPbtc = price * interestRate

```js
function getInterestCost(struct MoCHelperLib.MocLibConfig libConfig, uint256 value, uint256 interestRate) public view
returns(uint256)
```

**Returns**

Interest cost based on the value and interestRate [using SomePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| value | uint256 | Cost to apply interest [using SomePrecision] | 
| interestRate | uint256 | Interest rate to apply [using mocPrecision] | 

### coverage

Calculates Coverage: Coverage = nB / LB

```js
function coverage(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 lB) public view
returns(uint256)
```

**Returns**

Coverage [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nB | uint256 | Total BTC amount [using reservePrecision] | 
| lB | uint256 | Locked bitcoins amount [using reservePrecision] | 

### leverageFromCoverage

Calculates Leverage from Coverage: Leverage = C / (C - 1)

```js
function leverageFromCoverage(struct MoCHelperLib.MocLibConfig libConfig, uint256 cov) public view
returns(uint256)
```

**Returns**

Leverage [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| cov | uint256 | Coverage [using mocPrecision] | 

### leverage

Calculates Leverage: Leverage = nB / (nB - lB)

```js
function leverage(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 lB) public view
returns(uint256)
```

**Returns**

Leverage [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nB | uint256 | Total BTC amount [using reservePrecision] | 
| lB | uint256 | Locked bitcoins amount [using reservePrecision] | 

### docsBtcValue

Price in BTC of the amount of Docs

```js
function docsBtcValue(struct MoCHelperLib.MocLibConfig libConfig, uint256 amount, uint256 peg, uint256 btcPrice) public view
returns(uint256)
```

**Returns**

Total value [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| amount | uint256 | Total BTC amount [using reservePrecision] | 
| peg | uint256 |  | 
| btcPrice | uint256 | BTC price [using mocPrecision] | 

### bproBtcValue

Price in RBTC of the amount of BPros

```js
function bproBtcValue(struct MoCHelperLib.MocLibConfig libConfig, uint256 bproAmount, uint256 bproBtcPrice) public view
returns(uint256)
```

**Returns**

Total value [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| bproAmount | uint256 | amount of BPro [using mocPrecision] | 
| bproBtcPrice | uint256 | BPro price in RBTC [using reservePrecision] | 

### maxDoc

Max amount of Docs to issue: MaxDoc = ((nB*B)-(Cobj*B/Bcons*nDoc*PEG))/(PEG*(Cobj*B/BCons-1))

```js
function maxDoc(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 cobj, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons) public view
returns(uint256)
```

**Returns**

Total Docs amount [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nB | uint256 | Total BTC amount [using reservePrecision] | 
| cobj | uint256 | Target Coverage [using mocPrecision] | 
| nDoc | uint256 | DOC amount [using mocPrecision] | 
| peg | uint256 | peg value | 
| btcPrice | uint256 | BTC price [using mocPrecision] | 
| bCons | uint256 | BTC conservative price [using mocPrecision] | 

### maxDocAux

```js
function maxDocAux(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 adjCobj, uint256 nDoc, uint256 peg, uint256 btcPrice) internal view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nB | uint256 |  | 
| adjCobj | uint256 |  | 
| nDoc | uint256 |  | 
| peg | uint256 |  | 
| btcPrice | uint256 |  | 

### maxBPro

Max amount of BPro to redeem: MaxBPro = ((nB*B)-(Cobj*nDoc*PEG))/TPusd

```js
function maxBPro(struct MoCHelperLib.MocLibConfig libConfig, uint256 nB, uint256 cobj, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons, uint256 bproUsdPrice) public view
returns(uint256)
```

**Returns**

Total BPro amount [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nB | uint256 | Total BTC amount [using reservePrecision] | 
| cobj | uint256 | Target Coverage [using mocPrecision] | 
| nDoc | uint256 | Target Coverage [using mocPrecision] | 
| peg | uint256 | peg value | 
| btcPrice | uint256 | BTC price [using mocPrecision] | 
| bCons | uint256 | BTC conservative price [using mocPrecision] | 
| bproUsdPrice | uint256 | bproUsdPrice [using mocPrecision] | 

### totalBProInBtc

Calculates the total BTC price of the amount of BPros

```js
function totalBProInBtc(struct MoCHelperLib.MocLibConfig libConfig, uint256 amount, uint256 bproPrice) public view
returns(uint256)
```

**Returns**

BPro total value in BTC [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| amount | uint256 | Amount of BPro [using mocPrecision] | 
| bproPrice | uint256 | BPro BTC Price [using reservePrecision] | 

### maxDocsWithBtc

Calculates the equivalent in Docs of the btcAmount

```js
function maxDocsWithBtc(struct MoCHelperLib.MocLibConfig libConfig, uint256 btcAmount, uint256 btcPrice) public view
returns(uint256)
```

**Returns**

Equivalent Doc amount [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| btcAmount | uint256 | BTC  amount [using reservePrecision] | 
| btcPrice | uint256 | BTC price [using mocPrecision] | 

### maxBProWithBtc

Calculates the equivalent in BPro of the btcAmount

```js
function maxBProWithBtc(struct MoCHelperLib.MocLibConfig libConfig, uint256 btcAmount, uint256 bproPrice) public view
returns(uint256)
```

**Returns**

Equivalent Bpro amount [using mocPrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| btcAmount | uint256 | BTC amount [using reservePrecision] | 
| bproPrice | uint256 | BPro BTC price [using reservePrecision] | 

### bucketTransferAmount

Calculates the Btc amount to move from C0 bucket to: toMove = btcAmount * (lev - 1)
an L bucket when a BProx minting occurs

```js
function bucketTransferAmount(struct MoCHelperLib.MocLibConfig libConfig, uint256 btcAmount, uint256 lev) public view
returns(uint256)
```

**Returns**

btc to move [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| btcAmount | uint256 | Total BTC amount [using reservePrecision] | 
| lev | uint256 | L bucket leverage [using mocPrecision] | 

### maxBProxBtcValue

Max amount of BTC allowed to be used to mint bprox: Maxbprox = nDOC/ (PEG*B*(lev-1))

```js
function maxBProxBtcValue(struct MoCHelperLib.MocLibConfig libConfig, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 lev) public view
returns(uint256)
```

**Returns**

Max bprox BTC value [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| libConfig | struct MoCHelperLib.MocLibConfig |  | 
| nDoc | uint256 | number of DOC [using mocPrecision] | 
| peg | uint256 | peg value | 
| btcPrice | uint256 | BTC price [using mocPrecision] | 
| lev | uint256 | leverage [using mocPrecision] | 

### maxMoCWithBtc

Calculates the equivalent in MoC of the btcAmount

```js
function maxMoCWithBtc(struct MoCHelperLib.MocLibConfig , uint256 btcAmount, uint256 btcPrice, uint256 mocPrice) public pure
returns(uint256)
```

**Returns**

Equivalent MoC amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
|  | struct MoCHelperLib.MocLibConfig | btcAmount BTC  amount | 
| btcAmount | uint256 | BTC  amount | 
| btcPrice | uint256 | BTC price | 
| mocPrice | uint256 | MoC price | 

### mocBtcValue

Calculates the equivalent in BTC of the MoC amount

```js
function mocBtcValue(struct MoCHelperLib.MocLibConfig , uint256 amount, uint256 btcPrice, uint256 mocPrice) public pure
returns(uint256)
```

**Returns**

Equivalent MoC amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
|  | struct MoCHelperLib.MocLibConfig | amount BTC  amount | 
| amount | uint256 | BTC  amount | 
| btcPrice | uint256 | BTC price | 
| mocPrice | uint256 | MoC price | 

### getPayableAddress

Transform an address to payable address

```js
function getPayableAddress(struct MoCHelperLib.MocLibConfig , address account) public pure
returns(address payable)
```

**Returns**

Payable address for account

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
|  | struct MoCHelperLib.MocLibConfig | account Address to transform to payable | 
| account | address | Address to transform to payable | 

### mulr

Rounding product adapted from DSMath but with custom precision

```js
function mulr(uint256 x, uint256 y, uint256 precision) internal pure
returns(z uint256)
```

**Returns**

Product

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| x | uint256 | Multiplicand | 
| y | uint256 | Multiplier | 
| precision | uint256 |  | 

### pow

Potentiation by squaring adapted from DSMath but with custom precision

```js
function pow(uint256 x, uint256 n, uint256 precision) internal pure
returns(z uint256)
```

**Returns**

power

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| x | uint256 | Base | 
| n | uint256 | Exponent | 
| precision | uint256 |  | 

