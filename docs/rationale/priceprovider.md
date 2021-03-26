# PriceProvider

- Referenced by: MocState, MoC
- References/uses: SafeMath

Provides the price of a token in US dollars.
Currently it's a mock of the future functionality, since the price can be set by anyone and there isn't any consensus mechanism.
It's assumed that in a future production release there will be a reliable, decentralized price providing oracle.
It's used by MocState to get the token price and moving average.

## BtcPriceProvider (PriceProvider)

- Referenced by: MocState, MoC
- References/uses: SafeMath

Provides the price of bitcoin in US dollars.
Currently it's a mock of the future functionality, since the price can be set by anyone and there isn't any consensus mechanism.
It's assumed that in a future production release there will be a reliable, decentralized price providing oracle.
It's used by MocState to get the bitcoin price and moving average.

## MoCPriceProvider (PriceProvider)

- Referenced by: MocState, MoC
- References/uses: SafeMath

Provides the price of MoC token in US dollars.
Currently it's a mock of the future functionality, since the price can be set by anyone and there isn't any consensus mechanism.
It's assumed that in a future production release there will be a reliable, decentralized price providing oracle.
It's used by MocState to get the MoC token price.
