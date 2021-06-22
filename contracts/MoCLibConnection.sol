pragma solidity ^0.5.8;

import "./MoCHelperLib.sol";

/**
  @dev Interface with MocHelperLib
 */
contract MoCLibConnection {
  using MoCHelperLib for MoCHelperLib.MocLibConfig;
  MoCHelperLib.MocLibConfig internal mocLibConfig;

  /*
  * Precision getters
  */
  function getMocPrecision() public view returns(uint256) {
    return mocLibConfig.mocPrecision;
  }

  function getReservePrecision() public view returns(uint256) {
    return mocLibConfig.reservePrecision;
  }

  function getDayPrecision() public view returns(uint256) {
    return mocLibConfig.dayPrecision;
  }

  function initializePrecisions() internal {
    mocLibConfig = MoCHelperLib.MocLibConfig({
      reservePrecision: 10 ** 18,
      mocPrecision: 10 ** 18,
      dayPrecision: 1
    });
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
