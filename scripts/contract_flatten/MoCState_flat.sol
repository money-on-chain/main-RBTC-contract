// SPDX-License-Identifier: 
// File: openzeppelin-solidity/contracts/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: contracts/interface/PriceProvider.sol

pragma solidity ^0.5.8;

interface PriceProvider {
  function peek() external view returns (bytes32, bool);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: moc-governance/contracts/Governance/ChangeContract.sol

pragma solidity ^0.5.8;

/**
  @title ChangeContract
  @notice This interface is the one used by the governance system.
  @dev If you plan to do some changes to a system governed by this project you should write a contract
  that does those changes, like a recipe. This contract MUST not have ANY kind of public or external function
  that modifies the state of this ChangeContract, otherwise you could run into front-running issues when the governance
  system is fully in place.
 */
interface ChangeContract {

  /**
    @notice Override this function with a recipe of the changes to be done when this ChangeContract
    is executed
   */
  function execute() external;
}

// File: moc-governance/contracts/Governance/IGovernor.sol

pragma solidity ^0.5.8;


/**
  @title Governor
  @notice Governor interface. This functions should be overwritten to
  enable the comunnication with the rest of the system
  */
interface IGovernor{

  /**
    @notice Function to be called to make the changes in changeContract
    @dev This function should be protected somehow to only execute changes that
    benefit the system. This decision process is independent of this architechture
    therefore is independent of this interface too
    @param changeContract Address of the contract that will execute the changes
   */
  function executeChange(ChangeContract changeContract) external;

