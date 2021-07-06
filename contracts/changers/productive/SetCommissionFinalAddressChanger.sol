pragma solidity ^0.5.8;

import "moc-governance/contracts/Governance/ChangeContract.sol";
import "../../auxiliar/CommissionSplitter.sol";

/**
  @notice This changer sets the destination address for a part of the
  commissions of all Money on Chain
 */
contract SetCommissionFinalAddressChanger is ChangeContract {
  CommissionSplitter public commissionSplitter;
  address payable public commissionAddress;

  constructor(CommissionSplitter _commissionSplitter, address payable _commissionAddress) public {
    commissionSplitter = _commissionSplitter;
    commissionAddress = _commissionAddress;
  }

  function execute() external {
    commissionSplitter.setCommissionAddress(commissionAddress);
  }
}