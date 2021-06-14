pragma solidity ^0.5.8;

import "../interface/BtcPriceFeed.sol";
import "../interface/BtcPriceProvider.sol";

contract BtcPriceProviderMock_v019 is BtcPriceFeed, BtcPriceProvider {
  bytes32 btcPrice;
  bool has;

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