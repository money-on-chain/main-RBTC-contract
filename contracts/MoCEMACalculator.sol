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

  // Historical block-scheduling slots retained only for proxy storage layout.
  uint256 internal lastEmaCalculation;
  uint256 internal emaCalculationBlockSpan;

  // First unused word in the deployed parent storage gap.
  uint256 public nextEmaCalculation;

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
   * @dev Sets the first timestamp-based EMA due date. This can only be done
   *      once through the governance-approved changer that upgrades the proxy.
   */
  function initializeEmaCalculation(uint256 nextDueTimestamp) public onlyAuthorizedChanger() {
    require(nextDueTimestamp > 0, "EMA timestamp must be positive");
    require(nextEmaCalculation == 0, "EMA schedule already initialized");
    nextEmaCalculation = nextDueTimestamp;
  }

  function shouldCalculateEma() public view returns(bool) {
    require(nextEmaCalculation != 0, "EMA schedule not initialized");
    return block.timestamp >= nextEmaCalculation;
  }

  /**
    * @dev Provides Bitcoin's Price and Moving average.
    * More information of EMA calculation https://en.wikipedia.org/wiki/Exponential_smoothing
    * @param initialEma Initial ema value
    * @param smoothFactor Weight coefficient for EMA calculation.
    * @param emaBlockSpan Historical initialization parameter retained for ABI compatibility.
  */
  function initializeMovingAverage(uint256 initialEma, uint256 smoothFactor, uint256 emaBlockSpan) internal {
    _doSetSmoothingFactor(smoothFactor);
    lastEmaCalculation = block.number;
    bitcoinMovingAverage = initialEma;
    emaCalculationBlockSpan = emaBlockSpan;
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

      nextEmaCalculation = block.timestamp.add(1 days);
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

  // One slot is consumed by nextEmaCalculation.
  uint256[49] private upgradeGap;
}
