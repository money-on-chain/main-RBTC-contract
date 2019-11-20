pragma solidity 0.5.8;

interface BtcPriceProvider {
  function peek() external view returns (bytes32, bool);
}