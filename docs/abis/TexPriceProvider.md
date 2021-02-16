---
id: version-0.1.10-TexPriceProvider
title: TexPriceProvider
original_id: TexPriceProvider
---

# TexPriceProvider.sol

View Source: [contracts/interface/TexPriceProvider.sol](../contracts/interface/TexPriceProvider.sol)

**↘ Derived Contracts: [MoCPriceProviderMock](MoCPriceProviderMock.md)**

**TexPriceProvider** - version: 0.1.10

## Functions

- [getLastClosingPrice(address _baseToken, address _secondaryToken)](#getlastclosingprice)

### getLastClosingPrice

⤿ Overridden Implementation(s): [MoCPriceProviderMock.getLastClosingPrice](MoCPriceProviderMock.md#getlastclosingprice)

Getter for every value related to a pair

```js
function getLastClosingPrice(address _baseToken, address _secondaryToken) external view
returns(lastClosingPrice uint256)
```

**Returns**

lastClosingPrice - the last price from a successful matching

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _baseToken | address | Address of the base token of the pair | 
| _secondaryToken | address | Address of the secondary token of the pair | 

