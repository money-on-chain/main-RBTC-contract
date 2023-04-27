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

## Redeeming

### BitPro

A user can "sell" their BitPro back to the contract and recover the corresponding amount of RBTC.
The contract must be in the 'Above coverage' state.
The BitPros and RBTC are simply discounted from the base bucket.

### DoC

Tokens and their equivalent in RBTC are simply subtracted from the base bucket.

