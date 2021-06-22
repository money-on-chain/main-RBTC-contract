pragma solidity ^0.5.8;

interface BtcPriceProvider_v019 {
  function peek() external view returns (bytes32, bool);
}