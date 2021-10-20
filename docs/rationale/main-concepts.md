# Main Concepts

## Bucket

A bucket (MoCBucket struct) is a Tokens/RBTC grouping abstraction that represents certain state and follows certain rules.
It's identified by a name (currently `C0` and `X2`).
It has a "balance" of RBTC, DoC, and BitPro.
If it's a leverage (X) bucket, it also stores the balances of the leveraged token (currently only BTCx) holders (`bproxBalances` and `activeBalances`).
If it's instead a base bucket, it has a RBTC balance (`inrateBag`) from interests accumulated by leveraged instruments allocations, daily processing will move the corresponding daily payment from this "bag" to base bucket balance.
Balance accounting between buckets is articulated by a series of Smart Contracts that constitute the MoC ecosystem.

## Coverage

Is the ratio between the RBTC locked (backing DoCs) and the total amount of RBTC, be it in a particular bucket or the whole system (usually referred as global).
Locked RBTC amount is a result of the amount of DoCs and their price in BTC (BTC/USD rate).

## Tokens

### DoC

Its value is pegged to one dollar, in the sense that the SC (using [Oracle's](main-concepts.md#oracle) btc/usd price) will always[^1] return the equivalent amount of Bitcoin to satisfy that convertibility. It's targeted towards users seeking to avoid crypto's market volatility.
It's implemented as an ERC20 token, it can be traded freely, but minted/burned only by the MoC system. The more DocS minted, the more BTCx can be minted, since they are used for leverage.

[^1]: Needs sufficient collateral (coverage > 1) and redeems are only processed during [Settlements](process-actions.md#settlement)

### BitPro

It's targeted towards users seeking to _hodl_ Bitcoins and also receive a passive income from it. It's implemented as an ERC20 token, it can be traded freely, but minted/burned only by the MoC system. The more BitPros minted (introducing RBTC to the system), the more coverage the system has, since they add value to the system without locking any.

### MoC

The MoC token is designed to govern a decentralized autonomous organization (DAO), and can also be used to pay fees for the use of the platform at a lower rate than those to be paid with BTC. MoC holders will also be able to get a reward for staking and providing services to the platform. MoC token holders will vote on contract modifications and new features. On a basic level, the DAO decides whether or not to update the code of the smart contract.

## Leveraged instruments

### BTCx

It's targeted towards users looking to profit from long positions in bitcoin, with two times the risk and reward.
Leveraged instruments borrows capital from base bucket (50% in a X2) and pay a daily[^1] rate to it as return.
It can _not_ be traded freely and does _not_ have an ERC20 interface. BTCX positions can be canceled any time though.

[^1]: Actually uses X amount of block that, given the network, will approximate daily intervals.

## Oracle

It's crucial to the system workflow to have an up to date BTC-USD rate price feed to relay on. This is currently achieved by a separate contract so that it can be easily replaced in the future without affecting the MoC system. See [PriceProvider](priceprovider.md).
