pragma solidity ^0.5.8;

import "../MoCState.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";

contract EmaTimeBasedChangerMock is ChangeContract {
  MoCState private mocState;
  uint256 private lastCalculationTimestamp;

  constructor(MoCState _mocState, uint256 _lastCalculationTimestamp) public {
    mocState = _mocState;
    lastCalculationTimestamp = _lastCalculationTimestamp;
  }

  function execute() external {
    mocState.initializeEmaCalculation(lastCalculationTimestamp, 1 days);
  }
}
