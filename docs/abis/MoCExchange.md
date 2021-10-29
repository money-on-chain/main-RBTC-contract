---
id: version-0.1.12-MoCExchange
title: MoCExchange
original_id: MoCExchange
---

# MoCExchange.sol

View Source: [contracts/MoCExchange.sol](../../contracts/MoCExchange.sol)

**↗ Extends: [MoCExchangeEvents](MoCExchangeEvents.md), [MoCBase](MoCBase.md), [MoCLibConnection](MoCLibConnection.md), [IMoCExchange](IMoCExchange.md)**

**MoCExchange** - version: 0.1.12

## Structs
### RiskProxRedeemStruct

```js
struct RiskProxRedeemStruct {
 uint256 totalBtcRedeemed,
 uint256 btcTotalWithoutCommission,
 uint256 rbtcInterests,
 uint256 bucketLev,
 uint256 bproxToRedeem,
 uint256 rbtcToRedeem,
 uint256 bproxPrice,
 struct MoCExchange.CommissionReturnStruct commission
}
```

### RiskProxMintStruct

```js
struct RiskProxMintStruct {
 uint256 bproxToMint,
 uint256 finalBtcToMint,
 uint256 btcInterestAmount,
 uint256 lev,
 struct MoCExchange.CommissionReturnStruct commission
}
```

### RiskProRedeemStruct

```js
struct RiskProRedeemStruct {
 uint256 bproFinalAmount,
 uint256 btcTotalWithoutCommission,
 struct MoCExchange.CommissionReturnStruct commission
}
```

### FreeStableTokenRedeemStruct

```js
struct FreeStableTokenRedeemStruct {
 uint256 finalDocAmount,
 uint256 finalBtcAmount,
 uint256 btcInterestAmount,
 struct MoCExchange.CommissionReturnStruct commission
}
```

### RiskProMintStruct

```js
struct RiskProMintStruct {
 uint256 bproRegularPrice,
 uint256 btcValue,
 uint256 discountPrice,
 uint256 bproDiscountAmount,
 uint256 regularBProAmount,
 uint256 availableBPro,
 uint256 finalBProAmount,
 struct MoCExchange.CommissionReturnStruct commission
}
```

### StableTokenMintStruct

```js
struct StableTokenMintStruct {
 uint256 docs,
 uint256 docAmount,
 uint256 totalCost,
 struct MoCExchange.CommissionReturnStruct commission
}
```

### CommissionParamsStruct

```js
struct CommissionParamsStruct {
 address account,
 uint256 amount,
 uint8 txTypeFeesMOC,
 uint8 txTypeFeesRBTC,
 address vendorAccount
}
```

### CommissionReturnStruct

```js
struct CommissionReturnStruct {
 uint256 btcCommission,
 uint256 mocCommission,
 uint256 btcPrice,
 uint256 mocPrice,
 uint256 btcMarkup,
 uint256 mocMarkup
}
```

### StableTokenRedeemStruct

```js
struct StableTokenRedeemStruct {
 uint256 reserveTotal,
 uint256 btcToRedeem,
 uint256 totalBtc,
 struct MoCExchange.CommissionReturnStruct commission
}
```

