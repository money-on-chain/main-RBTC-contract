---
id: version-0.1.12-Initializable
title: Initializable
original_id: Initializable
---

# Initializable
 * (Initializable.sol)

View Source: [zos-lib/contracts/Initializable.sol](../../zos-lib/contracts/Initializable.sol)

**↘ Derived Contracts: [Governed](Governed.md), [MoCBase](MoCBase.md), [MoCConnector](MoCConnector.md), [MoCHelperLibHarness](MoCHelperLibHarness.md), [ReentrancyGuard](ReentrancyGuard.md)**

**Initializable** - version: 0.1.12

Helper contract to support initializer functions. To use it, replace
the constructor with a function that has the `initializer` modifier.
WARNING: Unlike constructors, initializer functions must be manually
invoked. This applies both to deploying an Initializable contract, as well
as extending an Initializable contract via inheritance.
WARNING: When used with inheritance, manual care must be taken to not invoke
a parent initializer twice, or ensure that all initializers are idempotent,
because this is not dealt with automatically as with constructors.

## Contract Members
**Constants & Variables**

```js
bool private initialized;
```
---

```js
bool private initializing;
```
---

```js
uint256[50] private ______gap;
```
---

## Modifiers

- [initializer](#initializer)

### initializer

Modifier to use in the initializer function of a contract.

```js
modifier initializer() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [isConstructor()](#isconstructor)

### isConstructor

Returns true if and only if the function is running in the constructor

```js
function isConstructor() private view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

