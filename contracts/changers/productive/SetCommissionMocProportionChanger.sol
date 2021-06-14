pragma solidity ^0.5.8;

import "moc-governance/contracts/Governance/ChangeContract.sol";
import "../../auxiliar/CommissionSplitter.sol";

/**
  @notice This changer sets the proportion of the commissions that will return
  to Money on Chain to increase reserves
 */
contract SetCommissionMocProportionChanger is ChangeContract {
  CommissionSplitter public commissionSplitter;
  uint256 public mocProportion;

  constructor(CommissionSplitter _commissionSplitter, uint256 _mocProportion) public {
    commissionSplitter = _commissionSplitter;
    mocProportion = _mocProportion;
  }

  function execute() external {
    commissionSplitter.setMocProportion(mocProportion);
  }
}