  /**
    @notice Function to be called to make the changes in changeContract
    @param _changer Address of the contract that will execute the changes
   */
  function isAuthorizedChanger(address _changer) external view returns (bool);
}

// File: zos-lib/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: moc-governance/contracts/Governance/Governed.sol

pragma solidity ^0.5.8;



/**
  @title Governed
  @notice Base contract to be inherited by governed contracts
  @dev This contract is not usable on its own since it does not have any _productive useful_ behaviour
  The only purpose of this contract is to define some useful modifiers and functions to be used on the
  governance aspect of the child contract
  */
contract Governed is Initializable {

  /**
    @notice The address of the contract which governs this one
   */
  IGovernor public governor;

  string constant private NOT_AUTHORIZED_CHANGER = "not_authorized_changer";

  /**
    @notice Modifier that protects the function
    @dev You should use this modifier in any function that should be called through
    the governance system
   */
  modifier onlyAuthorizedChanger() {
    require(governor.isAuthorizedChanger(msg.sender), NOT_AUTHORIZED_CHANGER);
    _;
  }

  /**
    @notice Initialize the contract with the basic settings
    @dev This initialize replaces the constructor but it is not called automatically.
    It is necessary because of the upgradeability of the contracts
    @param _governor Governor address
   */
  function initialize(IGovernor _governor) public initializer {
    governor = _governor;
  }

  /**
    @notice Change the contract's governor. Should be called through the old governance system
    @param newIGovernor New governor address
   */
  function changeIGovernor(IGovernor newIGovernor) public onlyAuthorizedChanger {
    governor = newIGovernor;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/MoCEMACalculator.sol

pragma solidity ^0.5.8;




contract MoCEMACalculator is Governed {
  using SafeMath for uint256;

  event MovingAverageCalculation (
    uint256 price,
    uint256 movingAverage
  );

  uint256 internal bitcoinMovingAverage;
  uint256 public smoothingFactor;
  uint256 public lastEmaCalculation;
  uint256 public emaCalculationBlockSpan;

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

  function getEmaCalculationBlockSpan() public view returns(uint256){
    return emaCalculationBlockSpan;
  }

  /**
  * @param blockSpan Defines how many blocks should pass between BMA calculations
  **/
  function setEmaCalculationBlockSpan(uint256 blockSpan) public onlyAuthorizedChanger() {
    emaCalculationBlockSpan = blockSpan;
  }

  function shouldCalculateEma() public view returns(bool) {
    return block.number >= lastEmaCalculation.add(emaCalculationBlockSpan);
  }

  function getLastEmaCalculation() public view returns(uint256) {
    return lastEmaCalculation;
  }

  /**
    @dev Provides Bitcoin's Price and Moving average.
     More information of EMA calculation https://en.wikipedia.org/wiki/Exponential_smoothing
    * @param initialEma Initial ema value
    * @param smoothFactor Weight coefficient for EMA calculation.
    * @param emaBlockSpan Block count in a period for EMA calculation
  */
  function initializeMovingAverage(uint256 initialEma, uint256 smoothFactor, uint256 emaBlockSpan) internal {
    _doSetSmoothingFactor(smoothFactor);
    lastEmaCalculation = block.number;
    bitcoinMovingAverage = initialEma;
    emaCalculationBlockSpan = emaBlockSpan;
  }

  /**
    @dev Calculates a EMA of the price.
     More information of EMA calculation https://en.wikipedia.org/wiki/Exponential_smoothing
    @param btcPrice Current price.
  */
  function setBitcoinMovingAverage(uint256 btcPrice) internal {
    if (shouldCalculateEma()) {
      uint256 weightedPrice = btcPrice.mul(smoothingFactor);
      uint256 currentEma = bitcoinMovingAverage.mul(coefficientComp()).add(weightedPrice)
        .div(FACTOR_PRECISION);

      lastEmaCalculation = block.number;
      bitcoinMovingAverage = currentEma;

      emit MovingAverageCalculation(btcPrice, currentEma);
    }
  }

  /**
    @dev Calculates the smoothing factor complement
  */
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

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/base/MoCWhitelist.sol

pragma solidity ^0.5.8;

/**
  @dev Provides access control between all MoC Contracts
 */
contract MoCWhitelist {
  mapping(address => bool) whitelist;

  /**
   * @dev Check if an account is whitelisted
   * @return Bool
   */
  function isWhitelisted(address account)
    public
    view
    returns (bool)
  {
    require(account != address(0), "Account must not be 0x0");
    return whitelist[account];
  }

  /**
   * @dev Add account to whitelist
   */
  function add(address account) internal {
    require(account != address(0), "Account must not be 0x0");
    require(!isWhitelisted(account), "Account not allowed to add accounts into white list");
    whitelist[account] = true;
  }

  /**
   * @dev Remove account from whitelist
   */
  function remove(address account) internal {
    require(account != address(0), "Account must not be 0x0");
    require(isWhitelisted(account), "Account is not allowed to remove address from the white list");

    whitelist[account] = false;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/base/MoCConnector.sol

pragma solidity ^0.5.8;



/**
  @dev Provides access control between all MoC Contracts
 */
contract MoCConnector is MoCWhitelist, Initializable {
  // References
  address payable public moc;
  address public docToken;
  address public bproToken;
  address public bproxManager;
  address public mocState;
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  address public DEPRECATED_mocConverter;
  address public mocSettlement;
  address public mocExchange;
  address public mocInrate;
  /** DEPRECATED mocBurnout **/
  address public mocBurnout;

  bool internal initialized;

  /**
    @dev Initializes the contract
    @param mocAddress MoC contract address
    @param docAddress DoCToken contract address
    @param bproAddress BProToken contract address
    @param bproxAddress BProxManager contract address
    @param stateAddress MoCState contract address
    @param settlementAddress MoCSettlement contract address
    @param exchangeAddress MoCExchange contract address
    @param inrateAddress MoCInrate contract address
    @param burnoutBookAddress (DEPRECATED) MoCBurnout contract address. DO NOT USE.
  */
  function initialize(
    address payable mocAddress,
    address docAddress,
    address bproAddress,
    address bproxAddress,
    address stateAddress,
    address settlementAddress,
    address exchangeAddress,
    address inrateAddress,
    address burnoutBookAddress
  ) public initializer {
    moc = mocAddress;
    docToken = docAddress;
    bproToken = bproAddress;
    bproxManager = bproxAddress;
    mocState = stateAddress;
    mocSettlement = settlementAddress;
    mocExchange = exchangeAddress;
    mocInrate = inrateAddress;
    mocBurnout = burnoutBookAddress;

    // Add to Whitelist
    add(mocAddress);
    add(docAddress);
    add(bproAddress);
    add(bproxAddress);
    add(stateAddress);
    add(settlementAddress);
    add(exchangeAddress);
    add(inrateAddress);
    add(burnoutBookAddress);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/base/MoCConstants.sol

pragma solidity ^0.5.8;

/**
 * @dev Defines special constants to use along all the MoC System
 */
contract MoCConstants {
  bytes32 constant public BUCKET_X2 = "X2";
  bytes32 constant public BUCKET_C0 = "C0";
}

// File: contracts/base/MoCBase.sol

pragma solidity ^0.5.8;




/**
  @dev General usefull modifiers and functions
 */
contract MoCBase is MoCConstants, Initializable {
  // Contracts
  MoCConnector public connector;

  bool internal initialized;

  function initializeBase(address connectorAddress) internal initializer {
    connector = MoCConnector(connectorAddress);
  }

  modifier onlyWhitelisted(address account) {
    require(connector.isWhitelisted(account), "Address is not whitelisted");
    _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/MoCHelperLib.sol

pragma solidity ^0.5.8;


library MoCHelperLib {

  struct MocLibConfig {
    uint256 reservePrecision;
    uint256 dayPrecision;
    uint256 mocPrecision;
  }

  using SafeMath for uint256;

  uint256 constant UINT256_MAX = ~uint256(0);

  /**
    @dev Returns max uint256 value constant.
    @return max uint256 value constant
  */
  function getMaxInt(MocLibConfig storage /*config*/) public pure returns(uint256) {
    return UINT256_MAX;
  }

  /**
    @dev Calculates average interest using integral function: T =  Rate = a * (x ** b) + c
    @param tMax maxInterestRate [using mocPrecision]
    @param power factor [using noPrecision]
    @param tMin minInterestRate C0 doc amount [using mocPrecision]
    @param abRat1 initial abundance ratio [using mocPrecision]
    @param abRat2 final abundance ratio [using mocPrecision]
    @return average interest rate [using mocPrecision]
  */
  function inrateAvg(MocLibConfig storage config, uint256 tMax, uint256 power, uint256 tMin, uint256 abRat1, uint256 abRat2)
  public view returns(uint256) {
    require(tMax > tMin, "Max inrate should be bigger than Min inrate");
    uint256 abRat1Comp = config.mocPrecision.sub(abRat1);
    uint256 abRat2Comp = config.mocPrecision.sub(abRat2);

    if (abRat1 == abRat2) {
      return potential(config, tMax, power, tMin, abRat1Comp);
    }
    else if (abRat2 < abRat1) {
      return avgInt(config, tMax, power, tMin, abRat1Comp, abRat2Comp);
    }
    else {
      return avgInt(config, tMax, power, tMin, abRat2Comp, abRat1Comp);
    }
  }

  /**
    @dev Calculates spot interest rate that BProx owners should pay to BPro owners: Rate = tMax * (abRatio ** power) + tMin
    @param tMin min interest rate [using mocPrecision]
    @param power power to use in the formula [using NoPrecision]
    @param tMax max interest rate [using mocPrecision]
    @param abRatio bucket C0  abundance Ratio [using mocPrecision]
   */
  function spotInrate(
    MocLibConfig storage config, uint256 tMax, uint256 power, uint256 tMin, uint256 abRatio
  ) public view returns(uint256) {
    uint256 abRatioComp = config.mocPrecision.sub(abRatio);

    return potential(config, tMax, power, tMin, abRatioComp);
  }

  /**
    @dev Calculates potential interests function with given parameters: Rate = a * (x ** b) + c
    @param a maxInterestRate [using mocPrecision]
    @param b factor [using NoPrecision]
    @param c minInterestRate C0 doc amount [using mocPrecision]
    @param value global doc amount [using mocPrecision]
  */
  function potential(MocLibConfig storage config, uint256 a, uint256 b, uint256 c, uint256 value)
  public view returns(uint256) {
    // value ** b
    // [MOC] ** [] = [MOC]
    uint256 aux1 = pow(value, b, config.mocPrecision);
    // (a * aux1) + c
    // [MOC] [MOC] / [MOC] + [MOC] = [MOC]
    return a.mul(aux1).div(config.mocPrecision).add(c);
  }

  /**
    @dev Calculates average of the integral function:
     T = (
              (c * xf + ((a * (xf ** (b + 1))) / (b + 1))) -
              (c * xi + ((a * (xi ** (b + 1))) / (b + 1)))
             ) / (xf - xi)
    @param a maxInterestRate [using mocPrecision]
    @param b factor [using NoPrecision]
    @param c minInterestRate C0 doc amount [using mocPrecision]
    @param value1 value to put in the function [using mocPrecision]
    @param value2 value to put in the function [using mocPrecision]
    @return average interest rate [using mocPrecision]
  */
  function avgInt(MocLibConfig storage config, uint256 a, uint256 b, uint256 c, uint256 value1, uint256 value2)
  public view returns(uint256) {
    // value2 - value1
    // [MOC]
    uint256 diff = value2.sub(value1);
    // ((c * (1 - value1) + ((a * ((1 - value1) ** (b + 1))) / (b + 1)))
    uint256 intV1 = integral(config, a, b, c, value1);
    // ((c * (1 - value2) + ((a * ((1 - value2) ** (b + 1))) / (b + 1)))
    uint256 intV2 = integral(config,  a, b, c, value2);
    // (secOp - first) / diff
    // ([MOC][MOC] - [MOC][MOC]) / [MOC] = [MOC]
    return intV2.sub(intV1).div(diff);
  }

  /**
    @dev Calculates integral of the exponential function: T = c * (value) + (a * value ** (b + 1)) / (b + 1))
    @param a maxInterestRate [using mocPrecision]
    @param b factor [using NoPrecision]
    @param c minInterestRate C0 doc amount [using mocPrecision]
    @param value value to put in the function [using mocPrecision]
    @return integration result [using mocPrecision]
  */
  function integral(MocLibConfig storage config, uint256 a, uint256 b, uint256 c, uint256 value)
  public view returns(uint256) {
    // b + 1
    // [NONE]
    uint256 b2 = b.add(1);
    // c * value
    // [MOC][MOC]
    uint256 firstOp = c.mul(value);
    // [MOC]
    uint256 pow = pow(value, b2, config.mocPrecision);
    // (a * value ** b2) / b2)
    // [MOC][MOC]
    uint256 secOp = a.mul(pow).div(b2);
    // (firstOp + secOp)
    // [MOC][MOC] + [MOC][MOC] = [MOC][MOC]
    return firstOp.add(secOp);
  }

  /**
  * @dev Relation between docs in bucket 0 and Doc total supply
  * @param doc0 doc count in bucket 0 [using mocPrecision]
  * @param doct total doc supply [using mocPrecision]
  * @return abundance ratio [using mocPrecision]
  */
  function abundanceRatio(MocLibConfig storage config, uint256 doc0, uint256 doct)
  public view returns(uint256) {
    if (doct == 0) {
      return config.mocPrecision;
    }
    // [DOC] [MOC] / [DOC] = [MOC]
    return doc0.mul(config.mocPrecision).div(doct);
  }

  /**
    @dev Returns the Ratio to apply to BPro Price in discount situations: SpotDiscountRate = TPD * (utpdu - cob) / (uptdu -liq)
    @param bproLiqDiscountRate Discount rate applied at Liquidation level coverage [using mocPrecision]
    @param liq Liquidation coverage threshold [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param cov Actual global Coverage threshold [using mocPrecision]
    @return Spot discount rate [using mocPrecision]
  */
  function bproSpotDiscountRate(
    MocLibConfig storage libConfig, uint256 bproLiqDiscountRate,
    uint256 liq, uint256 utpdu, uint256 cov
  ) public view returns(uint256) {
    require(bproLiqDiscountRate < libConfig.mocPrecision, "Discount rate should be lower than 1");

    if (cov >= utpdu) {
      return 0;
    }

    // utpdu - liq
    // [MOC] - [MOC] = [MOC]
    uint256 utpduLiqDiff = utpdu.sub(liq);

    // utpdu - cov
    // [MOC] - [MOC] = [MOC]
    uint256 utpduCovDiff = utpdu.sub(cov);

    // TPD * utpduCovDiff / utpduLiqDiff
    // [MOC] * [MOC] / [MOC] = [MOC]
    return bproLiqDiscountRate.mul(utpduCovDiff).div(utpduLiqDiff);
  }

  /**
    @dev Max amount of BPro to available with discount: MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)
    @param nB Total BTC amount [using reservePrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bproUsdPrice bproUsdPrice [using mocPrecision]
    @param spotDiscount spot discount [using mocPrecision]
    @return Total BPro amount [using mocPrecision]
  */
  function maxBProWithDiscount(
    MocLibConfig storage libConfig, uint256 nB, uint256 nDoc, uint256 utpdu,
    uint256 peg, uint256 btcPrice, uint256 bproUsdPrice, uint256 spotDiscount
  ) public view returns(uint256)  {
    require(spotDiscount < libConfig.mocPrecision, "Discount Rate should be lower than 1");

    if (spotDiscount == 0) {
      return 0;
    }

    // nBTC * B
    // [RES] * [MOC] / [RES] = [MOC]
    uint256 nbUsdValue = nB.mul(btcPrice).div(libConfig.reservePrecision);

    // (TPusd * (1 - TPD))
    // [MOC] * [MOC] / [MOC] = [MOC]
    uint256 bproDiscountPrice = bproUsdPrice.mul(libConfig.mocPrecision.sub(spotDiscount))
      .div(libConfig.mocPrecision);

    return maxBProWithDiscountAux(libConfig, nbUsdValue, nDoc, utpdu, peg, bproDiscountPrice);
  }

  /**
    @dev Max amount of BPro to available with discount: MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)
    @param nbUsdValue Total amount of BTC in USD [using mocPrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param bproDiscountPrice bproUsdPrice with discount applied [using mocPrecision]
    @param peg peg value
    @return Total BPro amount [using mocPrecision]
  */
  function maxBProWithDiscountAux(
    MocLibConfig storage libConfig, uint256 nbUsdValue, uint256 nDoc,
    uint256 utpdu, uint256 peg, uint256 bproDiscountPrice
  ) internal view returns(uint256) {

    // uTPDU * nDOC * PEG
    // [MOC] * [MOC] / [MOC] = [MOC]
    uint256 coverageUSDAmount = utpdu.mul(nDoc).mul(peg).div(libConfig.mocPrecision);

    // This case only occurs with Coverage below 1
    if (coverageUSDAmount <= nbUsdValue) {
      return 0;
    }

    // ([MOC] - [MOC]) * [RES] / [MOC] = [RES]
    return coverageUSDAmount.sub(nbUsdValue).mul(libConfig.reservePrecision).div(bproDiscountPrice);
  }

  /**
    @dev Calculates Locked bitcoin
    @param btcPrice BTC price [using mocPrecision]
    @param nDoc Docs amount [using mocPrecision]
    @param peg peg value
    @return Locked bitcoin [using reservePrecision]
  */
  function lockedBitcoin(
    MocLibConfig storage libConfig, uint256 btcPrice, uint256 nDoc, uint256 peg
  ) public view returns(uint256) {
    return nDoc.mul(peg).mul(libConfig.reservePrecision).div(btcPrice);
  }

  /**
    @dev Calculates price at liquidation event as a relation between the doc total supply
    and the amount of RBTC available to distribute
    @param rbtcAmount RBTC to distribute [using reservePrecision]
    @param nDoc Docs amount [using mocPrecision]
    @return Price at liquidation event [using mocPrecision]
  */
  function liquidationPrice(MocLibConfig storage libConfig, uint256 rbtcAmount, uint256 nDoc)
  public view returns(uint256) {
    // [MOC] * [RES] / [RES]
    return nDoc.mul(libConfig.reservePrecision).div(rbtcAmount);
  }

  /**
    @dev Calculates BPro BTC price: TPbtc = (nB-LB) / nTP
    @param nB Total BTC amount [using reservePrecision]
    @param lb Locked bitcoins amount [using reservePrecision]
    @param nTP BPro amount [using mocPrecision]
    @return BPro BTC price [using reservePrecision]
  */
  function bproTecPrice(MocLibConfig storage libConfig, uint256 nB, uint256 lb, uint256 nTP)
    public view returns(uint256) {
    // Liquidation happens before this condition turns true
    if (nB < lb) {
      return 0;
    }

    if (nTP == 0) {
      return libConfig.mocPrecision;
    }
    // ([RES] - [RES]) * [MOC] / [MOC]
    return nB.sub(lb).mul(libConfig.mocPrecision).div(nTP);
  }

  /**
    @dev Calculates BPro BTC price: BProxInBPro = bproxTecPrice / bproPrice
    @param bproxTecPrice BProx BTC price [using reservePrecision]
    @param bproPrice Trog BTC price [using reservePrecision]
    @return BProx price in BPro [using mocPrecision]
  */
  function bproxBProPrice(
    MocLibConfig storage libConfig, uint256 bproxTecPrice, uint256 bproPrice
  ) public view returns(uint256) {
    // [RES] * [MOC] / [RES] = [MOC]
    return bproxTecPrice.mul(libConfig.mocPrecision).div(bproPrice);
  }

  /**
    @dev Returns a new value with the discountRate applied: TPbtc = (price)* (1 - discountRate)
    @param price Price [using SomePrecision]
    @param discountRate Discount rate to apply [using mocPrecision]
    @return Price with discount applied [using SomePrecision]
  */
  function applyDiscountRate(MocLibConfig storage libConfig, uint256 price, uint256 discountRate)
    public view returns(uint256) {

    uint256 discountCoeff = libConfig.mocPrecision.sub(discountRate);

    return price.mul(discountCoeff).div(libConfig.mocPrecision);
  }

  /**
    @dev Returns the amount of interest to pay: TPbtc = price * interestRate
    @param value Cost to apply interest [using SomePrecision]
    @param interestRate Interest rate to apply [using mocPrecision]
    @return Interest cost based on the value and interestRate [using SomePrecision]
  */
  function getInterestCost(MocLibConfig storage libConfig, uint256 value, uint256 interestRate)
    public view returns(uint256) {
    // [ORIGIN] * [MOC] / [MOC] = [ORIGIN]
    return value.mul(interestRate).div(libConfig.mocPrecision);
  }

  /**
    @dev Calculates Coverage: Coverage = nB / LB
    @param nB Total BTC amount [using reservePrecision]
    @param lB Locked bitcoins amount [using reservePrecision]
    @return Coverage [using mocPrecision]
  */
  function coverage(MocLibConfig storage libConfig, uint256 nB, uint256 lB) public view
    returns(uint256) {
    if (lB == 0) {
      return UINT256_MAX;
    }

    return nB.mul(libConfig.mocPrecision).div(lB);
  }

 /**
    @dev Calculates Leverage from Coverage: Leverage = C / (C - 1)
    @param cov Coverage [using mocPrecision]
    @return Leverage [using mocPrecision]
  */
  function leverageFromCoverage(MocLibConfig storage libConfig, uint256 cov)
  public view returns(uint256) {
    if (cov == UINT256_MAX) {
      return libConfig.mocPrecision;
    }

    if (cov <= libConfig.mocPrecision) {
      return UINT256_MAX;
    }

    return cov.mul(libConfig.mocPrecision).div(cov.sub(libConfig.mocPrecision));
  }

 /**
    @dev Calculates Leverage: Leverage = nB / (nB - lB)
    @param nB Total BTC amount [using reservePrecision]
    @param lB Locked bitcoins amount [using reservePrecision]
    @return Leverage [using mocPrecision]
  */
  function leverage(MocLibConfig storage libConfig, uint256 nB,uint256 lB)
  public view returns(uint256) {
    if (lB == 0) {
      return libConfig.mocPrecision;
    }

    if (nB <= lB) {
      return UINT256_MAX;
    }

    return nB.mul(libConfig.mocPrecision).div(nB.sub(lB));
  }

  /**
    @dev Price in BTC of the amount of Docs
    @param amount Total BTC amount [using reservePrecision]
    @param btcPrice BTC price [using mocPrecision]
    @return Total value [using reservePrecision]
  */
  function docsBtcValue(
    MocLibConfig storage libConfig, uint256 amount,uint256 peg, uint256 btcPrice
  ) public view returns(uint256) {
    require(btcPrice > 0,"Bitcoin price should be more than zero");
    require(libConfig.reservePrecision > 0, "Precision should be more than zero");
    //Total = amount / satoshi price
    //Total = amount / (btcPrice / precision)
    // [RES] * [MOC] / [MOC]
    uint256 docBtcTotal = amount.mul(libConfig.mocPrecision).mul(peg).div(btcPrice);

    return docBtcTotal;
  }

 /**
    @dev Price in RBTC of the amount of BPros
    @param bproAmount amount of BPro [using mocPrecision]
    @param bproBtcPrice BPro price in RBTC [using reservePrecision]
    @return Total value [using reservePrecision]
  */
  function bproBtcValue(MocLibConfig storage libConfig, uint256 bproAmount, uint256 bproBtcPrice)
    public view returns(uint256) {
    require(libConfig.reservePrecision > 0, "Precision should be more than zero");

    // [MOC] * [RES] / [MOC] =  [RES]
    uint256 bproBtcTotal = bproAmount.mul(bproBtcPrice).div(libConfig.mocPrecision);

    return bproBtcTotal;
  }

  /**
    @dev Max amount of Docs to issue: MaxDoc = ((nB*B)-(Cobj*B/Bcons*nDoc*PEG))/(PEG*(Cobj*B/BCons-1))
    @param nB Total BTC amount [using reservePrecision]
    @param cobj Target Coverage [using mocPrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bCons BTC conservative price [using mocPrecision]
    @return Total Docs amount [using mocPrecision]
  */
  function maxDoc(
    MocLibConfig storage libConfig, uint256 nB,
    uint256 cobj, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons
  ) public view returns(uint256) {
    require(libConfig.reservePrecision > 0, "Invalid Precision");
    require(libConfig.mocPrecision > 0, "Invalid Precision");

    // If cobj is less than 1, just return zero
    if (cobj < libConfig.mocPrecision)
      return 0;

    // Cobj * B / BCons
    // [MOC] * [MOC] / [MOC] = [MOC]
    uint256 adjCobj = cobj.mul(btcPrice).div(bCons);

    return maxDocAux(libConfig, nB, adjCobj, nDoc, peg, btcPrice);
  }

  function maxDocAux(MocLibConfig storage libConfig, uint256 nB, uint256 adjCobj, uint256 nDoc, uint256 peg, uint256 btcPrice)
  internal view returns(uint256) {
    // (nB*B)
    // [RES] [MOC] [MOC] / [RES] = [MOC] [MOC]
    uint256 firstOperand = nB.mul(btcPrice).mul(libConfig.mocPrecision).div(libConfig.reservePrecision);
    // (adjCobj*nDoc*PEG)
    // [MOC] [MOC]
    uint256 secOperand = adjCobj.mul(nDoc).mul(peg);
    // (PEG*(adjCobj-1)
    // [MOC]
    uint256 denom = adjCobj.sub(libConfig.mocPrecision).mul(peg);

    if (firstOperand <= secOperand)
      return 0;

    // ([MOC][MOC] - [MOC][MOC]) / [MOC] = [MOC]
    return (firstOperand.sub(secOperand)).div(denom);
  }

  /**
    @dev Max amount of BPro to redeem: MaxBPro = ((nB*B)-(Cobj*nDoc*PEG))/TPusd
    @param nB Total BTC amount [using reservePrecision]
    @param cobj Target Coverage [using mocPrecision]
    @param nDoc Target Coverage [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bCons BTC conservative price [using mocPrecision]
    @param bproUsdPrice bproUsdPrice [using mocPrecision]
    @return Total BPro amount [using mocPrecision]
  */
  function maxBPro(
    MocLibConfig storage libConfig, uint256 nB, uint256 cobj,
    uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons, uint256 bproUsdPrice
  ) public view returns(uint256) {
    require(libConfig.reservePrecision > 0, "Invalid Precision");
    require(libConfig.mocPrecision > 0, "Invalid Precision");

    // Cobj * btcPrice / BCons
    // [MOC] * [MOC] / [MOC] = [MOC]
    uint256 adjCobj = cobj.mul(btcPrice).div(bCons);
    // (nB * btcPrice)
    // [RES] * [MOC] * [MOC] / [RES] = [MOC] [MOC]
    uint256 firstOperand = nB.mul(btcPrice)
      .mul(libConfig.mocPrecision)
      .div(libConfig.reservePrecision);
    // (adjCobj * nDoc * PEG)
    // [MOC] * [MOC]
    uint256 secOperand = adjCobj.mul(nDoc).mul(peg);

    if (firstOperand <= secOperand)
      return 0;

    // ([MOC][MOC] - [MOC][MOC]) / [MOC] = [MOC]
    return (firstOperand.sub(secOperand)).div(bproUsdPrice);
  }

  /**
    @dev Calculates the total BTC price of the amount of BPros
    @param amount Amount of BPro [using mocPrecision]
    @param bproPrice BPro BTC Price [using reservePrecision]
    @return BPro total value in BTC [using reservePrecision]
  */
  function totalBProInBtc(
    MocLibConfig storage libConfig, uint256 amount, uint256 bproPrice
  ) public view returns(uint256) {
    // [RES] * [MOC] / [MOC] = [RES]
    return bproPrice.mul(amount).div(libConfig.mocPrecision);
  }

  /**
    @dev Calculates the equivalent in Docs of the btcAmount
    @param btcAmount BTC  amount [using reservePrecision]
    @param btcPrice BTC price [using mocPrecision]
    @return Equivalent Doc amount [using mocPrecision]
  */
  function maxDocsWithBtc(
    MocLibConfig storage libConfig, uint256 btcAmount, uint256 btcPrice
  ) public view returns(uint256) {
    // [RES] * [MOC] / [RES] = [MOC]
    return btcAmount.mul(btcPrice).div(libConfig.reservePrecision);
  }

  /**
    @dev Calculates the equivalent in BPro of the btcAmount
    @param btcAmount BTC amount [using reservePrecision]
    @param bproPrice BPro BTC price [using reservePrecision]
    @return Equivalent Bpro amount [using mocPrecision]
  */
  function maxBProWithBtc(
    MocLibConfig storage libConfig, uint256 btcAmount, uint256 bproPrice
  ) public view returns(uint256) {
    if (bproPrice == 0) {
      return 0;
    }

    // [RES] * [MOC] / [RES]
    return btcAmount.mul(libConfig.mocPrecision).div(bproPrice);
  }

  /**
    @dev Calculates the Btc amount to move from C0 bucket to: toMove = btcAmount * (lev - 1)
    an L bucket when a BProx minting occurs
    @param btcAmount Total BTC amount [using reservePrecision]
    @param lev L bucket leverage [using mocPrecision]
    @return btc to move [using reservePrecision]
  */
  function bucketTransferAmount(
    MocLibConfig storage libConfig, uint256 btcAmount, uint256 lev
  ) public view returns(uint256) {
    require(lev > libConfig.mocPrecision, "Leverage should be more than 1");

    if (lev == UINT256_MAX || btcAmount == 0) {
      return 0;
    }

    // (lev-1)
    uint256 levSubOne = lev.sub(libConfig.mocPrecision);

    // Intentionally avaoid SafeMath
    // [RES] * [MOC]
    uint256 transferAmount = btcAmount * levSubOne;
    if (transferAmount / btcAmount != levSubOne)
      return 0;

    // [RES] * [MOC] / [MOC] = [RES]
    return transferAmount.div(libConfig.mocPrecision);
  }

  /**
    @dev Max amount of BTC allowed to be used to mint bprox: Maxbprox = nDOC/ (PEG*B*(lev-1))
    @param nDoc number of DOC [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param lev leverage [using mocPrecision]
    @return Max bprox BTC value [using reservePrecision]
  */
  function maxBProxBtcValue(
    MocLibConfig storage libConfig, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 lev
  ) public view returns(uint256)  {
    require(libConfig.reservePrecision > 0, "Invalid Precision");
    require(libConfig.mocPrecision > 0, "Invalid Precision");

    if (lev <= libConfig.mocPrecision) {
      return 0;
    }
    // (lev-1)
    // [MOC]
    uint256 levSubOne = lev.sub(libConfig.mocPrecision);

    // PEG * BtcPrice
    // [MOC]
    uint256 pegTimesPrice = peg.mul(btcPrice);

    // This intentionally avoid using safeMath to handle overflow case
    // PEG * BtcPrice * (lev - 1)
    // [MOC] * [MOC]
    uint256 dividend = pegTimesPrice * levSubOne;

    if (dividend / pegTimesPrice != levSubOne)
      return 0; // INFINIT dividend means 0

    // nDoc adjusted with precisions
    // [MOC] [RES]
    uint256 divider = nDoc.mul(libConfig.reservePrecision);

    // [MOC] [RES] [MOC] / [MOC] [MOC]
    return divider.mul(libConfig.mocPrecision).div(dividend);
  }

  /**
    @dev Calculates the equivalent in MoC of the btcAmount
    @param btcAmount BTC  amount
    @param btcPrice BTC price
    @param mocPrice MoC price
    @return Equivalent MoC amount
  */
  function maxMoCWithBtc(
    MocLibConfig storage /*libConfig*/, uint256 btcAmount, uint256 btcPrice, uint256 mocPrice
  ) public pure returns(uint256) {
    return btcPrice.mul(btcAmount).div(mocPrice);
  }

  /**
    @dev Calculates the equivalent in BTC of the MoC amount
    @param amount BTC  amount
    @param btcPrice BTC price
    @param mocPrice MoC price
    @return Equivalent MoC amount
  */
  function mocBtcValue(
    MocLibConfig storage /*libConfig*/, uint256 amount, uint256 btcPrice, uint256 mocPrice
  ) public pure returns(uint256) {
    require(btcPrice > 0,"Bitcoin price should be more than zero");
    require(mocPrice > 0,"MoC price should be more than zero");

    uint256 mocBtcTotal = amount.mul(mocPrice).div(btcPrice);

    return mocBtcTotal;
  }

  /**
    @dev Transform an address to payable address
    @param account Address to transform to payable
    @return Payable address for account
  */
  function getPayableAddress(
    MocLibConfig storage /*libConfig*/, address account
  ) public pure
  returns (address payable) {
    return address(uint160(account));
  }

  /**
    @dev Rounding product adapted from DSMath but with custom precision
    @param x Multiplicand
    @param y Multiplier
    @return Product
  */
  function mulr(uint x, uint y, uint256 precision) internal pure returns (uint z) {
    return x.mul(y).add(precision.div(2)).div(precision);
  }

  /**
    @dev Potentiation by squaring adapted from DSMath but with custom precision
    @param x Base
    @param n Exponent
    @return power
  */
  function pow(uint256 x, uint256 n, uint256 precision) internal pure returns (uint z) {
    uint256 x2 = x;
    z = n % 2 != 0 ? x : precision;

    for (n /= 2; n != 0; n /= 2) {
      x2 = mulr(x2, x2, precision);

      if (n % 2 != 0) {
        z = mulr(z, x2, precision);
      }
    }
  }
}

// File: contracts/MoCLibConnection.sol

pragma solidity ^0.5.8;


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

// File: contracts/MoCBucketContainer.sol

pragma solidity ^0.5.8;





contract MoCBucketContainer is MoCBase, Governed {
  using SafeMath for uint256;
  using Math for uint256;

  struct BProxBalance {
    uint256 value;
    uint index; // Index start in 1, zero is reserved for NULL
  }

  struct MoCBucket {
    bytes32 name;
    bool isBase;
    uint256 nDoc;
    uint256 nBPro;
    uint256 nBTC;
    uint256 cobj;
    // Should only be used in L buckets
    mapping(address => BProxBalance) bproxBalances;
    address payable[] activeBalances;
    uint256 activeBalancesLength;
    // Should only be used in Base buckets (C0)
    uint256 inrateBag;
    bool available;
  }

  event BucketMovement(
    bytes32 from,
    bytes32 to,
    uint256 reserves,
    uint256 stableTokens
  );

  event BucketCreation(
    bytes32 name,
    uint256 cobj
  );

  event BucketStateUpdate(
    bytes32 name,
    uint256 nReserve,
    uint256 nStable,
    uint256 nRiskProx,
    uint256 inrateBag
  );

  mapping(bytes32 => MoCBucket) internal mocBuckets;

   /**
   GETTERS
   */
  function getBucketNBTC(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nBTC;
  }

  function getBucketNBPro(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nBPro;
  }

  function getBucketNDoc(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nDoc;
  }

  function getBucketCobj(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].cobj;
  }

  function getInrateBag(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].inrateBag;
  }

  /**
   * @dev Sets the objective coverage (cobj) on an specficied bucket.
   * @param  _bucket - name of the bucket
   * @param  _cobj - new value of cobj
   */
  function setBucketCobj(bytes32 _bucket, uint256 _cobj) public onlyAuthorizedChanger(){
    //TODO: It is necessary to analyze the impact in the model it has when changing X2. This
    mocBuckets[_bucket].cobj = _cobj;
  }

  /**
    @dev returns true if the bucket is a base bucket
    @param bucket Name of the bucket
  */
  function isBucketBase(bytes32 bucket) public view returns(bool){
    return mocBuckets[bucket].isBase;
  }

  /**
    @dev returns true if the bucket have docs in it
    @param bucket Name of the bucket
  */
  function isBucketEmpty(bytes32 bucket) public view returns(bool) {
    return mocBuckets[bucket].nDoc == 0;
  }

  /**
    @dev Returns all the address that currently have bprox position for this bucket
    @param bucket bucket of the active address
  */
  function getActiveAddresses(bytes32 bucket) public view returns(address payable[] memory) {
    return mocBuckets[bucket].activeBalances;
  }

  /**
    @dev Returns all the address that currently have bprox position for this bucket
    @param bucket bucket of the active address
  */
  function getActiveAddressesCount(bytes32 bucket) public view returns(uint256 count) {
    return mocBuckets[bucket].activeBalancesLength;
  }

  /**
    @dev Add values to all variables of the bucket
    @param bucketName Name of the bucket
    @param btc BTC amount [using reservePrecision]
    @param doc Doc amount [using mocPrecision]
    @param bprox BPro amount [using mocPrecision]
  */
  function addValuesToBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox)
  public onlyWhitelisted(msg.sender) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    bucket.nBTC = bucket.nBTC.add(btc);
    bucket.nDoc = bucket.nDoc.add(doc);
    bucket.nBPro = bucket.nBPro.add(bprox);
  }

  /**
    @dev Substract values to all variables of the bucket
    @param bucketName Name of the bucket
    @param btc BTC amount [using reservePrecision]
    @param doc Doc amount [using mocPrecision]
    @param bprox BPro amount [using mocPrecision]
  */
  function substractValuesFromBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox)
  public onlyWhitelisted(msg.sender)  {
    MoCBucket storage bucket = mocBuckets[bucketName];

    bucket.nBTC = bucket.nBTC.sub(btc);
    bucket.nDoc = bucket.nDoc.sub(doc);
    bucket.nBPro = bucket.nBPro.sub(bprox);
  }

  /**
    @dev Moves BTC from inrateBag to main BTC bucket bag
    @param bucketName Name of the bucket to operate
    @param amount value to move from inrateBag to main bag [using reservePrecision]
   */
  function deliverInrate(bytes32 bucketName, uint256 amount) public
   onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) bucketStateUpdate(bucketName) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    uint256 toMove = Math.min(bucket.inrateBag, amount);

    bucket.inrateBag = bucket.inrateBag.sub(toMove);
    bucket.nBTC = bucket.nBTC.add(toMove);
  }

  /**
    @dev Removes Interests rate from Inrate bag
    @param bucketName Name of the bucket to operate
    @param amount value to move from inrateBag to main bag [using reservePrecision]
    @return Retrieved value
   */
  function recoverInrate(bytes32 bucketName, uint256 amount) public
  onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) bucketStateUpdate(bucketName) returns(uint256) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    uint256 toRetrieve = Math.min(bucket.inrateBag, amount);

    bucket.inrateBag = bucket.inrateBag.sub(toRetrieve);

    return toRetrieve;
  }

  /**
    @dev Moves BTC from origin bucket to destination bucket inrateBag
    @param bucketName name of the bucket to from which takes
    @param btcAmount value to add to main bag [using reservePrecision]
  */
  function payInrate(bytes32 bucketName, uint256 btcAmount) public
  onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) {
    MoCBucket storage bucket = mocBuckets[bucketName];
    bucket.inrateBag = bucket.inrateBag.add(btcAmount);
  }