## Contract Members
**Constants & Variables**

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
contract BProToken internal bproToken;
```
---

```js
contract DocToken internal docToken;
```
---

```js
contract IMoCInrate internal mocInrate;
```
---

```js
contract IMoC internal moc;
```
---

```js
uint256[50] private upgradeGap;
```
---

## RiskProMint

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 
| reserveTotal | uint256 |  | 
| commission | uint256 |  | 
| reservePrice | uint256 |  | 
| mocCommissionValue | uint256 |  | 
| mocPrice | uint256 |  | 
| btcMarkup | uint256 |  | 
| mocMarkup | uint256 |  | 
| vendorAccount | address |  | 

## RiskProWithDiscountMint

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| riskProTecPrice | uint256 |  | 
| riskProDiscountPrice | uint256 |  | 
| amount | uint256 |  | 

## RiskProRedeem

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 
| reserveTotal | uint256 |  | 
| commission | uint256 |  | 
| reservePrice | uint256 |  | 
| mocCommissionValue | uint256 |  | 
| mocPrice | uint256 |  | 
| btcMarkup | uint256 |  | 
| mocMarkup | uint256 |  | 
| vendorAccount | address |  | 

## StableTokenMint

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 
| reserveTotal | uint256 |  | 
| commission | uint256 |  | 
| reservePrice | uint256 |  | 
| mocCommissionValue | uint256 |  | 
| mocPrice | uint256 |  | 
| btcMarkup | uint256 |  | 
| mocMarkup | uint256 |  | 
| vendorAccount | address |  | 

## StableTokenRedeem

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 
| reserveTotal | uint256 |  | 
| commission | uint256 |  | 
| reservePrice | uint256 |  | 
| mocCommissionValue | uint256 |  | 
| mocPrice | uint256 |  | 
| btcMarkup | uint256 |  | 
| mocMarkup | uint256 |  | 
| vendorAccount | address |  | 

## FreeStableTokenRedeem

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 
| reserveTotal | uint256 |  | 
| commission | uint256 |  | 
| interests | uint256 |  | 
| reservePrice | uint256 |  | 
| mocCommissionValue | uint256 |  | 
| mocPrice | uint256 |  | 
| btcMarkup | uint256 |  | 
| mocMarkup | uint256 |  | 
| vendorAccount | address |  | 

## RiskProxMint

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 
| account | address |  | 
| amount | uint256 |  | 
| reserveTotal | uint256 |  | 
| interests | uint256 |  | 
| leverage | uint256 |  | 
| commission | uint256 |  | 
| reservePrice | uint256 |  | 
| mocCommissionValue | uint256 |  | 
| mocPrice | uint256 |  | 
| btcMarkup | uint256 |  | 
| mocMarkup | uint256 |  | 
| vendorAccount | address |  | 

## RiskProxRedeem

**Parameters**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 |  | 
| account | address |  | 
| commission | uint256 |  | 
| amount | uint256 |  | 
| reserveTotal | uint256 |  | 
| interests | uint256 |  | 
| leverage | uint256 |  | 
| reservePrice | uint256 |  | 
| mocCommissionValue | uint256 |  | 
| mocPrice | uint256 |  | 
| btcMarkup | uint256 |  | 
| mocMarkup | uint256 |  | 
| vendorAccount | address |  | 

## Functions

- [initialize(address connectorAddress)](#initialize)
- [getMoCTokenBalance(address owner, address spender)](#getmoctokenbalance)
- [calculateCommissionsWithPrices(struct MoCExchange.CommissionParamsStruct params)](#calculatecommissionswithprices)
- [bproDiscToBtc(uint256 bproAmount, uint256 bproTecPrice, uint256 bproDiscountRate)](#bprodisctobtc)
- [mintBPro(address account, uint256 btcAmount, address vendorAccount)](#mintbpro)
- [redeemBPro(address account, uint256 bproAmount, address vendorAccount)](#redeembpro)
- [redeemFreeDoc(address account, uint256 docAmount, address vendorAccount)](#redeemfreedoc)
- [mintDoc(address account, uint256 btcToMint, address vendorAccount)](#mintdoc)
- [redeemDocWithPrice(address payable userAddress, uint256 amount, uint256 btcPrice)](#redeemdocwithprice)
- [redeemAllDoc(address origin, address payable destination)](#redeemalldoc)
- [mintBProx(address payable account, bytes32 bucket, uint256 btcToMint, address vendorAccount)](#mintbprox)
- [redeemBProx(address payable account, bytes32 bucket, uint256 bproxAmount, address vendorAccount)](#redeembprox)
- [forceRedeemBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice)](#forceredeembprox)
- [burnBProxFor(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice)](#burnbproxfor)
- [redeemBProxInternal(address account, bytes32 bucket, uint256 bproxAmount, struct MoCExchange.RiskProxRedeemStruct details, address vendorAccount)](#redeembproxinternal)
- [mintBProInternal(address account, uint256 btcAmount, struct MoCExchange.RiskProMintStruct details, address vendorAccount)](#mintbprointernal)
- [mintBProxInternal(address account, bytes32 bucket, struct MoCExchange.RiskProxMintStruct details, address vendorAccount)](#mintbproxinternal)
- [mintDocInternal(address account, struct MoCExchange.StableTokenMintStruct details, address vendorAccount)](#mintdocinternal)
- [redeemFreeDocInternal(address account, struct MoCExchange.FreeStableTokenRedeemStruct details, address vendorAccount)](#redeemfreedocinternal)
- [redeemBProInternal(address account, struct MoCExchange.RiskProRedeemStruct details, address vendorAccount)](#redeembprointernal)
- [redeemDocWithPriceInternal(address account, uint256 amount, struct MoCExchange.StableTokenRedeemStruct details, address vendorAccount)](#redeemdocwithpriceinternal)
- [moveExtraFundsToBucket(bytes32 bucketFrom, bytes32 bucketTo, uint256 totalBtc, uint256 lev)](#moveextrafundstobucket)
- [recoverInterests(bytes32 bucket, uint256 rbtcToRedeem)](#recoverinterests)
- [doDocRedeem(address userAddress, uint256 docAmount, uint256 totalBtc)](#dodocredeem)
- [initializeContracts()](#initializecontracts)

### initialize

Initializes the contract

```js
function initialize(address connectorAddress) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| connectorAddress | address | MoCConnector contract address | 

