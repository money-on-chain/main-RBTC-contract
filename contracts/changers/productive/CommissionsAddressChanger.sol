pragma solidity ^0.5.8;

import "moc-governance/contracts/Governance/ChangeContract.sol";
import "../../MoCInrate.sol";

contract CommissionsAddressChanger is ChangeContract {
  MoCInrate public mocInrate;
  address payable public newCommissionAddress;

  constructor(MoCInrate _mocInrate, address payable _newCommissionAddress) public {
    mocInrate = _mocInrate;
    newCommissionAddress = _newCommissionAddress;
  }

  function execute() external {
    mocInrate.setCommissionsAddress(newCommissionAddress);
  }
}