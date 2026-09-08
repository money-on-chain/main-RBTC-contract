pragma solidity ^0.5.8;

import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";

contract BitProInterestTimeBasedChangerMock is ChangeContract {
  MoCInrate private mocInrate;
  uint256 private nextPaymentTimestamp;

  constructor(MoCInrate _mocInrate, uint256 _nextPaymentTimestamp) public {
    mocInrate = _mocInrate;
    nextPaymentTimestamp = _nextPaymentTimestamp;
  }

  function execute() external {
    mocInrate.initializeBitProInterestSchedule(nextPaymentTimestamp);
  }
}
