# MoCSettlement

- Referenced by: MoC, MoCState
- References/uses: Math, SafeMath, MoCBase, DocToken, MoCState, MoCExchange, MoCBProxManager, MoC
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
