---
id: version-0.1.10-MoCConnector
title: MoCConnector
original_id: MoCConnector
---

# MoCConnector.sol

View Source: [contracts/base/MoCConnector.sol](../../contracts/base/MoCConnector.sol)

**↗ Extends: [MoCWhitelist](MoCWhitelist.md), [Initializable](Initializable.md)**

**MoCConnector** - version: 0.1.10

Provides access control between all MoC Contracts

## Contract Members
**Constants & Variables**

```js
//public members
address payable public moc;
address public docToken;
address public bproToken;
address public bproxManager;
address public mocState;
address public mocConverter;
address public mocSettlement;
address public mocExchange;
address public mocInrate;
address public mocBurnout;

//internal members
bool internal initialized;

//private members
uint256[50] private upgradeGap;

```

## Functions

- [initialize(address payable mocAddress, address docAddress, address bproAddress, address bproxAddress, address stateAddress, address settlementAddress, address converterAddress, address exchangeAddress, address inrateAddress, address burnoutBookAddress)](#initialize)

### initialize

Initializes the contract

```js
function initialize(address payable mocAddress, address docAddress, address bproAddress, address bproxAddress, address stateAddress, address settlementAddress, address converterAddress, address exchangeAddress, address inrateAddress, address burnoutBookAddress) public nonpayable initializer 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| mocAddress | address payable | MoC contract address | 
| docAddress | address | DoCToken contract address | 
| bproAddress | address | BProToken contract address | 
| bproxAddress | address | BProxManager contract address | 
| stateAddress | address | MoCState contract address | 
| settlementAddress | address | MoCSettlement contract address | 
| converterAddress | address | MoCConverter contract address | 
| exchangeAddress | address | MoCExchange contract address | 
| inrateAddress | address | MoCInrate contract address | 
| burnoutBookAddress | address | (DEPRECATED) MoCBurnout contract address. DO NOT USE. | 

