pragma solidity ^0.5.8;

import "../MoCSettlement.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to set settlement to stall after execution
 * with MoC --- governance.
 */
contract MoCStallSettlementChanger is ChangeContract, Ownable{
  MoCSettlement private moCSettlement;
  uint256 public blockSpan;

  constructor(MoCSettlement _moCSettlement) public {
    moCSettlement = _moCSettlement;
  }

  function execute() external {
    moCSettlement.setSettlementToStall();
  }
}
