---
id: version-0.1.12-OwnerBurnableToken
title: OwnerBurnableToken
original_id: OwnerBurnableToken
---

# Owner Burnable Token (OwnerBurnableToken.sol)

View Source: [contracts/token/OwnerBurnableToken.sol](../../contracts/token/OwnerBurnableToken.sol)

**↗ Extends: [Ownable](Ownable.md), [ERC20Mintable](ERC20Mintable.md)**
**↘ Derived Contracts: [BProToken](BProToken.md), [DocToken](DocToken.md), [MoCToken](MoCToken.md)**

**OwnerBurnableToken** - version: 0.1.12

Token that allows the owner to irreversibly burned (destroyed) any token.

## Functions

- [burn(address who, uint256 value)](#burn)

### burn

Burns a specific amount of tokens for the address.

```js
function burn(address who, uint256 value) public nonpayable onlyOwner 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| who | address | who's tokens are gona be burned | 
| value | uint256 | The amount of token to be burned. | 

