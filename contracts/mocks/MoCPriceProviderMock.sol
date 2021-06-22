pragma solidity ^0.5.8;

import "../interface/PriceFeed.sol";
import "../interface/PriceProvider.sol";

contract MoCPriceProviderMock is PriceFeed, PriceProvider {
  bytes32 mocPrice;
  bool has;

  /**
    @dev Constructor
    @param price MoC price for mock contract
  */
  constructor(uint256 price) public {
    mocPrice = bytes32(price);
    has = true;
  }

  function peek() external view returns (bytes32, bool) {
    return (mocPrice, has);
  }

  function poke(uint128 val_, uint32) external {
    mocPrice = bytes32(uint256(val_));
  }

  function post(uint128 val_, uint32, address) external {
    mocPrice = bytes32(uint256(val_));
  }
}