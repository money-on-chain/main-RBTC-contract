pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "moc-governance/contracts/Governance/Governed.sol";
import "moc-governance/contracts/Governance/IGovernor.sol";

contract MoCEMACalculator is Governed {
  using SafeMath for uint256;

  event MovingAverageCalculation (
    uint256 price,
    uint256 movingAverage
  );

  uint256 internal bitcoinMovingAverage;
  uint256 public smoothingFactor;

  // Deprecated when EMA scheduling moved from blocks to timestamps. These
  // historical slots are retained only to preserve the proxy storage layout.
  uint256 internal deprecatedLastEmaCalculation;
  uint256 internal deprecatedEmaCalculationBlockSpan;

  // First unused word in the deployed parent storage gap.
  uint256 public lastEmaCalculationTimestamp;
  uint256 public emaCalculationTimeSpan;

  uint256 constant public PRICE_PRECISION =  10 ** 18;
  uint256 constant public FACTOR_PRECISION = 10 ** 18;

  function getBitcoinMovingAverage() public view returns(uint256) {
    return bitcoinMovingAverage;
  }

  function getSmoothingFactor() public view returns(uint256) {
    return smoothingFactor;
  }

  function setSmoothingFactor(uint256 factor) public onlyAuthorizedChanger() {
    _doSetSmoothingFactor(factor);
  }

  function getGovernorAddress() public view returns(address){
    return address(governor);
  }

  /**
   * @dev Sets the last timestamp-based EMA calculation. This can only be done
   *      once through the governance-approved changer that upgrades the proxy.
   */
  function initializeEmaCalculation(uint256 lastCalculationTimestamp, uint256 calculationTimeSpan)
    public onlyAuthorizedChanger() {
    require(lastCalculationTimestamp > 0, "EMA timestamp must be positive");
    require(calculationTimeSpan > 0, "EMA time span must be positive");
    require(lastEmaCalculationTimestamp == 0, "EMA schedule already initialized");
    require(emaCalculationTimeSpan == 0, "EMA time span already initialized");
    lastEmaCalculationTimestamp = lastCalculationTimestamp;
    emaCalculationTimeSpan = calculationTimeSpan;
  }

  function setEmaCalculationTimeSpan(uint256 calculationTimeSpan) public onlyAuthorizedChanger() {
    require(calculationTimeSpan > 0, "EMA time span must be positive");
    emaCalculationTimeSpan = calculationTimeSpan;
  }

  function shouldCalculateEma() public view returns(bool) {
    return block.timestamp >= lastEmaCalculationTimestamp.add(emaCalculationTimeSpan);
  }

  /**
    * @dev Provides Bitcoin's Price and Moving average.
    * More information of EMA calculation https://en.wikipedia.org/wiki/Exponential_smoothing
    * @param initialEma Initial ema value
    * @param smoothFactor Weight coefficient for EMA calculation.
  */
  function initializeMovingAverage(uint256 initialEma, uint256 smoothFactor) internal {
    _doSetSmoothingFactor(smoothFactor);
    lastEmaCalculationTimestamp = block.timestamp;
    emaCalculationTimeSpan = 1 days;
    bitcoinMovingAverage = initialEma;
  }

  /**
    * @dev Calculates a EMA of the price.
    * More information of EMA calculation https://en.wikipedia.org/wiki/Exponential_smoothing
    * @param btcPrice Current price.
  */
  function setBitcoinMovingAverage(uint256 btcPrice) internal {
    if (shouldCalculateEma()) {
      uint256 weightedPrice = btcPrice.mul(smoothingFactor);
      uint256 currentEma = bitcoinMovingAverage.mul(coefficientComp()).add(weightedPrice)
        .div(FACTOR_PRECISION);

      lastEmaCalculationTimestamp = block.timestamp;
      bitcoinMovingAverage = currentEma;

      emit MovingAverageCalculation(btcPrice, currentEma);
    }
  }

  function coefficientComp() internal view returns(uint256) {
    return FACTOR_PRECISION.sub(smoothingFactor);
  }

  function initializeGovernor(address _governor) internal {
    governor = IGovernor(_governor);
  }

  function _doSetSmoothingFactor(uint256 factor) private {
    require(factor <= FACTOR_PRECISION, "Invalid smoothing factor");
    smoothingFactor = factor;
  }

  // Two slots are consumed by the timestamp schedule.
  uint256[48] private upgradeGap;
}
