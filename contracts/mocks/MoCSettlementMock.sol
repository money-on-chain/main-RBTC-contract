pragma solidity ^0.5.8;

import "../MoCSettlement.sol";

contract MoCSettlementMock is MoCSettlement {
  //Step count that complete the execution in all tests
  uint256 constant STEPS = 100;

  /**
    @dev Constructor
  */
  constructor() MoCSettlement() public { }

  function() external {
    require(false, "fallback function is not enabled");
  }

  function pubRunDeleveraging() public {
    initializeSettlement();
    executeTask(DELEVERAGING_TASK, STEPS);
  }

  function pubRunRedeemDoc() public returns(uint256) {
    initializeSettlement();
    executeTask(DOC_REDEMPTION_TASK, STEPS);
    return settlementInfo.finalCommissionAmount;
  }

  /**
    @dev Sets the number of blocks settlement will be allowed to run
    @param _blockSpan number of blocks
  */
  function setBlockSpan(uint256 _blockSpan) public {
    blockSpan = _blockSpan;
  }

  /**
  @dev Returns the amount of steps for the Doc Redemption task
  which is the amount of redeem requests in the queue. (Used in tests only)
  */
  function docRedemptionStepCountForTest() public view returns (uint256) {
    return super.docRedemptionStepCount();
  }
}
