pragma solidity ^0.5.8;

import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";

contract BitProInterestTimeBasedChangerMock is ChangeContract {
  MoCInrate private mocInrate;
  uint256 private lastPaymentTimestamp;

  constructor(MoCInrate _mocInrate, uint256 _lastPaymentTimestamp) public {
    mocInrate = _mocInrate;
    lastPaymentTimestamp = _lastPaymentTimestamp;
  }

  function execute() external {
    mocInrate.initializeBitProInterestSchedule(lastPaymentTimestamp, 7 days);
  }
}
