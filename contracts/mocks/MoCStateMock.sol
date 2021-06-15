pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "../MoCState.sol";

contract MoCStateMock is MoCState {
  uint256 internal _daysToSettlement;

  /**
    @dev Constructor
  */
  constructor() MoCState() public { }

  function initialize(InitializeParams memory params) public initializer {
    _daysToSettlement = 4;
    super.initialize(params);
  }

  function setDaysToSettlement(uint256 daysToSettl) public {
    _daysToSettlement = daysToSettl;
  }

  function daysToSettlement() public view returns(uint256) {
    return _daysToSettlement;
  }
}