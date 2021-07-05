pragma solidity ^0.5.8;

import "../MoCSettlement.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration of MoCSettlement
 * with MoC --- governance.
 */
contract MoCSettlementChanger is ChangeContract, Ownable{
  MoCSettlement private moCSettlement;
  uint256 public blockSpan;

  constructor(MoCSettlement _moCSettlement, uint256 _blockSpan) public {
    moCSettlement = _moCSettlement;
    blockSpan = _blockSpan;
  }

  function execute() external {
    moCSettlement.setBlockSpan(blockSpan);
  }

  function setBlockSpan(uint256 _blockSpan) public onlyOwner() {
    blockSpan = _blockSpan;
  }
}
