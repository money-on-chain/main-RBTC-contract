# System states

System state is ruled by the global [Coverage](main-concepts.md#coverage) value, and it's relation with the Objective Coverage (Cobj), currently set to 4.

- Above coverage

  Healthy state of the system. Every Token can be minted, and every Token (besides non-free DoCs) can be redeemed.

- Below coverage

  When the coverage falls below a certain threshold (Cobj), BitPros can no longer be redeemed as a measure to keep the coverage as high as possible.
  Additionally, DoCs can't be minted.

- Discount sale of BitPro

  When the coverage falls below the next threshold (uTPDU, currently 1.6), BitPros are sold at a discounted price with the intention of pumping more bitcoins into the system.

- Liquidated

  If the former measures fail and the coverage falls below last threshold (currently 1.04) and liquidation is enabled, the contracts are locked allowing _only_ the redemption of remaining DoCs at the last available price.
  Although DoC Tokens can still be transferred freely, BitPro Token on the other hand is permanently paused, as it has lost all of its value.
  This state is irreversible, once the liquidation state is achieved on the contract, there is no coming back even if the price and/or coverage recovers.

## Protected mode

Additionally, the system can enter a protected mode when coverage falls below a certain threshold (currently 1.5), in which case neither BitPros can no longer be minted nor free DoCs can be redeemed. In case the price and/or coverage recovers, the system can go back to another state.

To know if the contract is in protected mode you can ask the **MocState** for the **protected** and the **globalCoverage()** values, if coverage is less than the protected threshold, the contract is in protected mode.

Note that eventually the contract can recover from this mode. In case it does not, two things can happen:
- global coverage stabilizes indefinitely below 1: liquidation is enabled
- global coverage stabilizes indefinitely below protected threshold but above 1: protected threshold is changed below its stabilization value