### getMoCTokenBalance

⤾ overrides IMoCExchange.getMoCTokenBalance

Converts MoC commission from RBTC to MoC price

```js
function getMoCTokenBalance(address owner, address spender) public view
returns(mocBalance uint256, mocAllowance uint256)
```

**Returns**

MoC balance of owner and MoC allowance of spender

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| owner | address | address of token owner | 
| spender | address | address of token spender | 

### calculateCommissionsWithPrices

Calculates commissions in MoC and BTC

```js
function calculateCommissionsWithPrices(struct MoCExchange.CommissionParamsStruct params) public view
returns(ret struct MoCExchange.CommissionReturnStruct)
```

**Returns**

Commissions calculated in MoC price and bitcoin price; and Bitcoin and MoC prices

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| params | struct MoCExchange.CommissionParamsStruct | Params defined in CommissionParamsStruct | 

### bproDiscToBtc

BTC equivalent for the amount of bpro given applying the spotDiscountRate

```js
function bproDiscToBtc(uint256 bproAmount, uint256 bproTecPrice, uint256 bproDiscountRate) internal view
returns(uint256)
```

**Returns**

BTC amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bproAmount | uint256 | amount of BPro [using mocPrecision] | 
| bproTecPrice | uint256 | price of BPro without discounts [using mocPrecision] | 
| bproDiscountRate | uint256 | BPro discounts [using mocPrecision] | 

### mintBPro

⤾ overrides IMoCExchange.mintBPro

Mint BPros and give it to the msg.sender

