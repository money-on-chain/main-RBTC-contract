pragma solidity ^0.5.8;

import "../MoCHelperLib.sol";

contract MoCHelperLibMock {
  using MoCHelperLib for MoCHelperLib.MocLibConfig;
  MoCHelperLib.MocLibConfig internal mocLibConfig;
  event MethodCalled(bytes32 name);

  /**
    @dev Constructor
  */
  constructor() public {
    mocLibConfig = MoCHelperLib.MocLibConfig({
      reservePrecision: 10 ** 18,
      mocPrecision: 10 ** 18,
      dayPrecision: 1
    });
  }

  function spotInrate(uint256 tMin, uint256 tMax, uint256 doc0, uint256 doct)
  public view returns(uint256) {
    return mocLibConfig.spotInrate(tMin, tMax, doc0, doct);
  }

  function maxBProWithDiscount(
    uint256 nB, uint256 nDoc, uint256 utpdu, uint256 peg,
    uint256 btcPrice, uint256 bproUsdPrice, uint256 spotDiscount
  )

  public view returns(uint256) {
    return mocLibConfig.maxBProWithDiscount(
      nB, nDoc, utpdu, peg, btcPrice, bproUsdPrice, spotDiscount
    );
  }

  function inrateAvg(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat1, uint256 abRat2)
  public view returns(uint256) {
    return mocLibConfig.inrateAvg(tMax, fact, tMin, abRat1, abRat2);
  }

  function avgInt( uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat1, uint256 abRat2)
  public view returns(uint256) {
    return mocLibConfig.avgInt(tMax, fact, tMin, abRat1, abRat2);
  }

  function potential(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat)
  public view returns(uint256) {
    return mocLibConfig.potential(tMax, fact, tMin, abRat);
  }

  function integral(uint256 tMax, uint256 fact, uint256 tMin, uint256 abRat)
  public view returns(uint256) {
    return mocLibConfig.integral(tMax, fact, tMin, abRat);
  }

  function bproSpotDiscountRate(
    uint256 bproLiqDiscountRate, uint256 liq, uint256 utpdu, uint256 cov
  ) public view returns(uint256) {
    return mocLibConfig.bproSpotDiscountRate(bproLiqDiscountRate, liq, utpdu, cov);
  }

  // For testing purposes, sends infinite leverage to contract
  function bucketTransferAmountInfiniteLeverage(uint256 nB, uint256 delta)
  public view returns (uint256) {
    return mocLibConfig.bucketTransferAmount(nB, mocLibConfig.getMaxInt() - delta);
  }

  function bucketTransferAmount(uint256 nB,uint256 lev) public view returns (uint256) {
    return mocLibConfig.bucketTransferAmount(nB, lev);
  }

  function coverage(uint256 nB,uint256 lB) public view returns (uint256) {
    return mocLibConfig.coverage(nB, lB);
  }

  function leverageFromCoverage(uint256 cov) public view returns (uint256) {
    return mocLibConfig.leverageFromCoverage(cov);
  }

  function leverage(uint256 nB,uint256 lB) public view returns (uint256) {
    return mocLibConfig.leverage(nB, lB);
  }

  function maxBProxBtcValue(uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 lev)
  public view returns (uint256) {
    return mocLibConfig.maxBProxBtcValue(nDoc, peg, btcPrice, lev);
  }

  // For testing purposes, sends infinite leverage to contract
  function maxBProxBtcValueInfiniteLeverage(
    uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 delta
  ) public view returns (uint256) {
    return mocLibConfig.maxBProxBtcValue(nDoc, peg, btcPrice, mocLibConfig.getMaxInt() - delta);
  }
}