  /**
    @dev Move Btcs and Docs from one bucket to another
    @param from Name of bucket from where the BTCs will be removed
    @param to Name of bucket from where the BTCs will be added
    @param btc BTCs amount [using reservePrecision]
    @param docs Docs amount [using mocPrecision]
  */
  function moveBtcAndDocs(bytes32 from, bytes32 to, uint256 btc, uint256 docs) public
  onlyWhitelisted(msg.sender) bucketStateUpdate(from) bucketStateUpdate(to) {
    MoCBucket storage bucketFrom = mocBuckets[from];
    MoCBucket storage bucketTo = mocBuckets[to];

    bucketFrom.nBTC = bucketFrom.nBTC.sub(btc);
    bucketTo.nBTC = bucketTo.nBTC.add(btc);

    bucketFrom.nDoc = bucketFrom.nDoc.sub(docs);
    bucketTo.nDoc = bucketTo.nDoc.add(docs);

    emit BucketMovement(from, to, btc, docs);
  }

  /**
    @dev Clears completely the origin bucket, removing all Docs, RBTCs and bproxs
    @param toLiquidate Bucket to be cleared out
    @param destination Bucket that will receive the Docs and RBTCs
   */
  function liquidateBucket(bytes32 toLiquidate, bytes32 destination) public onlyWhitelisted(msg.sender) {
    require(!isBucketBase(toLiquidate), "Cannot liquidate a base bucket");

    clearBucketBalances(toLiquidate);
    emptyBucket(toLiquidate, destination);
  }

