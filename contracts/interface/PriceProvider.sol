pragma solidity ^0.5.8;

interface PriceProvider {
  function peek() external view returns (bytes32, bool);
}