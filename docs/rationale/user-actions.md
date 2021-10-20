# User actions

## Minting

Token emission (minting/burning) is only allowed to be done through MOC system, users cannot create or destroy tokens directly on the ERC20 contracts.

### BitPro

Can only be minted in exchange for RBTC.
Given an amount of RBTC paid to the contract, the system calculates the corresponding BitPro amount to mint, RBTC and Bitpro balances are added to the base bucket and the new Tokens are sent to the user.
There's a discount sale, below a certain level of coverage (uTPDU, currently 1.6).
This increases coverage, and allows to mint `(sent_btc/target_coverage)*btc_price` extra DoCs, assuming the system is in the 'above coverage' state.

### DoC

Can only be minted in exchange for RBTC.
Given an amount of RBTC paid to the contract, the system calculates the corresponding DoCs amount to mint [^1], RBTC and DoC balances are added to the base bucket and the new Tokens are sent to the user.

[^1]: The contract must be in the 'Above coverage' state, but given the minting itself lowers coverage, the amount of DoCs to be minted is limited by the preservation of this state. (See `globalMaxDoc`)

### BTCx

Can only be "minted" in exchange of RBTC.
The process for the minting is as follows:

- An amount of RBTC is paid to the contract
- The interest to be paid is pre-determined based on: "days until next settlement", "DoCs abundance" and the amount sent.
- The interest computed in the previous item is subtracted from the sent amount, and transferred into the "interest bag" of the base bucket.
- DoCs are transferred from the base bucket into the leverage bucket, in the same "volume" as the amount remaining from what was sent.
- BTCx are assigned to the user. (This is not a Token transfer as leveraged instruments cannot change owner)

The interests are discounted from the sent BTC, that is, if a user sends `X` BTC, they'll be assigned `X - interests` BTCx equivalent.

## Redeeming

### BitPro

A user can "sell" their BitPro back to the contract and recover the corresponding amount of RBTC.
The contract must be in the 'Above coverage' state.
The BitPros and RBTC are simply discounted from the base bucket.

### DoC

#### On settlement

A DoC redeem request can be created to redeem any amount of DoCs, but this will be processed on next settlement.
The intended amount can be greater than user's balance at request time, allowing to, for example, redeem all future user's DoCs regardless of whether their balance increases.
The redemption of DoCs at the settlement is explained in detail in [its own section](process-actions.md#settlement).

#### Outside of settlement

Only free DoCs can be redeemed outside of the settlement.
Free DoCs are those that remain in the base bucket, that is, they were not transferred to another to provide leverage.
Tokens and their equivalent in RBTC are simply subtracted from the base bucket.

### BTCx

RBTC deposited are sent back to the user, alongside the refunded interests (waiting in inrateBag) for the remaining time until the settlement (not yet charged).
Associated DoCs are moved back to the base bucket.
