# Relevant patterns and choices

## Safe Math and precision

MoC system requires many mathematical operations, in this model just the 2 basic operations are used (addition/subtraction, multiplication/division). To protect against overflows, OpenZeppelin SaveMath library is used on any of this operations.
As current RSK EVM version does not "support" decimal values, it's also important to point out that in MoC every value that is mathematically a decimal, it's represented as an integer adjusted by a given value, which is called _precision_.

For example, let's take coverage formula:
`cob = nB / lB`
and suppose that on a given time `nB=35` and `lB=10`, then
`cob = 35 / 10 = 3.5`
if we look at the MoCHelperLib coverage method:

```
/**
  Coverage = nB / LB

  @dev Calculates Coverage
  @param nB Total BTC amount [using reservePrecision]
  @param lB Locked bitcoins amount [using reservePrecision]
  @return Coverage [using coveragePrecision]
**/
function coverage(MocLibConfig storage libConfig, uint256 nB, uint256 lB) public view
  returns(uint256) {
  if (lB == 0) {
    return UINT256_MAX;
  }

  return nB.mul(libConfig.coveragePrecision).div(lB);
}
```

We notice that:

- nB and lB param are expected to be received with `reservePrecision`
- coverage return value is supposed to be return with `coveragePrecision`
- the actual formula _first_ multiplies `nB` with the return coverage `nB.mul(libConfig.coveragePrecision)` and _then_ dives by `lB`. The order is not trivial, as even if mathematically there is no difference, making the division first would result in precision lost.

In our example, supposing `coveragePrecision = 1*10^18`

`cob = nB.mul(1*10^18).div(lB) = 35*10^17`

If we invert the operation order:

`cob = nB.div(lB).mul(1*10^18) = 3*10^18` ===> loosing precision !!!

There are many different precision values, depending on the value "denomination" being used, all of them are statically defined on the Library:

```
contract MoCHelperLibMock {
  ...
  constructor() public {
    mocLibConfig = MoCHelperLib.MocLibConfig({
      reservePrecision: 10 ** 18,
      mocPrecision: 10 ** 18,
      dayPrecision: 1
    });
  }
```

Even if many are equal, we keep them on separate variables to be able to adjust them accordantly on future formula changes.
Using unsigned int256 as the norm for all values, sets an upper limit to ~76 decimal places, so even if it's ok to multiply 18 precision values a couple of times, we need to be careful not to overflow nor lose precision.
Most of MoC methods signatures specify the expected precision of the given input and return values, as well of internal operation precision cancelling, for example:

```
  // [DISCOUNT] * [COV] / [COV] = [DISCOUNT]
  return bproLiqDiscountRate.mul(utpduCovDiff).div(utpduLiqDiff);
```

where the convention is to indicate the short description of the precision on brackets ([COV] = coveragePrecision).

## Inheritance, Composition and Contract whitelisting

In general programming, Composition is preferred upon Inherence, but solidity presents new consideration to keep in mind when choosing each pattern. As composition means a new Contract, and that means intra-contracts calls, meaning public methods and confusing `msg.sender` scopes; one might be turn into diminish this and prioritize inherence. The problem then arises when contract code grows and deploy fees goes beyond block gas limit.
Managing this equilibrium was not easy, and we think we are far from having the ultimate clearer and efficient solution yet, but using the whitelisted contract address network pattern, gave us an easy and scalable way on which to relay for contract inter-dependencies.
We understand that this solution makes the system vulnerable on deploy stage, as there is a post deploy initilization phase that needs to be atomically completed in other to have the whole system ready, a hook in this process might be able to compromise it. A post deploy integrity check script might a good option to solve this in the future.

## Block gas limit prevention

Although not recomended, dynamic array looping is needed to be performed on certain functions:

- On Settlement, while processing _DoCRedeemRequest_ or _BProX_ collection.

That's why this functions are wrapped on TASKs and might requires more than one call to complete. They receive a step amount parameter indicating the maximum number of iterations to be performed on each call.

_Note_: Some model simulations had shown ~100 items is close to RSK block gas limit.

## Governance and Upgradability

MoC contracts subscribes to a governance implementation that allows an external contract to authorize changers to:

- Set single parameters values (for example, adjusting commission fee)

- Upgrade specific contracts to new versions (for example updating some formula to make it more efficient)

- Pause/Un-pause the whole system (intended as temporal halts for future upgrades)

For further detail on Governance mechanism refer to [Moc Governance project](https://github.com/money-on-chain/Areopagus-Governance)
