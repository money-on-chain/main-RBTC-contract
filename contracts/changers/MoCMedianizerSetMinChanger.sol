pragma solidity 0.5.8;

import "moc-governance/contracts/Governance/ChangeContract.sol";

interface Medianizer {
  function setMin(uint96 priceFeed) external;
}

contract MoCMedianizerSetMinChanger is ChangeContract {
  Medianizer public medianizer;
  uint96 public min;

  constructor(Medianizer _medianizer, uint96 _min) public {
    medianizer = _medianizer;
    min = _min;
  }

  function execute() external {
    medianizer.setMin(min);
  }
}
