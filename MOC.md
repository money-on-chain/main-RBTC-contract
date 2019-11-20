# Money on Chain

1. [Introduction](#introduction)
1. [Main Concepts](#main-concepts)
   1. [Bucket](#bucket)
   1. [Coverage](#coverage)
   1. [Tokens](#tokens)
   1. [Leveraged Instruments](#leveraged-instruments)
1. [System states](#system-states)
1. [Architecture](#architecture)
1. [Public actions](#public-actions)
   1. [User actions](#user-actions)
      1. [Minting](#minting)
      1. [Redeeming](#redeeming)
   1. [Process actions](#processes-actions)
      1. [Interest payments](#interest-payments)
      1. [Settlement](#settlement)
      1. [Liquidation](#liquidation)
1. [Contracts](#contracts)
   1. [MoC](#moc)
   1. [MoCState](#mocstate)
   1. [MoCBucketContainer](#mocbucketcontainer)
   1. [MoCSettlement](#mocsettlement)
   1. [MoCBurnout](#mocburnout)
   1. [MoCHelperLib](#mochelperlib)
   1. [MoCLibConnection](#moclibconnection)
   1. [MoCConverter](#mocconverter)
   1. [MoCExchange](#mocexchang)
   1. [MoCConnector](#mocconnector)
   1. [MoCBProxManager](#mocbproxmanager)
   1. [MoCInrate](#mocinrate)
   1. [MoCWhitelist](#mocwhitelist)
   1. [MoCBase](#mocbase)
   1. [OwnerBurnableToken](#ownerburnabletoken)
   1. [BProToken](#bprotoken)
   1. [DocToken](#doctoken)
   1. [BtcPriceProvider](#btcpriceprovider)
1. [Contracts Mocks](#contracts-mocks)
1. [Relevant patterns and choices](#relevant-patterns-and-choices)
   1. [Safe Math and precision](#safe-math-and-precision)
   1. [Inheritance, Composition and Contract whitelisting](#inheritance-composition-and-contract-whitelisting)
   1. [Governance and Upgradability](#governance-and-upgradability)
   1. [Block gas limit prevention](#block-gas-limit-prevention)
1. [Data Dictionary](#data-dictionary)
1. [Getting started](#getting-started)

# Introduction

Money On Chain is a suite of smart contracts dedicated to providing a bitcoin-collateralized stable-coin, Dollar On Chain, (DoC); a passive income hodler-targeted token, BitPro (BPRO), and a leveraged Bitcoin investment instrument (BTCX series).
The rationale behind this is that deposits of Rootstock-BTC (RBTC) help collateralize the DoCs, BitPro absorbs the USD-BTC rate fluctuations, and BTC2X is leveraged borrowing value from BitPro and DoC holders, with a daily interest rate being paid to the former.

# Main Concepts

## Bucket

A bucket (MoCBucket struct) is a Tokens/RBTC grouping abstraction that represents certain state and follows certain rules.
It's identified by a name (currently `C0` and `X2`).
It has a "balance" of RBTC, DoC, and BitPro.
If it's a leverage (X) bucket, it also stores the balances of the leveraged token (currently only BTC2X) holders (`bproxBalances` and `activeBalances`).
If it's instead a base bucket, it has a RBTC balance (`inrateBag`) from interests accumulated by leveraged instruments allocations, daily processing will move the corresponding daily payment from this "bag" to base bucket balance.
Balance accounting between buckets is articulated by a series of Smart Contracts that constitute the MOC ecosystem.

## Coverage

Is the ratio between the RBTC locked (backing DoCs) and the total amount of RBTC, be it in a particular bucket or the whole system (usually referred as global).
Locked RBTC amount is a result of the amount of DoCs and their price in BTC (BTC/USD rate).

## Tokens

### DoC

Its value is pegged to one dollar, in the sense that the SC (using [Oracle's](#Oracle) btc/usd price) will always[^1] return the equivalent amount of Bitcoin to satisfy that convertibility.
It's targeted towards users seeking to avoid crypto's market volatility.
It's implemented as an ERC20 token, it can be traded freely, but minted/burned only by the Moc system.
The more DocS minted, the more BTC2X can be minted, since they are used for leverage.

[^1]: Needs sufficient collateral (coverage > 1) and redeems are only processed during [Settlements](#Settlement)

### BitPro

It's targeted towards users seeking to _hodl_ Bitcoins and also receive a passive income from it.
It's implemented as an ERC20 token, it can be traded freely, but minted/burned only by the Moc system.
The more BitPros minted (introducing RBTC to the system), the more coverage the system has, since they add value to the system without locking any.

## Leveraged instruments

### BTC2X

It's targeted towards users looking to profit from long positions in bitcoin, with two times the risk and reward.
Leveraged instruments borrows capital from base bucket (50% in a X2) and pay a daily[^1] rate to it as return.
It can _not_ be traded freely and does _not_ have an ERC20 interface. BTCX positions can be canceled any time though.

[^1]: Actually uses X amount of block that, given the network, will approximate daily intervals.

## Oracle

It's crucial to the system workflow to have an up to date BTC-USD rate price feed to relay on. This is currently achieved by a separate contract so that it can be easily replaced in the future without affecting the MOC system. See [BtcPriceProvider](#BtcPriceProvider).

# System states

System state is ruled by the global [Coverage](#Coverage) value, and it's relation with the Objective Coverage (Cobj), currently set to 4.

- Above coverage

  Healthy state of the system. Every Token can be minted, and every Token (besides non-free DoCs) can be redeemed.

- Below coverage

  When the coverage falls below a certain threshold (Cobj), BitPros can no longer be redeemed as a measure to keep the coverage as high as possible.
  Additionally, DoCs can't be minted.

- Discount sale of BitPro

  When the coverage falls below the next threshold (uTPDU, currently 1.6), BitPros are sold at a discounted price with the intention of pumping more bitcoins into the system.

- Liquidated

  If the former measures fail and the coverage falls below last threshold ( currently 1.04), the contracts are locked allowing _only_ the redemption of remaining DoCs at the last available price.
  Although DoC Tokens can still be transferred freely, BitPro Token on the other hand is permanently paused, as it has lost all of its value.
  This state is irreversible, once the liquidation state is achieved on the contract, there is no coming back even if the price and/or coverage recovers.

# Public Actions

We distinguish three types of public interactions with the SC:

- _View actions_: methods to query system state variables
- _User actions_: methods oriented to MoC's wider user base, allowing them to interact with Tokens and Investment instruments.
- _Process actions_: methods that allow the system to evolve under time and/or btc price rules
  All actions are performed directly to the `MoC` contract, although it usually channels the request to a more specif contract, working as a unified Proxy entry point.

## User actions

### Minting

Token emission (minting/burning) is only allowed to be done through MOC system, users cannot create or destroy tokens directly on the ERC20 contracts.

#### BitPro

Can only be minted in exchange for RBTC.
Given an amount of RBTC paid to the contract, the system calculates the corresponding BitPro amount to mint, RBTC and Bitpro balances are added to the base bucket and the new Tokens are sent to the user.
There's a discount sale, below a certain level of coverage (uTPDU, currently 1.6).
This increases coverage, and allows to mint `(sent_btc/target_coverage)*btc_price` extra DoCs, assuming the system is in the 'above coverage' state.

#### DoC

Can only be minted in exchange for RBTC.
Given an amount of RBTC paid to the contract, the system calculates the corresponding DoCs amount to mint [^1], RBTC and DoC balances are added to the base bucket and the new Tokens are sent to the user.

[^1]: The contract must be in the 'Above coverage' state, but given the minting itself lowers coverage, the amount of DoCs to be minted is limited by the preservation of this state. (See `globalMaxDoc`)

#### BTC2X

Can only be "minted" in exchange of RBTC.
The process for the minting is as follows:

- An amount of RBTC is paid to the contract
- The interest to be paid is pre-determined based on: "days until next settlement", "DoCs abundance" and the amount sent.
- The interest computed in the previous item is subtracted from the sent amount, and transferred into the "interest bag" of the base bucket.
- DoCs are transferred from the base bucket into the leverage bucket, in the same "volume" as the amount remaining from what was sent.
- BTC2X are assigned to the user. (This is not a Token transfer as leveraged instruments cannot change owner)

The interests are discounted from the sent BTC, that is, if a user sends `X` BTC, they'll be assigned `X - interests` BTC2X equivalent.

### Redeeming

#### BitPro

A user can "sell" their BitPro back to the contract and recover the corresponding amount of RBTC.
The contract must be in the 'Above coverage' state.
The BitPros and RBTC are simply discounted from the base bucket.

#### DoC

##### On settlement

A DoC redeem request can be created to redeem any amount of DoCs, but this will be processed on next settlement.
The intended amount can be greater than user's balance at request time, allowing to, for example, redeem all future user's DoCs regardless of whether their balance increases.
The redemption of DoCs at the settlement is explained in detail in [its own section](#Process-DoC-redeem-requests)

##### Outside of settlement

Only free DoCs can be redeemed outside of the settlement.
Free DoCs are those that remain in the base bucket, that is, they were not transferred to another to provide leverage.
Tokens and their equivalent in RBTC are simply subtracted from the base bucket.

#### BTC2X

RBTC deposited are sent back to the user, alongside the refunded interests (waiting in inrateBag) for the remaining time until the settlement (not yet charged).
Associated DoCs are moved back to the base bucket.

## Process Actions

### Interest-payments

Leveraged positions are charged by an interest as return for the borrowed value.
On each investment, the total interest to be paid is calculated and pre-allocated in an common interest "bag" (inrateBag) for all payments.
Once a day[^1] the smart contract allows a transaction to move certain amount of RBTC from that bag, to the base bucket itself.
Once executed for the current block span, it gets blocked "waiting" for blocks to be mined until the conditions are meet again.

[^1]: based on a given number of blocks dependent on the network's mining rate.

### Settlement

Similar to daily payments, settlements are a time based recurrent process which relies on block number to allow/reject execution. This is currently intended to execute on 90 day intervals, although it can be adjusted on deploy.
During settlement, two important events take place: deleveraging of leveraged positions, and Doc redeem request processing.

As this process involves array loops, it might require more than on call to complete. That's why it is wrapped on a TASK and the step amount parameter indicates the maximum number of iterations to be performed on each call. Take in account that during the execution (in between calls) some other functions won't be available to execute.

#### Deleveraging

Although the name deleveraging evokes a broader process, in this case it just refers to the "settlement" of all individual leveraged position. At this time, all interests should had been payed (as they depends inversely to days to settlement), so it's a matter of converting the remaining open positions to RBTC and give back the corresponding DoCs borrowed. Under the hood, it simply invokes redeem for each user account. Market will determine whether they had lost or earned money.

#### DoC redeem requests

As explained in the [redeem section](#####On-settlement), docs are not entirely liquid but need to be programmed to be redeemed (burn DoC and retrieve RBTC). Users enter a list (currently called queue in anticipation of future pagination) waiting to be executed during settlement.
This events simply goes through the aforementioned collection burning the corresponding DoC amount[^1], sending the equivalent RBTC (at the current BTC-USD rate) and obviously updating the bucket balances in the process.
Said collection should be empty at the end of the process.

[^1]: Note that the intended amount it's not validated until processing, so obviously that amount would only be fulfilled if the user actually owns that amount of DoCs. If he has less, all of them will be redeemed.

### System Liquidation

If the BTC/USD price drops drastically, an none of the incentive mechanisms along the coverage dropping prevents it to cross the liquidation threshold (currently: coverage < 1.04) the system will enter the liquidation state and the liquidation function will be available to be executed.
Although there is an specific method to evaluate liquidation (`evalLiquidation`), to guarantee this process is executed, the same logic is evaluated and, if needed, executed in every MoC state changing method. For example, mintDoC, redeemBPro, etc or even settlement itself; every that has the `transitionState` modifier actually.
Liquidation process will invalidate the BitPro Token (it cannot be transfer any more) as a precaution measure as it has no more RBTC backing it, it has no value.
It will go thru the [burnout address](#Burnout-address) collection and transfer the corresponding RBTC amount to each one accordingly to theirs DoC balances.

As this process involves array loops, it might require more than on call to complete. That's why it is wrapped on a TASK and the step amount parameter indicates the maximum number of iterations to be performed on each call.

### Bucket Liquidation

Leveraged buckets will get to critical coverage values quicker than the system as a whole, so they will potentially cross liquidation threshold (currently `liq = 1.04`) sooner.
Bucket liquidation process is verified on every bucket State Transition (`bucketStateTransition` modifier), that being mint/redeem of leveraged (X) instruments. And there is also a public function to evaluate (and trigger if needed): `evalBucketLiquidation`.
For a leveraged bucket, reaching coverage liquidation point (~1) means that user's funds had absorbed all the price dropping, so this process just needs to return the borrowed value (to base bucket) and dissolve the position.

# Contracts architecture

MoC system is a network of cooperative contracts working together to ultimately provide an US dollar pegged ERC20 Token (DoC). In this sense, be can categorize then into 4 categories:

- _MoC state Contracts_: They keep MoC state variables and logic (MoC, MoCState, MoCBucketContainer, MoCSettlement, MoCBurnout)
- _MoC pure logic Contracts & Libraries_: Functional extensions of the above merely to have responsibility separation and contracts size (aka deploy fee) low. (MoCHelperLib, MoCLibConnection, MoCConverter, MoCExchange, MoCConnector, MoCBProxManager, MoCInrate, MoCWhitelist, MoCBase)
- _Tokens_: Tokens backed by the system (OwnerBurnableToken, DocToken, BProToken)
- _External Dependencies_: External contracts the system relies on, in this case the Oracle or price provider; this could evolved independently of MoC system as along as the interface is maintained. (BtcPriceProvider)

## MoC

- Referenced by: MoCBurnout, MoCSettlement
- References/uses: SafeMath, MoCLibConnection, DocToken, BProToken, BtcPriceProvider, MoCBProxManager, MoCState, MoCConverter, MoCSettlement, MoCExchange, MoCBurnout, base/MoCBase
- Inherits from: MoCEvents, MoCLibConnection, MoCBase, Stoppable

  MoC is the main contract of the MoC ecosystem, it's the entry point of almost every public interaction with it and it articulates the main logic and relations between the rest of the contracts.
  It is also the _only one_ that receives RBTC and holds the actual value of the system. The only methods marked as `payable` belongs to this contract and corresponds with the actual two ways of adding "value" to the system minting BitPro and DoC: - `function mintBPro() public payable transitionState() { ... }` - `function mintDoc() public payable transitionState() atLeastState(MoCState.States.AboveCobj) { ... }`
  You'll also notice that many of it's methods just "redirects" to a more specif contract, abstracting it from the `msg.sender` and `msg.value`; for example:

```sol
  /**
  * @dev Creates or updates the amount of a Doc redeem Request from the msg.sender
  * @param docAmount Amount of Docs to redeem on settlement [using dollarPrecision]
  */
  function redeemDocRequest(uint256 docAmount) public {
    settlement.addRedeemRequest(docAmount, msg.sender);
  }
```

MoC also handles the [System states][#system-states] by a series of modifiers:

- _atState_: requires certain state to allow execution

```
  modifier atState(MoCState.States _state) {
    require(mocState.state() == _state, "Function cannot be called at this state.");
    _;
  }
```

- _atLeastState_: as states have a progressive order, we can require certain state or higher (where higher indicates a healthier system state)

```
  modifier atLeastState(MoCState.States _state) {
    require(mocState.state() >= _state, "Function cannot be called at this state.");
    _;
  }
```

- _bucketStateTransition_: Any method that can potentially modify a bucket values is require to first verify if current conditions doesn't demand that bucket liquidation. This is currently used while minting/redeeming Leveraged instruments (BProX).

```
  modifier bucketStateTransition(string bucket) {
    evalBucketLiquidation(bucket);
    _;
  }
```

- _transitionState_: As liquidation (as a way to maintain the USD PEG) is a fundamental commitment of the system, we want to ensure that no operation could ever be done without triggering it if the conditions are met. This is why every method that may change the system inner state, is annotated with this modifier.

```
  modifier transitionState()
  {
    mocState.nextState();
    if (mocState.state() == MoCState.States.Liquidated)
      liquidation();
    else
      _;
  }
```

## MoCState

- Referenced by: MoC, MoCConverter, MoCExchange, MoCInrate, MoCSettlement
- References/uses: Math, MoCBProxManager, BtcPriceProvider, DocToken, BProToken, MoCSettlement
- Inherits from: MoCLibConnection, MoCBase
  This contract holds the system variables to manage the state, wether it's the state itself or the thresholds configurations; as well as many `view` functions to access and evaluate it.
- State:
  - System State itself:
    `States public state = States.AboveCobj;`
  - Global number of RBTC: Complete amount of Bitcoin in the system
    `uint256 public globalNB = 0;`
  - Configuration variables:
    - PEG: Relation between DOC and dollar
      `uint256 public peg = 1;`
    - BPro max discount rate: Reflects the discount spot rate at Liquidation level
      `uint256 public bproMaxDiscountRate;`
    - Liquidation threshold:
      `uint256 public liq;`
    - BPro with discount threshold:
      `uint256 public utpdu;`

It also defines the State enum options:

```sol
  enum States {
    // State 0
    Liquidated,
    // State 1
    BProDiscount,
    // State 2
    BelowCobj,
    // State 3
    AboveCobj
  }
```

## MoCBucketContainer

- Referenced by: MocBproxManager
- References/uses: SafeMath, Math
- Inherits from: MocBase
  Defines the structure of a bucket and implements various utility methods related to said structure.
- State:
  - MoC Buckets: Mapping of named buckets. Despite currently having just two (`C0` & `X2`), this is expected to grow in the future and even be dynamically modified.
    `mapping(string => MoCBucket) internal mocBuckets;`

## MoCSettlement

- Referenced by: MoC, MoCState
- References/uses: Math, SafeMath,MoCBase, DocToken, MoCState, MoCExchange, MoCBProxManager, MoC
- Inherits from: MoCBase
  This contract handles settlement logic and stores redeem request collection. It uses both `lastProcessedBlock` and `blockSpan` to periodically allow one execution.

- State:
  - Last Processed Block: Block Number of the last successful execution
    `uint256 internal lastProcessedBlock;`
  - Block Span: Set by configuration, min number of blocks settlement should be re-evaluated on, this should be adjusted according network mining rate to hit the target time (90 days)
    `uint256 internal blockSpan;`
  - Redeem request collection: tracks accounts with active redeem request for next settlement
    ```
      struct RedeemRequest {
        address who;
        uint256 amount;
      }
      RedeemRequest[] private redeemQueue;
      uint256 private numElements = 0;
    ```

## MoCBurnout

- Referenced by: MoC
- References/uses: DocToken, MoC, MoCExchange, DocToken
- Inherits from: MoCBase, MoCBurnoutEvents
  Tracks the Burnout addresses that will be redeemed to in case of a liquidation.
  When liquidation happens all Docs of the holders in the queue will be sent to the corresponding burnout address.
  Those aforementioned holders have to manually set their burnout address.
- State:
  This contracts uses tree variables to keep track of burn out address. A mapping relating the userAddress (sender) with the burnoutAddress called `burnoutBook`, an array (`burnoutQueue`) that keep tracks of userAddresses that had manifest intent of having this exit (aka had provide a burnout address) and the number of element of that array (`numElements`). Note that this is kept as a separate variable (instead of using `burnoutQueue.length`) to have flexibility on where we want or not, to shrink the array if needed.
  Also note that even if the array seems redundant, it's needed to iterate [^1] on liquidation, which in not possible with a mapping.

  - `mapping(address => address) burnoutBook;`
  - `address[] private burnoutQueue;`
  - `uint256 private numElements = 0;`

  [^1]: See [# Well known issue and planned improvements](#Well-known-issue-and-planned-improvements) for detail on vulnerabilities for array iterations.

## MoCHelperLib

- Referenced by: MoCLibConnection
- References/uses: SafeMath
  Implements several utility methods related to leverage, coverage and maximum emission of tokens, amongst others.
  It's modeled as a library to enforce it's stateless an operative nature. It's intended to group all the formulas of the model in a pure functional way.

## MoCLibConnection

- Referenced by: MocExchangeEvents, MoCLibConnection, MoCExchange, MoCInrate, MoCConverter, MoCState, MoC
- References/uses: MoCHelperLib
  It's a common way of "injecting" MoCHelperLib into the contracts that will need it, along with some useful precision methods. Contracts the needs this library, will inherit from MoCLibConnection.

## MoCConverter

- Referenced by: MoC, MoCConnector, MoCExchange, MoCInrate
- References/uses: MoCState
- Inherits from: MoCBase, MoCLibConnection
  Nucleates all conversion function to go from a given token/currency amount to another.

## MoCExchange

- Referenced by: MoCBurnout, MoC, MoCSettlement
- References/uses: DoCToken, BproToken, MocInrate
- Inherits from: MocExchangeEvents, MocBase, MoCLibConnection
  Handles minting and redemption of all tokens and instruments. Has no state.

## MoCConnector

- Referenced by: MoCBase, MoCConnector
- References/uses: MoCWhitelist, Ownable
- Inherits from: Ownable, MoCWhitelist
  Tracks an provides the addresses of all the other contracts in the system.

## MoCBProxManager

- Referenced by: MoCExchange, MoCInrate, MoCState, MoC, MoCSettlement
- References/uses: MocBase, SafeMath
- Inherits from: MoCBucketContainer
  Handles BTCXX (formerly BProX) balances.

## MoCInrate

- Referenced by: MoCExchange, MoC
- References/uses: MoCLibConnection, MoCState, MoCBProxManager, MoCConverter, MoCBase
- Inherits from: MoCInrateEvents, MoCBase, MoCLibConnection
  Deals with the interest payments from leverage buckets to base buckets.

## MoCWhitelist

- Referenced by: MoCConnector
- References/uses: Ownable
- Inherits from: Ownable
  Handles contract whitelisting, a list of allowed contracts to call on each other.
  Due to the big code size, it was necessary to separate the logic into many contracts, and those contracts had to trigger changes in each other that naturally should belonged to internal functions. To solve this, we make this functions public but only accepting calls from certain addresses (whitelisted), which are configured to the necessary contracts while deploy and initialize.

## MoCBase

- Referenced by: MoCBucketContainer, MoCExchange, MoCBase, MoCBurnout, MoCBProxManager, MoCInrate, MoCConverter, MoCState, MoC, MoCSettlement
- References/uses: MoCConnector
- Inherits from:
  Helps with whitelisting, providing needed modifiers to only allow specific addresses.

## OwnerBurnableToken

- Referenced by: DocToken, BProToken
- References/uses:
- Inherits from: OpenZeppelin/Ownable, OpenZeppelin/ERC20Mintable
  As burning tokens is a faculty that only MoC system have, this contracts overrides the "default" ERC20 behavior for witch the user owning the tokens is the one that can destroy them.

## DocToken

- Referenced by: MoC, MoCBurnout, MoCExchange, MoCSettlement, MoCState
- References/uses:
- Inherits from: OpenZeppelin/ERC20Mintable, OpenZeppelin/ERC20Detailed, OwnerBurnableToken
  Dollar On Chain token
- Name: Dollar on Chain
- Symbol: DOC
- Decimals: 18

## BProToken

- Referenced by: MoC, MoCExchange, MoCState
- References/uses:
- Inherits from: ERC20Mintable, ERC20Detailed, ERC20Pausable, OwnerBurnableToken
- Name: BITPRO
- Symbol: BITPRO
- Decimals: 18

## BtcPriceProvider

- Referenced by: MocState, MoC
- References/uses: SafeMath
  Provides the price of bitcoin in US dollars.
  Currently it's a mock of the future functionality, since the price can be set by anyone and there isn't any consensus mechanism.
  It's assumed that in a future production release there will be a reliable, decentralized price providing oracle.
  It's used by MocState to get the bitcoin price and moving average.

# Contract Mocks

Mocks are for testing purposes, inheriting from MoC contracts and overriding of certain methods allows to expose or manipulates data that wouldn't be possible to unit test instead.

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
    mocLibConfig.dollarPrecision = 10 ** 18;
    mocLibConfig.reservePrecision = 10 ** 18;
    mocLibConfig.coveragePrecision = 10 ** 18;
    mocLibConfig.ratePrecision = 10 ** 18;
    mocLibConfig.dayPrecision = 1;
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
- On Liquidation, while processing DoC burnout addresses.

That's why this functions are wrapped on TASKs and might requires more than one call to complete. They receive a step amount parameter indicating the maximum number of iterations to be performed on each call.

_Note_: Some model simulations had shown ~100 items is close to RSK block gas limit.

## Governance and Upgradability

MoC contracts subscribes to a governance implementation that allows an external contract to authorize changers to:

- Set single parameters values (for example, adjusting commission fee)

- Upgrade specific contracts to new versions (for example updating some formula to make it more efficient)

- Pause/Un-pause the whole system (intended as temporal halts for future upgrades)

For further detail on Governance mechanism refer to [Moc Governance project](https://gitlab.com/atixlabs/moc---gobernanza)

# Data Dictionary

- _uTPDU_: Universal TPro discount sales coverage threshold, from spanish "Umbral de venta de TPROg con descuento universal"
- _EMA_: Exponential Moving Average, technique to aproximate the moving average based on a previous value and and smoothing factor.
- _Oracle_: Smart Contract dedicated to provide off-chain data that change over time, for example a price for a given source.

# getting started

## Install dependencies

- Use nodejs v8.12: `nvm install 8.12 && nvm alias default 8.12`
- Install local dependencies: `npm install`

## Run Ganache-cli

- Globally:

```sh
npm install -g ganache-cli;
ganache-cli
```

- Using Docker:

```sh
docker pull trufflesuite/ganache-cli;
docker run -d -p 8545:8545 trufflesuite/ganache-cli:latest
```

## Run Rsk Local Node

- With Docker:
  See this repo: https://github.com/rsksmart/artifacts/tree/master/Dockerfiles/RSK-Node

## Run Tests

- run: `npm test`

### With Coverage

- `npm run coverage`
- browse: [./coverage/index.html](./coverage/index.html)

## Deploy

(Truffle suit)[https://github.com/trufflesuite/truffle] is recommended to compile and deploy the contracts. There are a set of scripts to easy this process for the different known environments. Each environment (and network) might defer in its configuration settings, you can adjust this values in the the `migrations/config/config.json` file.

At the end of the deployment the addresses of the most relevant contracts will be displayed. If you are interested in another contracts you should look inside some files depending if the contracts is upgradeable or not.

The addresses of the deployed proxies will be in a file called `zos.<network-id>.json` . There you will have to look inside the proxies object and look for the `address` of the proxy you are interested in. If you are interested in the address of a contract that has not a proxy you should look for it in the prints of the deployment or inside the `builds/<contract-name>.json` file.

## Settings

- _initialPrice_: Bitcoin initial (current) price
- _initialEma_: Bitcoin initial EMA (exponential moving average) price
- _dayBlockSpan_: Average amount of blocks expected to be mined in a calendar day in this network.
- _settlementDays_: Amount of days in between settlement to allowed executions
- _gas_: Gas to use on MoC.sol contract deploy.
- _oracle_: Moc Price Provider compatible address (see `contracts/interface/BtcPriceProvider.sol`). You can deploy this contract using the `oracle` project or (in development) the mock:`contracts/mocks/BtcPriceProviderMock.sol` (which is deployed on development migration by default).
- _startStoppable_: If set to true, the MoC contract can be stopped after the deployment. If set to false, before pausing the contract you should make it stoppable with governance(this together with the blockage of the governance system can result in a blockage of the pausing system too).