  /**
    @dev Clears Docs and BTC from bucket origin and sends them to destination bucket
    @param origin Bucket to clear out
    @param destination Destination bucket
  */
  function emptyBucket(bytes32 origin, bytes32 destination) public onlyWhitelisted(msg.sender) {
    moveBtcAndDocs(origin, destination, mocBuckets[origin].nBTC, mocBuckets[origin].nDoc);
  }

  /**
   * @dev checks if a bucket exists
   * @param bucket name of the bucket
   */
  function isAvailableBucket(bytes32 bucket) public view returns(bool) {
    return mocBuckets[bucket].available;
  }

  /**
    @dev Put all bucket BProx balances in zero
    @param bucketName Bucket to clear out
   */
  function clearBucketBalances(bytes32 bucketName) public onlyWhitelisted(msg.sender) {
    MoCBucket storage bucket = mocBuckets[bucketName];
    bucket.nBPro = 0;
    bucket.activeBalancesLength = 0;
  }

  /**
    @dev Creates bucket
    @param name Name of the bucket
    @param cobj Target Coverage of the bucket
    @param isBase Indicates if it is a base bucket (true) or not (false)
  */
  function createBucket(bytes32 name, uint256 cobj, bool isBase) internal {
    mocBuckets[name].name = name;
    mocBuckets[name].nDoc = 0;
    mocBuckets[name].nBPro = 0;
    mocBuckets[name].nBTC = 0;
    mocBuckets[name].cobj = cobj;
    mocBuckets[name].isBase = isBase;
    mocBuckets[name].available = true;
    emit BucketCreation(name, cobj);
  }

