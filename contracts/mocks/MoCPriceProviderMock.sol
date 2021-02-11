pragma solidity 0.5.8;

import "../interface/TexPriceProvider.sol";

contract MoCPriceProviderMock is TexPriceProvider {
  uint256 mocPrice;

  /**
    @dev Constructor
    @param price MoC price for mock contract
  */
  constructor(uint256 price) public {
    setPrice(price);
  }

  function setPrice(uint256 price) public {
    mocPrice = price;
  }

  /**
    @dev Getter for every value related to a pair
    @return lastClosingPrice - the last price from a successful matching
  */
  function getLastClosingPrice(address /*_baseToken*/, address /*_secondaryToken*/) public view returns (uint256 lastClosingPrice) {
    return mocPrice;
  }
}