pragma solidity ^0.5.8;

import "../../../MoCSettlement.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration of MoCSettlement
 * with MoC --- governance.
 */
contract MoCSettlementChangerDeploy is ChangeContract, Ownable{
  MoCSettlement private moCSettlement;
  uint256 public blockSpan;

  constructor(MoCSettlement _moCSettlement) public {
    moCSettlement = _moCSettlement;
  }

  function execute() external {
    moCSettlement.fixTasksPointer();
  }

}