  modifier onlyBaseBucket(bytes32 bucket) {
    require(isBucketBase(bucket), "Bucket should be a base type bucket");
    _;
  }

  modifier bucketStateUpdate(bytes32 bucket) {
    _;
    emit BucketStateUpdate(
      bucket,
      mocBuckets[bucket].nBTC,
      mocBuckets[bucket].nDoc,
      mocBuckets[bucket].nBPro,
      mocBuckets[bucket].inrateBag
      );
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/MoCBProxManager.sol

pragma solidity ^0.5.8;




contract MoCBProxManager is MoCBucketContainer {
  using SafeMath for uint256;
  uint256 constant MIN_ALLOWED_BALANCE = 0;

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
    @param _governor Governor contract address
    @param _c0Cobj Bucket C0 objective coverage
    @param _x2Cobj Bucket X2 objective coverage
  */
  function initialize(
    address connectorAddress,
    address _governor,
    uint256 _c0Cobj,
    uint256 _x2Cobj
  ) public initializer {
    initializeBase(connectorAddress);
    initializeValues(_governor);
    createBucket(BUCKET_C0, _c0Cobj, true);
    createBucket(BUCKET_X2, _x2Cobj, false);
  }

  /**
    @dev returns user balance
    @param bucket BProx corresponding bucket to get balance from
    @param userAddress user address to get balance from
    @return total balance for the userAddress
  */
  function bproxBalanceOf(bytes32 bucket, address userAddress) public view returns(uint256) {
    BProxBalance memory userBalance = mocBuckets[bucket].bproxBalances[userAddress];
    if (!hasValidBalance(bucket, userAddress, userBalance.index)) return 0;
    return userBalance.value;
  }

  /**
    @dev verifies that this user has assigned balance for the given bucket
    @param bucket corresponding Leveraged bucket to get balance from
    @param userAddress user address to verify balance for
    @param index index, starting from 1, where the address of the user is being kept
    @return true if the user has assigned balance
  */
  function hasValidBalance(bytes32 bucket, address userAddress, uint index) public view returns(bool) {
    return (index != 0) &&
      (index <= getActiveAddressesCount(bucket)) &&
      (mocBuckets[bucket].activeBalances[index - 1] == userAddress);
  }

  /**
    @dev  Assigns the amount of BProx
    @param bucket bucket from which the BProx will be removed
    @param account user address to redeem for
    @param bproxAmount bprox amount to redeem [using mocPresicion]
    @param totalCost btc value of bproxAmount [using reservePrecision]
  */
  function assignBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 totalCost)
  public onlyWhitelisted(msg.sender) {
    uint256 currentBalance = bproxBalanceOf(bucket, account);

    setBProxBalanceOf(bucket, account, currentBalance.add(bproxAmount));
    addValuesToBucket(bucket, totalCost, 0, bproxAmount);
  }

  /**
    @dev Removes the amount of BProx and substract BTC cost from bucket
    @param bucket bucket from which the BProx will be removed
    @param userAddress user address to redeem for
    @param bproxAmount bprox amount to redeem [using mocPresicion]
    @param totalCost btc value of bproxAmount [using reservePrecision]
  */
  function removeBProx(bytes32 bucket, address payable userAddress, uint256 bproxAmount, uint256 totalCost)
  public onlyWhitelisted(msg.sender) {
    uint256 currentBalance = bproxBalanceOf(bucket, userAddress);

    setBProxBalanceOf(bucket, userAddress, currentBalance.sub(bproxAmount));
    substractValuesFromBucket(bucket, totalCost, 0, bproxAmount);
  }

  /**
    @dev Sets the amount of BProx
    @param bucket bucket from which the BProx will be setted
    @param userAddress user address to redeem for
    @param value bprox amount to redeem [using mocPresicion]
  */
  function setBProxBalanceOf(bytes32 bucket, address payable userAddress, uint256 value) public onlyWhitelisted(msg.sender) {
    mocBuckets[bucket].bproxBalances[userAddress].value = value;
    uint256 index = mocBuckets[bucket].bproxBalances[userAddress].index;
    if (!hasValidBalance(bucket, userAddress, index))
      index = 0;

    bool hasBalance = value > MIN_ALLOWED_BALANCE;
    // The address is not in the array
    if (index == 0) {
      if (hasBalance) {
        if (mocBuckets[bucket].activeBalances.length == mocBuckets[bucket].activeBalancesLength) {
          mocBuckets[bucket].activeBalances.length += 1;
        }
        uint256 currentIndex = mocBuckets[bucket].activeBalancesLength++;
        mocBuckets[bucket].activeBalances[currentIndex] = userAddress;
        mocBuckets[bucket].bproxBalances[userAddress].index = mocBuckets[bucket].activeBalancesLength;
      }
    } else {
      if (!hasBalance) {
        // We need to delete this address from the tracker
        uint256 lastActiveIndex = mocBuckets[bucket].activeBalancesLength;
        address payable keyToMove = mocBuckets[bucket].activeBalances[lastActiveIndex - 1];
        mocBuckets[bucket].activeBalances[index - 1] = keyToMove;
        // Alternative index and array decreases lenght to prevent gas limit
        mocBuckets[bucket].activeBalancesLength--;
        // Update moved key index
        mocBuckets[bucket].bproxBalances[keyToMove].index = index;
        // Disable empty account index (0 == NULL)
        mocBuckets[bucket].bproxBalances[userAddress].index = 0;
      }
    }
  }

  /**
   @dev intializes values of the contract
   @param _governor Governor contract address
  */
  function initializeValues(address _governor) internal {
    governor = IGovernor(_governor);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;



/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

pragma solidity ^0.5.0;



/**
 * @dev Extension of `ERC20` that adds a set of accounts with the `MinterRole`,
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See `ERC20._mint`.
     *
     * Requirements:
     *
     * - the caller must have the `MinterRole`.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/token/OwnerBurnableToken.sol

pragma solidity ^0.5.8;



/**
 * @title Owner Burnable Token
 * @dev Token that allows the owner to irreversibly burned (destroyed) any token.
 */
contract OwnerBurnableToken is Ownable, ERC20Mintable {
  /**
   * @dev Burns a specific amount of tokens for the address.
   * @param who who's tokens are gona be burned
   * @param value The amount of token to be burned.
   */
  function burn(address who, uint256 value) public onlyOwner {
    _burn(who, value);
  }
}

// File: contracts/token/DocToken.sol

pragma solidity ^0.5.8;



contract DocToken is ERC20Detailed, OwnerBurnableToken {

  string private _name = "Dollar on Chain";
  string private _symbol = "DOC";
  uint8 private _decimals = 18;

  /**
    @dev Constructor
  */
  constructor() Ownable() ERC20Detailed(_name, _symbol, _decimals) public {

  }

  /**
    @dev Fallback function
  */
  function() external {
  }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol

pragma solidity ^0.5.0;



/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

// File: contracts/token/BProToken.sol

pragma solidity ^0.5.8;




contract BProToken is ERC20Detailed, ERC20Pausable, OwnerBurnableToken {

  string private _name = "BitPRO";
  string private _symbol = "BITP";
  uint8 private _decimals = 18;

  /**
    @dev Constructor
  */
  constructor() Ownable() ERC20Detailed(_name, _symbol, _decimals) public {
  }

  /**
    @dev Fallback function
  */
  function() external {
  }
}

// File: contracts/token/MoCToken.sol

pragma solidity ^0.5.8;



contract MoCToken is ERC20Detailed, OwnerBurnableToken {

  string private _name = "MoC";
  string private _symbol = "MOC";
  uint8 private _decimals = 18;

  /**
    @dev Constructor
  */
  constructor() Ownable() ERC20Detailed(_name, _symbol, _decimals) public {

  }

  /**
    @dev Fallback function
  */
  function() external {
  }
}

// File: contracts/interface/IMoCSettlement.sol

pragma solidity ^0.5.8;

interface IMoCSettlement {
    function getRedeemRequestAt(uint256 _index) external view returns (address payable, uint256);

    function redeemQueueSize() external view returns (uint256);

    function docAmountToRedeem(address _who) external view returns (uint256);

    function addRedeemRequest(uint256 amount, address payable redeemer) external;

    function alterRedeemRequestAmount(bool isAddition, uint256 delta, address redeemer) external;

    function isSettlementEnabled() external view returns (bool);

    function runSettlement(uint256 steps) external returns (uint256);

    function isSettlementReady() external view returns (bool);

    function nextSettlementBlock() external view returns (uint256);
}

// File: contracts/interface/IMoCState.sol

pragma solidity ^0.5.8;

interface IMoCState {

     /******STATE MACHINE*********/
    enum States {
        // State 0
        Liquidated,
        // State 1
        BProDiscount,
        // State 2
        BelowCobj,
        // State 3
        AboveCobj
    }


    function addToRbtcInSystem(uint256 btcAmount) external;

    function subtractRbtcFromSystem(uint256 btcAmount) external;

    function coverage(bytes32 bucket) external view returns(uint256);

    function getRbtcRemainder() external view returns(uint256);

    function liq() external view returns(uint256);

    function state() external view returns(States);

    function peg() external view returns(uint256);

    function dayBlockSpan() external view returns(uint256);

    function getBitcoinPrice() external view returns(uint256);

    function getMoCPrice() external view returns(uint256);

    function getProtected() external view returns(uint256);

    function globalCoverage() external view returns(uint256);

    function getMoCVendors() external view returns(address);

    function getMoCToken() external view returns(address);

    function nextState() external;

    function maxBProWithDiscount() external view returns(uint256);

    function absoluteMaxBPro() external view returns(uint256);

    function absoluteMaxDoc() external view returns(uint256);

    function freeDoc() external view returns(uint256);

    function bproTecPrice() external view returns(uint256);

    function bproSpotDiscountRate() external view returns(uint256);

    function bproDiscountPrice() external view returns(uint256);

    function bucketBProTecPrice(bytes32 bucket) external view returns(uint256);

    function currentAbundanceRatio() external view returns(uint256);

    function abundanceRatio(uint256 doc0) external view returns(uint256);

    function daysToSettlement() external view returns(uint256);

    function leverage(bytes32 bucket) external view returns(uint256);

    function getBucketNBTC(bytes32 bucket) external view returns(uint256);

    function getLiquidationPrice() external view returns(uint256);

    function maxBProxBtcValue(bytes32 bucket) external view returns(uint256);

    function bucketBProTecPriceHelper(bytes32 bucket) external view returns(uint256);

    // Ex Mocconverter
    function docsToBtc(uint256 docAmount) external view returns(uint256);
    function btcToDoc(uint256 btcAmount) external view returns(uint256);
    function bproxToBtc(uint256 bproxAmount, bytes32 bucket) external view returns(uint256);
    function btcToBProx(uint256 btcAmount, bytes32 bucket) external view returns(uint256);


}

// File: contracts/MoCState.sol

pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;














contract MoCState is MoCLibConnection, MoCBase, MoCEMACalculator, IMoCState {
  using Math for uint256;
  using SafeMath for uint256;

  struct InitializeParams {
    address connectorAddress;
    address governor;
    address btcPriceProvider;
    uint256 liq;
    uint256 utpdu;
    uint256 maxDiscRate;
    uint256 dayBlockSpan;
    uint256 ema;
    uint256 smoothFactor;
    uint256 emaBlockSpan;
    uint256 maxMintBPro;
    address mocPriceProvider;
    address mocTokenAddress;
    address mocVendorsAddress;
    bool liquidationEnabled;
    uint256 protected;
  }

  // This is the current state.
  States public state;

  event StateTransition(States newState);
  event BtcPriceProviderUpdated(address oldAddress, address newAddress);

  // Contracts
  PriceProvider internal btcPriceProvider;
  IMoCSettlement internal mocSettlement;
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  address internal DEPRECATED_mocConverter;
  DocToken internal docToken;
  BProToken internal bproToken;
  MoCBProxManager internal bproxManager;

  // One Day based on 15 seconds blocks
  uint256 public dayBlockSpan;
  // Relation between DOC and dollar
  uint256 public peg;
  // BPro max discount rate
  // Reflects the discount spot rate at Liquidation level
  uint256 public bproMaxDiscountRate;
  // Liquidation limit
  // [using mocPrecision]
  uint256 public liq;
  // BPro with discount limit
  // [using mocPrecision]
  uint256 public utpdu;
  // Complete amount of Bitcoin in the system
  // this represents basically MoC Balance
  uint256 public rbtcInSystem;
  // Price to use at doc redemption at
  // liquidation event
  uint256 public liquidationPrice;
  // Liquidation enabled
  bool public liquidationEnabled;
  // Protected limit
  // [using mocPrecision]
  uint256 public protected;

  /**
    @dev Initializes the contract
    @param params Params defined in InitializeParams struct
  */
  function initialize(InitializeParams memory params) public initializer {
    initializePrecisions();
    initializeBase(params.connectorAddress);
    initializeContracts(params.mocTokenAddress, params.mocVendorsAddress);
    initializeValues(
      params.governor,
      params.btcPriceProvider,
      params.liq,
      params.utpdu,
      params.maxDiscRate,
      params.dayBlockSpan,
      params.maxMintBPro,
      params.mocPriceProvider,
      params.liquidationEnabled,
      params.protected);
    initializeMovingAverage(params.ema, params.smoothFactor, params.emaBlockSpan);
  }

  /**
   @dev Sets the max discount rate.
   @param rate Discount rate at liquidation level [using mocPrecision]
  */
  function setMaxDiscountRate(uint256 rate) public onlyAuthorizedChanger() {
    require(rate < mocLibConfig.mocPrecision, "rate is lower than mocPrecision");

    bproMaxDiscountRate = rate;
  }

  /**
   @dev Returns the value of the BPro max discount rate configuration param
   @return bproMaxDiscountRate BPro max discount rate
  */
  function getMaxDiscountRate() public view returns(uint256) {
    return bproMaxDiscountRate;
  }

  /**
    @dev Defines how many blocks there are in a day
    @param blockSpan blocks there are in a day
  */
  function setDayBlockSpan(uint256 blockSpan) public onlyAuthorizedChanger() {
    dayBlockSpan = blockSpan;
  }

  /**
   @dev Sets a new BTCProvider contract
   @param btcProviderAddress address of the BTC price provider contract
  */
  function setBtcPriceProvider(address btcProviderAddress) public onlyAuthorizedChanger() {
    address oldBtcPriceProviderAddress = address(btcPriceProvider);
    btcPriceProvider = PriceProvider(btcProviderAddress);
    emit BtcPriceProviderUpdated(oldBtcPriceProviderAddress, address(btcPriceProvider));
  }

  /**
   @dev Gets the BTCPriceProviderAddress
   @return address of the BTC price provider contract
  */
  function getBtcPriceProvider() public view returns(address) {
    return address(btcPriceProvider);
  }

  /**
   @dev Gets how many blocks there are in a day
   @return blocks there are in a day
  */
  function getDayBlockSpan() public view returns(uint256) {
    return dayBlockSpan;
  }

  /**
   @dev Subtract the btc amount passed by parameter to the total Bitcoin Amount
   @param btcAmount Amount that will be subtract to rbtcInSystem
  */
  function subtractRbtcFromSystem(uint256 btcAmount) public onlyWhitelisted(msg.sender) {
    rbtcInSystem = rbtcInSystem.sub(btcAmount);
  }

  /**
   @dev btcAmount Add the btc amount passed by parameter to the total Bitcoin Amount
   @param btcAmount Amount that will be added to rbtcInSystem
  */
  function addToRbtcInSystem(uint256 btcAmount) public onlyWhitelisted(msg.sender) {
    rbtcInSystem = rbtcInSystem.add(btcAmount);
  }

  /**
    @dev All BPros in circulation
   */
  function bproTotalSupply() public view returns(uint256) {
    return bproToken.totalSupply();
  }

  /**
    @dev All docs in circulation
   */
  function docTotalSupply() public view returns(uint256) {
    return docToken.totalSupply();
  }

  /**
    @dev Target coverage for complete system
  */
  function cobj() public view returns(uint256) {
    return bproxManager.getBucketCobj(BUCKET_C0);
  }

  /**
    @dev Amount of Bitcoins in the system excluding BTCx values and interests holdings
  */
  function collateralRbtcInSystem() public view returns(uint256) {
    uint256 rbtcInBtcx = bproxToBtcHelper(bproxManager.getBucketNBPro(BUCKET_X2),BUCKET_X2);
    uint256 rbtcInBag = bproxManager.getInrateBag(BUCKET_C0);

    return rbtcInSystem.sub(rbtcInBtcx).sub(rbtcInBag);
  }

  /**
    @dev GLOBAL Coverage
    @return coverage [using mocPrecision]
  */
  function globalCoverage() public view returns(uint256) {
    uint256 lB = globalLockedBitcoin();

    return mocLibConfig.coverage(collateralRbtcInSystem(), lB);
  }

  /**
   @dev BUCKET lockedBitcoin
   @param bucket Name of the bucket used
   @return lockedBitcoin amount [using reservePrecision]
  */
  function lockedBitcoin(bytes32 bucket) public view returns(uint256) {
    uint256 nDoc = bproxManager.getBucketNDoc(bucket);

    return mocLibConfig.lockedBitcoin(getBitcoinPrice(), nDoc, peg);
  }

  /**
   @dev Gets RBTC in BitPro within specified bucket
   @param bucket Name of the bucket used
   @return Bitcoin amount of BitPro in Bucket [using reservePrecision]
  */
  function getRbtcInBitPro(bytes32 bucket) public view returns(uint256) {
    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 lB = lockedBitcoin(bucket);

    if ( lB >= nB ){
      return 0;
    }

    return nB.sub(lB);
  }

  /**
   @dev Gets the RBTC in the contract that not corresponds to Doc collateral
   @return RBTC remainder [using reservePrecision]
  */
  function getRbtcRemainder() public view returns(uint256) {
    uint256 lB = globalLockedBitcoin();

    if ( lB >= rbtcInSystem ){
      return 0;
    }

    return rbtcInSystem.sub(lB);
  }

  /**
   @dev BUCKET Coverage
   @param bucket Name of the bucket used
   @return coverage [using coveragePrecision]
  */
  function coverage(bytes32 bucket) public view returns(uint256) {
    if (!bproxManager.isBucketBase(bucket) && bproxManager.isBucketEmpty(bucket)) {
      return bproxManager.getBucketCobj(bucket);
    }

    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 lB = lockedBitcoin(bucket);

    return mocLibConfig.coverage(nB, lB);
  }

  /**
   @dev Abundance ratio, receives tha amount of doc to use the value of doc0 and Doc total supply
   @return abundance ratio [using mocPrecision]
  */
  function abundanceRatio(uint256 doc0) public view returns(uint256) {
    return mocLibConfig.abundanceRatio(doc0, docTotalSupply());
  }

  /**
   @dev Relation between docs in bucket 0 and Doc total supply
   @return abundance ratio [using mocPrecision]
  */
  function currentAbundanceRatio() public view returns(uint256) {
    return abundanceRatio(getBucketNDoc(BUCKET_C0));
  }

  /**
   @dev BUCKET Leverage
   @param bucket Name of the bucket used
   @return coverage [using mocPrecision]
  */
  function leverage(bytes32 bucket) public view returns(uint256) {
    uint256 cov = coverage(bucket);

    return mocLibConfig.leverageFromCoverage(cov);
  }

  /**
   @dev GLOBAL maxDoc
   @return abundance ratio [using mocPrecision]
  */
  function globalMaxDoc() public view returns(uint256) {
    return mocLibConfig.maxDoc(collateralRbtcInSystem(), cobj(), docTotalSupply(), peg, getBitcoinPrice(), getBcons());
  }

  /**
   @dev Returns the amount of DoCs in bucket 0, that can be redeemed outside of settlement
   @return amount of docs in bucket 0, that can be redeemed outside of settlement [using mocPrecision]
  */
  function freeDoc() public view returns(uint256) {
    return bproxManager.getBucketNDoc(BUCKET_C0);
  }

  /**
   @dev BUCKET maxDoc
   @return abundance ratio [using mocPrecision]
  */
  function maxDoc(bytes32 bucket) public view returns(uint256) {
    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 nDoc = bproxManager.getBucketNDoc(bucket);
    uint256 bktCobj = bproxManager.getBucketCobj(bucket);

    return mocLibConfig.maxDoc(nB, bktCobj, nDoc, peg, getBitcoinPrice(), getBcons());
  }

  /**
   @dev GLOBAL maxBPro
   @return maxBPro for redeem [using reservePrecision]
  */
  function globalMaxBPro() public view returns(uint256) {
    uint256 bproPrice = bproUsdPrice();

    return mocLibConfig.maxBPro(
      collateralRbtcInSystem(), cobj(), docTotalSupply(), peg, getBitcoinPrice(), getBcons(), bproPrice
    );
  }

  /**
   @dev ABSOLUTE maxDoc
   @return maxDoc to issue [using mocPrecision]
  */
  function absoluteMaxDoc() public view returns(uint256) {
    return Math.min(globalMaxDoc(), maxDoc(BUCKET_C0));
  }

  /**
    @dev BUCKET maxBPro to redeem / mint
    @param bucket Name of the bucket used
    @return maxBPro for redeem [using mocPrecision]
  */
  function maxBPro(bytes32 bucket) public view returns(uint256) {
    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 nDoc = bproxManager.getBucketNDoc(bucket);
    uint256 bproPrice = bproUsdPrice();
    uint256 bktCobj = bproxManager.getBucketCobj(bucket);

    return mocLibConfig.maxBPro(
      nB, bktCobj, nDoc, peg, getBitcoinPrice(), getBcons(), bproPrice
    );
  }

  /**
   @dev GLOBAL max bprox to mint
   @param bucket Name of the bucket used
   @return maxBProx [using reservePrecision]
  */
  function maxBProx(bytes32 bucket) public view returns(uint256) {
    uint256 maxBtc = maxBProxBtcValue(bucket);

    return mocLibConfig.maxBProWithBtc(maxBtc, bucketBProTecPrice(bucket));
  }

  /**
   @dev GLOBAL max bprox to mint
   @param bucket Name of the bucket used
   @return maxBProx BTC value to mint [using reservePrecision]
  */
  function maxBProxBtcValue(bytes32 bucket) public view returns(uint256) {
    uint256 nDoc0 = bproxManager.getBucketNDoc(BUCKET_C0);
    uint256 bucketLev = leverage(bucket);

    return mocLibConfig.maxBProxBtcValue(nDoc0, peg, getBitcoinPrice(), bucketLev);
  }

  /**
   @dev ABSOLUTE maxBPro
   @return maxDoc to issue [using mocPrecision]
  */
  function absoluteMaxBPro() public view returns(uint256) {
    return Math.min(globalMaxBPro(), maxBPro(BUCKET_C0));
  }

  /**
   @dev DISCOUNT maxBPro
   @return maxBPro for mint with discount [using mocPrecision]
  */
  function maxBProWithDiscount() public view returns(uint256) {
    uint256 nDoc = docTotalSupply();
    uint256 bproSpotDiscount = bproSpotDiscountRate();
    uint256 bproPrice = bproUsdPrice();
    uint256 btcPrice = getBitcoinPrice();

    return mocLibConfig.maxBProWithDiscount(collateralRbtcInSystem(), nDoc, utpdu, peg, btcPrice, bproPrice,
      bproSpotDiscount);
  }

  /**
   @dev GLOBAL lockedBitcoin
   @return lockedBitcoin amount [using reservePrecision]
  */
  function globalLockedBitcoin() public view returns(uint256) {
    return mocLibConfig.lockedBitcoin(getBitcoinPrice(), docTotalSupply(), peg);
  }

  /**
   @dev BTC price of BPro
   @return the BPro Tec Price [using reservePrecision]
  */
  function bproTecPrice() public view returns(uint256) {
    return bucketBProTecPrice(BUCKET_C0);
  }

  /**
   @dev BUCKET BTC price of BPro
   @param bucket Name of the bucket used
   @return the BPro Tec Price [using reservePrecision]
  */
  function bucketBProTecPrice(bytes32 bucket) public view returns(uint256) {
    uint256 cov = globalCoverage();
    uint256 coverageThreshold = uint256(1).mul(mocLibConfig.mocPrecision);

    // If Protected Mode is reached and below threshold
    if (bucket == BUCKET_C0 && cov <= getProtected() && cov < coverageThreshold) {
      return 1; // wei
    }

    return bucketBProTecPriceHelper(bucket);
  }

  /**
   @dev BUCKET BTC price of BPro (helper)
   @param bucket Name of the bucket used
   @return the BPro Tec Price [using reservePrecision]
  */
  function bucketBProTecPriceHelper(bytes32 bucket) public view returns(uint256) {
    uint256 nBPro = bproxManager.getBucketNBPro(bucket);
    uint256 lb = lockedBitcoin(bucket);
    uint256 nB = bproxManager.getBucketNBTC(bucket);

    return mocLibConfig.bproTecPrice(nB, lb, nBPro);
  }

  /**
   @dev BTC price of BPro with spot discount applied
   @return the BPro Tec Price [using reservePrecision]
  */
  function bproDiscountPrice() public view returns(uint256) {
    uint256 bproTecprice = bproTecPrice();
    uint256 discountRate = bproSpotDiscountRate();

    return mocLibConfig.applyDiscountRate(bproTecprice, discountRate);
  }

  /**
   @dev BPro USD PRICE
   @return the BPro USD Price [using mocPrecision]
  */
  function bproUsdPrice() public view returns(uint256) {
    uint256 bproBtcPrice = bproTecPrice();
    uint256 btcPrice = getBitcoinPrice();

    return btcPrice.mul(bproBtcPrice).div(mocLibConfig.reservePrecision);
  }

 /**
   @dev GLOBAL max bprox to mint
   @param bucket Name of the bucket used
   @return max BPro allowed to be spent to mint BProx [using reservePrecision]
  */
  function maxBProxBProValue(bytes32 bucket) public view returns(uint256) {
    uint256 btcValue = maxBProxBtcValue(bucket);

    return mocLibConfig.maxBProWithBtc(btcValue, bproTecPrice());
  }

  /**
   @dev BUCKET BProx price in BPro
   @param bucket Name of the bucket used
   @return BProx BPro Price [using mocPrecision]
  */
  function bproxBProPrice(bytes32 bucket) public view returns(uint256) {
    // Otherwise, it reverts.
    if (state == States.Liquidated) {
      return 0;
    }

    uint256 bproxBtcPrice = bucketBProTecPrice(bucket);
    uint256 bproBtcPrice = bproTecPrice();

    return mocLibConfig.bproxBProPrice(bproxBtcPrice, bproBtcPrice);
  }

  /**
   @dev GLOBAL BTC Discount rate to apply to BProPrice.
   @return BPro discount rate [using DISCOUNT_PRECISION].
  */
  function bproSpotDiscountRate() public view returns(uint256) {
    uint256 cov = globalCoverage();

    return mocLibConfig.bproSpotDiscountRate(bproMaxDiscountRate, liq, utpdu, cov);
  }

  /**
    @dev Calculates the number of days to next settlement based dayBlockSpan
    @return days to next settlement
  */
  function daysToSettlement() public view returns(uint256) {
    return blocksToSettlement().mul(mocLibConfig.dayPrecision).div(dayBlockSpan);
  }

  /**
    @dev Calculates the number of blocks to settlement
    @return Number of blocks to settlement
  */
  function blocksToSettlement() public view returns(uint256) {
    if (mocSettlement.nextSettlementBlock() <= block.number) {
      return 0;
    }

    return mocSettlement.nextSettlementBlock().sub(block.number);
  }

  /**
    @dev Verifies if forced liquidation is reached checking if globalCoverage <= liquidation (currently 1.04)
     and if liquidation is enabled
    @return true if liquidation state is reached, false otherwise
   */
  function isLiquidationReached() public view returns(bool) {
    uint256 cov = globalCoverage();
    if (state != States.Liquidated && cov <= liq && liquidationEnabled)
      return true;
    return false;
  }

  /**
    @dev Gets the price to use for doc redeem in a liquidation event
    @return price to use for doc redeem in a liquidation event
  */
  function getLiquidationPrice() public view returns(uint256) {
    return liquidationPrice;
  }

  function getBucketNBTC(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getBucketNBTC(bucket);
  }

  function getBucketNBPro(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getBucketNBPro(bucket);
  }

  function getBucketNDoc(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getBucketNDoc(bucket);
  }

  function getBucketCobj(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getBucketCobj(bucket);
  }

  function getInrateBag(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getInrateBag(bucket);
  }

  /**********************
    BTC PRICE PROVIDER
   *********************/

  function getBcons() public view returns(uint256) {
    return Math.min(getBitcoinPrice(), getBitcoinMovingAverage());
  }

  function getBitcoinPrice() public view returns(uint256) {
    (bytes32 price, bool has) = btcPriceProvider.peek();
    require(has, "Oracle have no Bitcoin Price");

    return uint256(price);
  }


  function calculateBitcoinMovingAverage() public {
    setBitcoinMovingAverage(getBitcoinPrice());
  }



  /**
   @dev return the value of the liq threshold configuration param
   @return liq threshold, currently 1.04
  */
  function getLiq() public view returns(uint256) {
    return liq;
  }

  /**
   @dev sets the value of the liq threshold configuration param
   @param _liq liquidation threshold
  */
  function setLiq(uint _liq) public onlyAuthorizedChanger(){
    liq = _liq;
  }

  /**
    @dev return the value of the utpdu threshold configuration param
    @return utpdu Universal TPro discount sales coverage threshold
  */
  function getUtpdu() public view returns(uint256) {
    return utpdu;
  }

  /**
   @dev sets the value of the utpdu threshold configuration param
   @param _utpdu Universal TPro discount sales coverage threshold
  */
  function setUtpdu(uint _utpdu) public onlyAuthorizedChanger(){
    utpdu = _utpdu;
  }

  /**
   @dev returns the relation between DOC and dollar. By default it is 1.
   @return peg relation between DOC and dollar
  */
  function getPeg() public view returns(uint256) {
    return peg;
  }

  /**
   @dev sets the relation between DOC and dollar. By default it is 1.
   @param _peg relation between DOC and dollar
  */
  function setPeg(uint _peg) public onlyAuthorizedChanger(){
    peg = _peg;
  }

  /**
   @dev return the value of the protected threshold configuration param
   @return protected threshold, currently 1.5
  */
  function getProtected() public view returns(uint256) {
    return protected;
  }

  /**
   @dev sets the value of the protected threshold configuration param
   @param _protected protected threshold
  */
  function setProtected(uint _protected) public onlyAuthorizedChanger() {
    protected = _protected;
  }

  /**
   @dev returns if is liquidation enabled.
   @return liquidationEnabled is liquidation enabled
  */
  function getLiquidationEnabled() public view returns(bool) {
    return liquidationEnabled;
  }

  /**
   @dev returns if is liquidation enabled.
   @param _liquidationEnabled is liquidation enabled
  */
  function setLiquidationEnabled(bool _liquidationEnabled) public onlyAuthorizedChanger() {
    liquidationEnabled = _liquidationEnabled;
  }

  /**
   @dev Transitions to next state.
  */
  function nextState() public {
    // There is no coming back from Liquidation
    if (state == States.Liquidated)
      return;

    States prevState = state;
    calculateBitcoinMovingAverage();
    uint256 cov = globalCoverage();
    if (cov <= liq && liquidationEnabled) {
      setLiquidationPrice();
      state = States.Liquidated;
    } else if (cov > liq && cov <= utpdu) {
      state = States.BProDiscount;
    } else if (cov > utpdu && cov <= cobj()) {
      state = States.BelowCobj;
    } else {
      state = States.AboveCobj;
    }

    if (prevState != state)
      emit StateTransition(state);
  }

  /************************************/
  /***** UPGRADE v017       ***********/
  /************************************/

  /** START UPDATE V017: 01/11/2019 **/
  /** Public functions **/

  /**
   @dev Sets max mint BPro value
   @param _maxMintBPro [using mocPrecision]
  */
  function setMaxMintBPro(uint256 _maxMintBPro) public onlyAuthorizedChanger() {
    maxMintBPro = _maxMintBPro;
  }

  /**
    @dev return Max value posible to mint of BPro
    @return maxMintBPro
  */
  function getMaxMintBPro() public view returns(uint256) {
    return maxMintBPro;
  }

  /** END UPDATE V017: 01/11/2019 **/

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** and rename price interfaces **/
  /** Public functions **/

  /**********************
    MoC PRICE PROVIDER
   *********************/

  /**
   @dev Sets a new MoCProvider contract
   @param mocProviderAddress MoC price provider address
  */
  function setMoCPriceProvider(address mocProviderAddress) public onlyAuthorizedChanger() {
    address oldMoCPriceProviderAddress = address(mocPriceProvider);
    mocPriceProvider = PriceProvider(mocProviderAddress);
    emit MoCPriceProviderUpdated(oldMoCPriceProviderAddress, address(mocPriceProvider));
  }

  /**
   @dev Gets the MoCPriceProviderAddress
   @return MoC price provider address
  */
  function getMoCPriceProvider() public view returns(address) {
    return address(mocPriceProvider);
  }

  /**
   @dev Gets the MoCPrice
   @return MoC price
  */
  function getMoCPrice() public view returns(uint256) {
    (bytes32 price, bool has) = mocPriceProvider.peek();
    require(has, "Oracle have no MoC Price");

    return uint256(price);
  }

  /**********************
    Ex MoCConverter
   *********************/

   /**
  * @dev BTC equivalent for the amount of bpros given
  * @param amount Amount of BPro to calculate the total price
  * @return total BTC Price of the amount BPros [using reservePrecision]
  */
  function bproToBtc(uint256 amount) public view returns(uint256) {
    uint256 tecPrice = bproTecPrice();

    return mocLibConfig.totalBProInBtc(amount, tecPrice);
  }

  function docsToBtc(uint256 docAmount) public view returns(uint256) {
    return mocLibConfig.docsBtcValue(docAmount, peg, getBitcoinPrice());
  }

  function btcToDoc(uint256 btcAmount) public view returns(uint256) {
    return mocLibConfig.maxDocsWithBtc(btcAmount, getBitcoinPrice());
  }

  function bproxToBtc(uint256 bproxAmount, bytes32 bucket) public view returns(uint256) {
    return mocLibConfig.bproBtcValue(bproxAmount, bucketBProTecPrice(bucket));
  }

  function bproxToBtcHelper(uint256 bproxAmount, bytes32 bucket) internal view returns(uint256) {
    return mocLibConfig.bproBtcValue(bproxAmount, bucketBProTecPriceHelper(bucket));
  }

  function btcToBProx(uint256 btcAmount, bytes32 bucket) public view returns(uint256) {
    return mocLibConfig.maxBProWithBtc(btcAmount, bucketBProTecPrice(bucket));
  }


  /**********************
    MoC TOKEN
   *********************/

  /**
   @dev Sets the MoC token contract address
   @param mocTokenAddress MoC token contract address
  */
  // TODO: Suggestion: create a "MoCConnectorChanger" contract and whitelist the address
  function setMoCToken(address mocTokenAddress) public onlyAuthorizedChanger() {
    setMoCTokenInternal(mocTokenAddress);
  }

  /**
   @dev Gets the MoC token contract address
   @return MoC token contract address
  */
  function getMoCToken() public view returns(address) {
    return address(mocToken);
  }

  /**********************
    MoC VENDORS
   *********************/

  // TODO: Suggestion: create a "MoCConnectorChanger" contract and whitelist the address
  /**
   @dev Sets the MoCVendors contract address
   @param mocVendorsAddress MoCVendors contract address
  */
  function setMoCVendors(address mocVendorsAddress) public onlyAuthorizedChanger() {
    setMoCVendorsInternal(mocVendorsAddress);
  }

  /**
   @dev Gets the MoCVendors contract addfress
   @return MoCVendors contract address
  */
  function getMoCVendors() public view returns(address) {
    return mocVendors;
  }

  /** END UPDATE V0112: 24/09/2020 **/

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** and rename price interfaces **/
  /** Internal functions **/

  /**********************
    MoC TOKEN
   *********************/

  /**
   @dev Sets the MoC token contract address (internal function)
   @param mocTokenAddress MoC token contract address
  */
  function setMoCTokenInternal(address mocTokenAddress) internal {
    mocToken = MoCToken(mocTokenAddress);

    emit MoCTokenChanged(mocTokenAddress);
  }

  /**********************
    MoC VENDORS
   *********************/

  /**
   @dev Sets the MoCVendors contract address (internal function)
   @param mocVendorsAddress MoCVendors contract address
  */
  function setMoCVendorsInternal(address mocVendorsAddress) internal {
    mocVendors = mocVendorsAddress;

    emit MoCVendorsChanged(mocVendorsAddress);
  }

  /** END UPDATE V0112: 24/09/2020 **/

  /**
    @dev Calculates price at liquidation event as the relation between
    the doc total supply and the amount of RBTC available to distribute
  */
  function setLiquidationPrice() internal {
    // When coverage is below 1, the amount to
    // distribute is all the RBTC in the contract
    uint256 rbtcAvailable = Math.min(globalLockedBitcoin(), rbtcInSystem);

    liquidationPrice = mocLibConfig.liquidationPrice(rbtcAvailable, docTotalSupply());
  }

  function initializeValues(
    address _governor,
    address _btcPriceProvider,
    uint256 _liq,
    uint256 _utpdu,
    uint256 _maxDiscRate,
    uint256 _dayBlockSpan,
    uint256 _maxMintBPro,
    address _mocPriceProvider,
    bool _liquidationEnabled,
    uint256 _protected) internal {
    liq = _liq;
    utpdu = _utpdu;
    bproMaxDiscountRate = _maxDiscRate;
    dayBlockSpan = _dayBlockSpan;
    governor = IGovernor(_governor);
    btcPriceProvider = PriceProvider(_btcPriceProvider);
    // Default values
    state = States.AboveCobj;
    peg = 1;
    maxMintBPro = _maxMintBPro;
    mocPriceProvider = PriceProvider(_mocPriceProvider);
    liquidationEnabled = _liquidationEnabled;
    protected = _protected;
  }

  function initializeContracts(address _mocTokenAddress, address _mocVendorsAddress) internal  {
    mocSettlement = IMoCSettlement(connector.mocSettlement());
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    setMoCTokenInternal(_mocTokenAddress);
    setMoCVendorsInternal(_mocVendorsAddress);
  }

  /************************************/
  /***** UPGRADE v017       ***********/
  /************************************/

  /** START UPDATE V017: 01/11/2019 **/
  /** Variables **/

  // Max value posible to mint of BPro
  uint256 public maxMintBPro;

  /** END UPDATE V017: 01/11/2019 **/

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** and rename price interfaces **/
  /** Variables and events **/

  PriceProvider internal mocPriceProvider;
  MoCToken internal mocToken;
  address internal mocVendors;

  event MoCPriceProviderUpdated(
    address oldAddress,
    address newAddress
  );

  event MoCTokenChanged (
    address mocTokenAddress
  );

  event MoCVendorsChanged (
    address mocVendorsAddress
  );

  /** END UPDATE V0112: 24/09/2020 **/

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
