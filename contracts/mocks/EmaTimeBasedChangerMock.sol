pragma solidity ^0.5.8;

import "../MoCState.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";

contract EmaTimeBasedChangerMock is ChangeContract {
  MoCState private mocState;
  uint256 private nextDueTimestamp;

  constructor(MoCState _mocState, uint256 _nextDueTimestamp) public {
    mocState = _mocState;
    nextDueTimestamp = _nextDueTimestamp;
  }

  function execute() external {
    mocState.initializeEmaCalculation(nextDueTimestamp);
  }
}
