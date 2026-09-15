pragma solidity ^0.5.8;

import "../MoCState.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";

contract EmaTimeSpanChangerMock is ChangeContract {
  MoCState private mocState;
  uint256 private timeSpan;

  constructor(MoCState _mocState, uint256 _timeSpan) public {
    mocState = _mocState;
    timeSpan = _timeSpan;
  }

  function execute() external {
    mocState.setEmaCalculationTimeSpan(timeSpan);
  }
}
