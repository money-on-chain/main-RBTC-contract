pragma solidity ^0.5.8;

import "../interface/PriceFeed.sol";
import "../interface/PriceProvider.sol";

contract BtcPriceProviderMock is PriceFeed, PriceProvider {
  bytes32 btcPrice;
  bool has;

  /**
    @dev Constructor
    @param price BTC price for mock contract
  */
  constructor(uint256 price) public {
    btcPrice = bytes32(price);
    has = true;
  }

  function peek() external view returns (bytes32, bool) {
    return (btcPrice, has);
  }

  function poke(uint128 val_, uint32) external {
    btcPrice = bytes32(uint256(val_));
  }

  function post(uint128 val_, uint32, address) external {
    btcPrice = bytes32(uint256(val_));
  }
}