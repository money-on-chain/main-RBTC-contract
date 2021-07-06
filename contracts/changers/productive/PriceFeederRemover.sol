pragma solidity ^0.5.8;

import "moc-governance/contracts/Governance/ChangeContract.sol";

// These doesnt have to be exhaustively complete interface; they only allow solidity to call the actual contract

interface Medianizer {
  function unset(address priceFeed) external;
}

/**
 * @dev This productive contract to remove a new PriceFeeder with moc---gobernanza.
 */
contract PriceFeederRemover is ChangeContract {
  Medianizer public medianizer;
  address public priceFeed;

  /**
    @dev Constructor
  */
  constructor(Medianizer _medianizer, address _priceFeed) public {
    medianizer = _medianizer;
    priceFeed = _priceFeed;
  }

  function execute() external {
    medianizer.unset(priceFeed);
  }
}
