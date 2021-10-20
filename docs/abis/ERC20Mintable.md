---
id: version-0.1.12-ERC20Mintable
title: ERC20Mintable
original_id: ERC20Mintable
---

# ERC20Mintable.sol

View Source: [openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol](../../openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol)

**↗ Extends: [ERC20](ERC20.md), [MinterRole](MinterRole.md)**
**↘ Derived Contracts: [OwnerBurnableToken](OwnerBurnableToken.md)**

**ERC20Mintable** - version: 0.1.12

Extension of `ERC20` that adds a set of accounts with the `MinterRole`,
which have permission to mint (create) new tokens as they see fit.
 * At construction, the deployer of the contract is the only minter.

## Functions

- [mint(address account, uint256 amount)](#mint)

### mint

See `ERC20._mint`.
     * Requirements:
     * - the caller must have the `MinterRole`.

```js
function mint(address account, uint256 amount) public nonpayable onlyMinter 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 
| amount | uint256 |  | 

