pragma solidity ^0.5.8;

import "../../MoCSettlement.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This productive contract is used to set settlement to stall after restart with moc---gobernanza.
 */
contract MoCRestartSettlementProdChanger is ChangeContract, Ownable{
  MoCSettlement private moCSettlement;

  constructor(MoCSettlement _moCSettlement) public {
    moCSettlement = _moCSettlement;
  }

  function execute() external {
    moCSettlement.restartSettlementState();
  }
}
