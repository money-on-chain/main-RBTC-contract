pragma solidity ^0.5.8;

import "moc-governance/contracts/Governance/ChangeContract.sol";

// These dont have to be exhaustively complete  interfaces; they only allow solidity to call the actual contract
interface DSAuth {
  function setOwner(address newOwner) external;
}

interface PriceFactory {
  function create() external returns (DSAuth);
}

interface Medianizer {
  function set(address priceFeed) external;
}

/**
 * @dev This productive contract to add a new PriceFeeder with moc---gobernanza.
 */
contract PriceFeederAdder is ChangeContract {
  PriceFactory public priceFactory;
  Medianizer public medianizer;
  address public priceFeedOwner;

  /**
    @dev Constructor
  */
  constructor(PriceFactory _priceFactory, Medianizer _medianizer, address _priceFeedOwner) public {
    priceFactory = _priceFactory;
    medianizer = _medianizer;
    priceFeedOwner = _priceFeedOwner;
  }

  function execute() external {
    DSAuth priceFeeder = priceFactory.create();
    priceFeeder.setOwner(priceFeedOwner);
    medianizer.set(address(priceFeeder));
  }
}
