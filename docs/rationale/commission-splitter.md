# CommissionSplitter

The CommissionSplitter is the contract used to implement [Commission Splitting](process-actions.md#commission-splitting) functionality.
The contract has two main properties that can be modified by Governance:

- _commissionAddress_: Defines the final destination of the commissions after the split process takes place. Can be changed with `setCommissionAddress(address _commissionAddress)` function.
- _mocProportion_: Defines the proportion of the accumulated commissions that will be injected into MoC contract as collateral. Can be changed with `function setMocProportion(uint256 _mocProportion)`.