```js
function mintBPro(address account, uint256 btcAmount, address vendorAccount) external nonpayable onlyWhitelisted 
returns(uint256, uint256, uint256, uint256, uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Address of minter | 
| btcAmount | uint256 | Amount in BTC to mint | 
| vendorAccount | address | Vendor address | 

### redeemBPro

⤾ overrides IMoCExchange.redeemBPro

Sender burns his BProS and redeems the equivalent BTCs

```js
function redeemBPro(address account, uint256 bproAmount, address vendorAccount) public nonpayable onlyWhitelisted 
returns(uint256, uint256, uint256, uint256, uint256)
```

**Returns**

bitcoins to transfer to the redeemer and commission spent (in BTC and MoC), using [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Address of the redeeemer | 
| bproAmount | uint256 | Amount of BPros to be redeemed | 
| vendorAccount | address | Vendor address | 

### redeemFreeDoc

⤾ overrides IMoCExchange.redeemFreeDoc

Redeems the requested amount for the account, or the max amount of free docs possible.

```js
function redeemFreeDoc(address account, uint256 docAmount, address vendorAccount) public nonpayable onlyWhitelisted 
returns(uint256, uint256, uint256, uint256, uint256)
```

**Returns**

bitcoins to transfer to the redeemer and commission spent (in BTC and MoC), using [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | Address of the redeeemer | 
| docAmount | uint256 | Amount of Docs to redeem [using mocPrecision] | 
| vendorAccount | address | Vendor address | 

### mintDoc

⤾ overrides IMoCExchange.mintDoc

Mint Max amount of Docs and give it to the msg.sender

```js
function mintDoc(address account, uint256 btcToMint, address vendorAccount) public nonpayable onlyWhitelisted 
returns(uint256, uint256, uint256, uint256, uint256)
```

**Returns**

the actual amount of btc used and the btc commission (in BTC and MoC) for them [using rbtPresicion]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address | minter user address | 
| btcToMint | uint256 | btc amount the user intents to convert to DoC [using rbtPresicion] | 
| vendorAccount | address | Vendor address | 

### redeemDocWithPrice

⤾ overrides IMoCExchange.redeemDocWithPrice

User DoCs get burned and he receives the equivalent BTCs in return

```js
function redeemDocWithPrice(address payable userAddress, uint256 amount, uint256 btcPrice) public nonpayable onlyWhitelisted 
returns(bool, uint256)
```

**Returns**

true and commission spent (in BTC and MoC) if btc send was completed, false if fails.

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| userAddress | address payable | Address of the user asking to redeem | 
| amount | uint256 | Verified amount of Docs to be redeemed [using mocPrecision] | 
| btcPrice | uint256 | bitcoin price [using mocPrecision] | 

### redeemAllDoc

⤾ overrides IMoCExchange.redeemAllDoc

Allow redeem on liquidation state, user DoCs get burned and he receives
the equivalent RBTCs according to liquidationPrice

```js
function redeemAllDoc(address origin, address payable destination) public nonpayable onlyWhitelisted 
returns(uint256)
```

**Returns**

The amount of RBTC in sent for the redemption or 0 if send does not succed

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| origin | address | address owner of the DoCs | 
| destination | address payable | address to send the RBTC | 

### mintBProx

⤾ overrides IMoCExchange.mintBProx

BUCKET Bprox minting. Mints Bprox for the specified bucket

```js
function mintBProx(address payable account, bytes32 bucket, uint256 btcToMint, address vendorAccount) public nonpayable onlyWhitelisted 
returns(uint256, uint256, uint256, uint256, uint256)
```

**Returns**

total RBTC Spent (btcToMint more interest) and commission spent (in BTC and MoC) [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address payable | owner of the new minted Bprox | 
| bucket | bytes32 | bucket name | 
| btcToMint | uint256 | rbtc amount to mint [using reservePrecision] | 
| vendorAccount | address | Vendor address | 

### redeemBProx

⤾ overrides IMoCExchange.redeemBProx

Sender burns his BProx, redeems the equivalent amount of BPros, return
the "borrowed" DOCs and recover pending interests

```js
function redeemBProx(address payable account, bytes32 bucket, uint256 bproxAmount, address vendorAccount) public nonpayable onlyWhitelisted 
returns(uint256, uint256, uint256, uint256, uint256)
```

**Returns**

the actual amount of btc to redeem and the btc commission (in BTC and MoC) for them [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address payable | user address to redeem bprox from | 
| bucket | bytes32 | Bucket where the BProxs are hold | 
| bproxAmount | uint256 | Amount of BProxs to be redeemed [using mocPrecision] | 
| vendorAccount | address | Vendor address | 

### forceRedeemBProx

⤾ overrides IMoCExchange.forceRedeemBProx

Burns user BProx and sends the equivalent amount of RBTC
to the account without caring if transaction succeeds

```js
function forceRedeemBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice) public nonpayable onlyWhitelisted 
returns(bool)
```

**Returns**

result of the RBTC sending transaction [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket where the BProxs are hold | 
| account | address payable | user address to redeem bprox from | 
| bproxAmount | uint256 | Amount of BProx to redeem [using mocPrecision] | 
| bproxPrice | uint256 | Price of one BProx in RBTC [using reservePrecision] | 

### burnBProxFor

Burns user BProx

```js
function burnBProxFor(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice) public nonpayable onlyWhitelisted 
returns(uint256)
```

**Returns**

Bitcoin total value of the redemption [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket where the BProxs are hold | 
| account | address payable | user address to redeem bprox from | 
| bproxAmount | uint256 | Amount of BProx to redeem [using mocPrecision] | 
| bproxPrice | uint256 | Price of one BProx in RBTC [using reservePrecision] | 

### redeemBProxInternal

Internal function to avoid stack too deep errors

```js
function redeemBProxInternal(address account, bytes32 bucket, uint256 bproxAmount, struct MoCExchange.RiskProxRedeemStruct details, address vendorAccount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| bucket | bytes32 |  | 
| bproxAmount | uint256 |  | 
| details | struct MoCExchange.RiskProxRedeemStruct |  | 
| vendorAccount | address |  | 

### mintBProInternal

Internal function to avoid stack too deep errors

```js
function mintBProInternal(address account, uint256 btcAmount, struct MoCExchange.RiskProMintStruct details, address vendorAccount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| btcAmount | uint256 |  | 
| details | struct MoCExchange.RiskProMintStruct |  | 
| vendorAccount | address |  | 

### mintBProxInternal

Internal function to avoid stack too deep errors

```js
function mintBProxInternal(address account, bytes32 bucket, struct MoCExchange.RiskProxMintStruct details, address vendorAccount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| bucket | bytes32 |  | 
| details | struct MoCExchange.RiskProxMintStruct |  | 
| vendorAccount | address |  | 

### mintDocInternal

Internal function to avoid stack too deep errors

```js
function mintDocInternal(address account, struct MoCExchange.StableTokenMintStruct details, address vendorAccount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| details | struct MoCExchange.StableTokenMintStruct |  | 
| vendorAccount | address |  | 

### redeemFreeDocInternal

Internal function to avoid stack too deep errors

```js
function redeemFreeDocInternal(address account, struct MoCExchange.FreeStableTokenRedeemStruct details, address vendorAccount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| details | struct MoCExchange.FreeStableTokenRedeemStruct |  | 
| vendorAccount | address |  | 

### redeemBProInternal

Internal function to avoid stack too deep errors

```js
function redeemBProInternal(address account, struct MoCExchange.RiskProRedeemStruct details, address vendorAccount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| details | struct MoCExchange.RiskProRedeemStruct |  | 
| vendorAccount | address |  | 

### redeemDocWithPriceInternal

Internal function to avoid stack too deep errors

```js
function redeemDocWithPriceInternal(address account, uint256 amount, struct MoCExchange.StableTokenRedeemStruct details, address vendorAccount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 
| details | struct MoCExchange.StableTokenRedeemStruct |  | 
| vendorAccount | address |  | 

### moveExtraFundsToBucket

Calculates the amount of RBTC that one bucket should move to another in
BProx minting/redemption. This extra makes BProx more leveraging than BPro.

```js
function moveExtraFundsToBucket(bytes32 bucketFrom, bytes32 bucketTo, uint256 totalBtc, uint256 lev) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucketFrom | bytes32 | Origin bucket from which the BTC are moving | 
| bucketTo | bytes32 | Destination bucket to which the BTC are moving | 
| totalBtc | uint256 | Amount of BTC moving between buckets [using reservePrecision] | 
| lev | uint256 | lev of the L bucket [using mocPrecision] | 

### recoverInterests

Returns RBTCs for user in concept of interests refund

```js
function recoverInterests(bytes32 bucket, uint256 rbtcToRedeem) internal nonpayable
returns(uint256)
```

**Returns**

Interests [using reservePrecision]

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| bucket | bytes32 | Bucket where the BProxs are hold | 
| rbtcToRedeem | uint256 | Total RBTC value of the redemption [using reservePrecision] | 

### doDocRedeem

```js
function doDocRedeem(address userAddress, uint256 docAmount, uint256 totalBtc) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| userAddress | address |  | 
| docAmount | uint256 |  | 
| totalBtc | uint256 |  | 

### initializeContracts

```js
function initializeContracts() internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

