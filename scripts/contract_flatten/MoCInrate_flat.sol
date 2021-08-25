// SPDX-License-Identifier: 
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

// File: contracts/interface/IMoCVendors.sol

pragma solidity ^0.5.8;

interface IMoCVendors {
    function resetTotalPaidInMoC() external;

    function getIsActive(address account) external view
    returns (bool);

    function getTotalPaidInMoC(address account) external view
    returns (uint256);

    function getStaking(address account) external view
    returns (uint256);

    function getMarkup(address account) external view
    returns (uint256);

    function updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount) external
    returns(bool);
}

// File: contracts/interface/IMoCInrate.sol

pragma solidity ^0.5.8;

interface IMoCInrate {
    // Transaction types
    function MINT_BPRO_FEES_RBTC() external view returns(uint8);
    function REDEEM_BPRO_FEES_RBTC() external view returns(uint8);
    function MINT_DOC_FEES_RBTC() external view returns(uint8);
    function REDEEM_DOC_FEES_RBTC() external view returns(uint8);
    function MINT_BTCX_FEES_RBTC() external view returns(uint8);
    function REDEEM_BTCX_FEES_RBTC() external view returns(uint8);
    function MINT_BPRO_FEES_MOC() external view returns(uint8);
    function REDEEM_BPRO_FEES_MOC() external view returns(uint8);
    function MINT_DOC_FEES_MOC() external view returns(uint8);
    function REDEEM_DOC_FEES_MOC() external view returns(uint8);
    function MINT_BTCX_FEES_MOC() external view returns(uint8);
    function REDEEM_BTCX_FEES_MOC() external view returns(uint8);

    function dailyInratePayment() external returns(uint256);

    function payBitProHoldersInterestPayment() external returns(uint256);

    function calculateBitProHoldersInterest() external view returns(uint256, uint256);

    function getBitProInterestAddress() external view returns(address payable);

    function getBitProRate() external view returns(uint256);

    function getBitProInterestBlockSpan() external view returns(uint256);

    function isDailyEnabled() external view returns(bool);

    function isBitProInterestEnabled() external view returns(bool);

    function commissionsAddress() external view returns(address payable);

    function calcCommissionValue(uint256 rbtcAmount, uint8 txType) external view returns(uint256);

    function calculateVendorMarkup(address vendorAccount, uint256 amount) external view returns (uint256 markup);

    function calcDocRedInterestValues(uint256 docAmount, uint256 rbtcAmount) external view returns(uint256);

    function calcMintInterestValues(bytes32 bucket, uint256 rbtcAmount) external view returns(uint256);

    function calcFinalRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) external view returns(uint256);

    function setBitProInterestBlockSpan(uint256 newBitProBlockSpan) external;
}

// File: contracts/MoCInrate.sol

pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;









contract MoCInrateEvents {
  event InrateDailyPay(uint256 amount, uint256 daysToSettlement, uint256 nReserveBucketC0);
  event RiskProHoldersInterestPay(uint256 amount, uint256 nReserveBucketC0BeforePay);
}

contract MoCInrateStructs {
  struct InrateParams {
    uint256 tMax;
    uint256 tMin;
    uint256 power;
  }

  InrateParams btcxParams = InrateParams({
    tMax: 261157876067800,
    tMin: 0,
    power: 1
  });

  struct InitializeParams {
    // MoCConnector contract address
    address connectorAddress;
    // Governor contract address
    address governor;
    // Minimum interest rate [using mocPrecision]
    uint256 btcxTmin;
    // Power is a parameter for interest rate calculation [using noPrecision]
    uint256 btcxPower;
    // Maximun interest rate [using mocPrecision]
    uint256 btcxTmax;
    // BitPro holder interest rate [using mocPrecision]
    uint256 bitProRate;
    // BitPro blockspan to configure payments periods[using mocPrecision]
    uint256 blockSpanBitPro;
    // Target address to transfer the weekly BitPro holders interest
    address payable bitProInterestTargetAddress;
    // Target address to transfer commissions of mint/redeem
    address payable commissionsAddressTarget;
    //uint256 commissionRateParam,
    // Upgrade to support red doc inrate parameter
    uint256 docTmin;
    // Upgrade to support red doc inrate parameter
    uint256 docPower;
    // Upgrade to support red doc inrate parameter
    uint256 docTmax;
  }
}


contract MoCInrate is MoCInrateEvents, MoCInrateStructs, MoCBase, MoCLibConnection, Governed, IMoCInrate {
  using SafeMath for uint256;

  // Last block when a payment was executed
  uint256 public lastDailyPayBlock;
  // Absolute  BitPro holders rate for the given bitProInterestBlockSpan time span. [using mocPrecision]
  uint256 public bitProRate;
  // Target address to transfer BitPro holders interests
  address payable public bitProInterestAddress;
  // Last block when an BitPro holders instereste was calculated
  uint256 public lastBitProInterestBlock;
  // BitPro interest Blockspan to configure blocks between payments
  uint256 public bitProInterestBlockSpan;

  // Target addres to transfer commissions of mint/redeem
  address payable public commissionsAddress;
  /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  /** DEPRECATED **/
  // commissionRate [using mocPrecision]
  // solium-disable-next-line mixedcase
  uint256 public DEPRECATED_commissionRate;

  /**CONTRACTS**/
  IMoCState internal mocState;
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  address internal DEPRECATED_mocConverter;
  MoCBProxManager internal bproxManager;

  /************************************/
  /***** UPGRADE v017       ***********/
  /************************************/

  /** START UPDATE V017: 01/11/2019 **/

  // Upgrade to support red doc inrate parameter
  uint256 public docTmin;
  uint256 public docPower;
  uint256 public docTmax;

  function setDoCTmin(uint256 _docTmin) public onlyAuthorizedChanger() {
    docTmin = _docTmin;
  }

  function setDoCTmax(uint256 _docTmax) public onlyAuthorizedChanger() {
    docTmax = _docTmax;
  }

  function setDoCPower(uint256 _docPower) public onlyAuthorizedChanger(){
    docPower = _docPower;
  }

  function getDoCTmin() public view returns(uint256) {
    return docTmin;
  }

  function getDoCTmax() public view returns(uint256) {
    return docTmax;
  }

  function getDoCPower() public view returns(uint256) {
    return docPower;
  }

  /**
    @dev Calculates an average interest rate between after and before free doc Redemption
    @param docRedeem Docs to redeem [using mocPrecision]
    @return Interest rate value [using mocPrecision]
   */
  function docInrateAvg(uint256 docRedeem) public view returns(uint256) {
    uint256 preAbRatio = mocState.currentAbundanceRatio();
    uint256 posAbRatio = mocState.abundanceRatio(bproxManager.getBucketNDoc(BUCKET_C0).sub(docRedeem));

    return mocLibConfig.inrateAvg(docTmax, docPower, docTmin, preAbRatio, posAbRatio);
  }

  /** END UPDATE V017: 01/11/2019 **/

  /**
    @dev Initializes the contract
    @param params Params defined in InitializeParams struct
  */
  function initialize(InitializeParams memory params) public initializer {
    initializePrecisions();
    initializeBase(params.connectorAddress);
    initializeContracts();
    initializeValues(
      params.governor,
      params.btcxTmin,
      params.btcxPower,
      params.btcxTmax,
      params.bitProRate,
      params.commissionsAddressTarget,
      //commissionRateParam,
      params.blockSpanBitPro,
      params.bitProInterestTargetAddress,
      params.docTmin,
      params.docPower,
      params.docTmax
    );
  }

  /**
   * @dev gets tMin param of BTCX tokens
   * @return returns tMin of BTCX
   */
  function getBtcxTmin() public view returns(uint256) {
    return btcxParams.tMin;
  }

  /**
   * @dev gets tMax param of BTCX tokens
   * @return returns tMax of BTCX
   */
  function getBtcxTmax() public view returns(uint256) {
    return btcxParams.tMax;
  }

  /**
   * @dev gets power param of BTCX tokens
   * @return returns power of BTCX
   */
  function getBtcxPower() public view returns(uint256) {
    return btcxParams.power;
  }

  /**
   * @dev Gets the blockspan of BPRO that represents the frecuency of BitPro holders intereset payment
   * @return returns power of bitProInterestBlockSpan
   */
  function getBitProInterestBlockSpan() public view returns(uint256) {
    return bitProInterestBlockSpan;
  }

  /**
   * @dev sets tMin param of BTCX tokens
   * @param _btxcTmin tMin of BTCX
   */
  function setBtcxTmin(uint256 _btxcTmin) public onlyAuthorizedChanger() {
    btcxParams.tMin = _btxcTmin;
  }

  /**
   * @dev sets tMax param of BTCX tokens
   * @param _btxcTax tMax of BTCX
   */
  function setBtcxTmax(uint256 _btxcTax) public onlyAuthorizedChanger() {
    btcxParams.tMax = _btxcTax;
  }

  /**
   * @dev sets power param of BTCX tokens
   * @param _btxcPower power of BTCX
   */
  function setBtcxPower(uint256 _btxcPower) public onlyAuthorizedChanger(){
    btcxParams.power = _btxcPower;
  }

  /**
   @dev Gets the rate for BitPro Holders
   @return BitPro Rate
  */
  function getBitProRate() public view returns(uint256) {
    return bitProRate;
  }

   /**
    @dev Sets BitPro Holders rate
    @param newBitProRate New BitPro rate
   */
  function setBitProRate(uint256 newBitProRate) public onlyAuthorizedChanger() {
    bitProRate = newBitProRate;
  }

   /**
    @dev Sets the blockspan BitPro Intereset rate payment is enable to be executed
    @param newBitProBlockSpan New BitPro Block span
   */
  function setBitProInterestBlockSpan(uint256 newBitProBlockSpan) public onlyAuthorizedChanger() {
    bitProInterestBlockSpan = newBitProBlockSpan;
  }

  /**
   @dev Gets the target address to transfer BitPro Holders rate
   @return Target address to transfer BitPro Holders interest
  */
  function getBitProInterestAddress() public view returns(address payable) {
    return bitProInterestAddress;
  }

  /**
   @dev Sets the target address to transfer BitPro Holders rate
   @param newBitProInterestAddress New BitPro rate
  */
  function setBitProInterestAddress(address payable newBitProInterestAddress ) public onlyAuthorizedChanger() {
    bitProInterestAddress = newBitProInterestAddress;
  }

  /**
   @dev Sets the target address to transfer commissions of Mint/Redeem transactions
   @param newCommissionsAddress New commisions address
  */
  function setCommissionsAddress(address payable newCommissionsAddress) public onlyAuthorizedChanger() {
    commissionsAddress = newCommissionsAddress;
  }

  /**
    @dev Calculates interest rate for BProx Minting, redeem and Free Doc Redeem
    @return Interest rate value [using RatePrecsion]
   */
  function spotInrate() public view returns(uint256) {
    uint256 abRatio = mocState.currentAbundanceRatio();

    return mocLibConfig.spotInrate(btcxParams.tMax, btcxParams.power, btcxParams.tMin, abRatio);
  }

  /**
    @dev Calculates an average interest rate between after and before mint/redeem
    @param bucket Name of the bucket involved in the operation
    @param btcAmount Value of the operation from which calculates the inrate [using reservePrecision]
    @param onMinting Value that represents if the calculation is based on mint or on redeem
    @return Interest rate value [using mocPrecision]
   */
  function btcxInrateAvg(bytes32 bucket, uint256 btcAmount, bool onMinting) public view returns(uint256) {
    uint256 preAbRatio = mocState.currentAbundanceRatio();
    uint256 posAbRatio = mocState.abundanceRatio(simulateDocMovement(bucket, btcAmount, onMinting));

    return mocLibConfig.inrateAvg(btcxParams.tMax, btcxParams.power, btcxParams.tMin, preAbRatio, posAbRatio);
  }

  /**
    @dev returns the amount of BTC to pay in concept of interest to bucket C0
   */
  function dailyInrate() public view returns(uint256) {
    uint256 daysToSettl = mocState.daysToSettlement();
    uint256 totalInrateInBag = bproxManager.getInrateBag(BUCKET_C0);

    if (daysToSettl < mocLibConfig.dayPrecision) {
      return totalInrateInBag;
    }

    // ([RES] * [DAY] / ([DAY] + [DAY])) = [RES]
    // inrateBag / (daysToSettlement + 1)
    uint256 toPay = totalInrateInBag
      .mul(mocLibConfig.dayPrecision)
      .div(daysToSettl.add(mocLibConfig.dayPrecision));

    return toPay;
  }

  /**
    @dev Extract the inrate from the passed RBTC value for Bprox minting operation
    @param bucket Bucket to use to calculate interés
    @param rbtcAmount Total value from which extract the interest rate [using reservePrecision]
    @return RBTC to pay in concept of interests [using reservePrecision]
  */
  function calcMintInterestValues(bytes32 bucket, uint256 rbtcAmount) public view returns(uint256) {
    // Calculate Reserves to move in the operation
    uint256 rbtcToMove = mocLibConfig.bucketTransferAmount(rbtcAmount, mocState.leverage(bucket));
    // Calculate interest rate
    uint256 inrateValue = btcxInrateAvg(bucket, rbtcAmount, true); // Minting
    uint256 finalInrate = inrateToSettlement(inrateValue, true); // Minting

    // Final interest
    return mocLibConfig.getInterestCost(rbtcToMove, finalInrate);
  }

  /**
    @dev Extract the inrate from the passed RBTC value for the Doc Redeem operation
    @param docAmount Doc amount of the redemption [using mocPrecision]
    @param rbtcAmount Total value from which extract the interest rate [using reservePrecision]
    @return RBTC to pay in concept of interests [using reservePrecision]
  */
  function calcDocRedInterestValues(uint256 docAmount, uint256 rbtcAmount) public view returns(uint256) {
    uint256 rate = docInrateAvg(docAmount);
    uint256 finalInrate = inrateToSettlement(rate, true);
    uint256 interests = mocLibConfig.getInterestCost(rbtcAmount, finalInrate);

    return interests;
  }

  /**
    @dev This function calculates the interest to return to the user
    in a BPRox redemption. It uses a mechanism to counteract the effect
    of free docs redemption. It will be replaced with FreeDoC redemption
    interests in the future
    @param bucket Bucket to use to calculate interest
    @param rbtcToRedeem Total value from which calculate interest [using reservePrecision]
    @return RBTC to recover in concept of interests [using reservePrecision]
  */
  function calcFinalRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) public view returns(uint256) {
    // Get interests to return for redemption
    uint256 redeemInterest = calcRedeemInterestValue(bucket, rbtcToRedeem); // Redeem
    uint256 proportionalInterest = calcProportionalInterestValue(bucket, redeemInterest);

    return Math.min(proportionalInterest, redeemInterest);
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Public functions **/

  /**
    @dev calculates the Commission rate from the passed RBTC amount and the transaction type for mint/redeem operations
    @param rbtcAmount Total value from which apply the Commission rate [using reservePrecision]
    @param txType Transaction type according to constant values defined in this contract
    @return finalCommissionAmount [using reservePrecision]
  */
  function calcCommissionValue(uint256 rbtcAmount, uint8 txType)
  public view returns(uint256) {
    // Validate txType
    require (txType > 0, "Invalid txType");

    uint256 finalCommissionAmount = rbtcAmount.mul(commissionRatesByTxType[txType]).div(mocLibConfig.mocPrecision);
    return finalCommissionAmount;
  }

  /**
    @dev DEPRECATED calculates the Commission rate from the passed RBTC amount for mint/redeem operations
    @param rbtcAmount Total value from which apply the Commission rate [using reservePrecision]
    @return finalCommissionAmount [using reservePrecision]
  */
  function calcCommissionValue(uint256 rbtcAmount)
  external view returns(uint256) {
    // solium-disable-next-line mixedcase
    uint256 finalCommissionAmount = rbtcAmount.mul(commissionRatesByTxType[MINT_BPRO_FEES_RBTC]).div(mocLibConfig.mocPrecision);
    return finalCommissionAmount;
  }

  /**
    @dev calculates the vendor markup rate from the passed vendor account and amount
    @param vendorAccount Vendor address
    @param amount Total value from which apply the vendor markup rate [using reservePrecision]
    @return finalCommissionAmount [using reservePrecision]
  */
  function calculateVendorMarkup(address vendorAccount, uint256 amount) public view
    returns (uint256 markup) {
    // Calculate according to vendor markup
    if (vendorAccount != address(0)) {
      IMoCVendors mocVendors = IMoCVendors(mocState.getMoCVendors());

      markup = amount.mul(mocVendors.getMarkup(vendorAccount)).div(mocLibConfig.mocPrecision);
    }

    return markup;
  }

  /** END UPDATE V0112: 24/09/2020 **/

  /**
    @dev Calculates RBTC value to return to the user in concept of interests
    @param bucket Bucket to use to calculate interest
    @param rbtcToRedeem Total value from which calculate interest [using reservePrecision]
    @return RBTC to recover in concept of interests [using reservePrecision]
  */
  function calcRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) public view returns(uint256) {
    // Calculate Reserves to move in the operation
    uint256 rbtcToMove = mocLibConfig.bucketTransferAmount(rbtcToRedeem, mocState.leverage(bucket));
    // Calculate interest rate
    uint256 inrate = btcxInrateAvg(bucket, rbtcToRedeem, false); // Redeem
    uint256 finalInrate = inrateToSettlement(inrate, false); // Redeem

    // Calculate interest for the redemption
    return mocLibConfig.getInterestCost(rbtcToMove, finalInrate);
  }

  /**
    @dev Moves the daily amount of interest rate to C0 bucket
  */
  function dailyInratePayment() public
  onlyWhitelisted(msg.sender) onlyOnceADay() returns(uint256) {
    uint256 toPay = dailyInrate();
    lastDailyPayBlock = block.number;

    if (toPay != 0) {
      bproxManager.deliverInrate(BUCKET_C0, toPay);
    }

    emit InrateDailyPay(toPay, mocState.daysToSettlement(), mocState.getBucketNBTC(BUCKET_C0));
  }

  function isDailyEnabled() public view returns(bool) {
    return lastDailyPayBlock == 0 || block.number > lastDailyPayBlock + mocState.dayBlockSpan();
  }

  function isBitProInterestEnabled() public view returns(bool) {
    return lastBitProInterestBlock == 0 || block.number > (lastBitProInterestBlock + bitProInterestBlockSpan);
  }

  /**
   * @dev Calculates BitPro Holders interest rates
   * @return toPay interest in RBTC [using RBTCPrecsion]
   * @return bucketBtnc0 RTBC on bucket0 used to calculate de interest [using RBTCPrecsion]
   */
  function calculateBitProHoldersInterest() public view returns(uint256, uint256) {
    uint256 bucketBtnc0 = bproxManager.getBucketNBTC(BUCKET_C0);
    uint256 toPay = (bucketBtnc0.mul(bitProRate).div(mocLibConfig.mocPrecision));
    return (toPay, bucketBtnc0);
  }

  /**
   * @dev Pays the BitPro Holders interest rates
   * @return interest payed in RBTC [using RBTCPrecsion]
   */
  function payBitProHoldersInterestPayment() public
  onlyWhitelisted(msg.sender)
  onlyWhenBitProInterestsIsEnabled() returns(uint256) {
    (uint256 bitProInterest, uint256 bucketBtnc0) = calculateBitProHoldersInterest();
    lastBitProInterestBlock = block.number;
    emit RiskProHoldersInterestPay(bitProInterest, bucketBtnc0);
    return bitProInterest;
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Public functions **/
  /**
    @dev Sets the commission rate to a particular transaction type
    @param txType Transaction type according to constant values defined in this contract
    @param value Commission rate
  */
  function setCommissionRateByTxType(uint8 txType, uint256 value) public onlyAuthorizedChanger() {
    commissionRatesByTxType[txType] = value;
  }

  /** END UPDATE V0112: 24/09/2020 **/

  /**
    @dev Calculates the interest rate to pay until the settlement day
    @param inrate Spot interest rate
    @param countAllDays Value that represents if the calculation will use all days or one day less
    @return Interest rate value [using RatePrecsion]
   */
  function inrateToSettlement(uint256 inrate, bool countAllDays) internal view returns(uint256) {
    uint256 dayCount = inrateDayCount(countAllDays);

    return inrate.mul(dayCount).div(mocLibConfig.dayPrecision);
  }

  /**
    @dev This function calculates the interest to return to a user redeeming
    BTCx as a proportion of the amount in the interestBag.
    @param bucket Bucket to use to calculate interest
    @param redeemInterest Total value from which calculate interest [using reservePrecision]
    @return InterestsInBag * (RedeemInterests / FullRedeemInterest) [using reservePrecision]
  */
  function calcProportionalInterestValue(bytes32 bucket, uint256 redeemInterest) internal view returns(uint256) {
    uint256 fullRedeemInterest = calcFullRedeemInterestValue(bucket);
    uint256 interestsInBag = bproxManager.getInrateBag(BUCKET_C0);

    if (fullRedeemInterest == 0) {
      return 0;
    }

    // Proportional interests amount
    return redeemInterest.mul(interestsInBag).div(fullRedeemInterest); // [RES] * [RES] / [RES]
  }

  /**
    @dev This function calculates the interest to return if a user redeem all Btcx in existance
    @param bucket Bucket to use to calculate interest
    @return Interests [using reservePrecision]
  */
  function calcFullRedeemInterestValue(bytes32 bucket) internal view returns(uint256) {
    // Value in RBTC of all BProxs in the bucket
    uint256 fullBProxRbtcValue = mocState.bproxToBtc(bproxManager.getBucketNBPro(bucket), bucket);
    // Interests to return if a redemption of all Bprox is done
    return calcRedeemInterestValue(bucket, fullBProxRbtcValue); // Redeem
  }

  /**
    @dev Calculates the final amount of Bucket 0 DoCs on BProx mint/redeem
    @param bucket Name of the bucket involved in the operation
    @param btcAmount Value of the operation from which calculates the inrate [using reservePrecision]
    @return Final bucket 0 Doc amount
   */
  function simulateDocMovement(bytes32 bucket, uint256 btcAmount, bool onMinting) internal view returns(uint256) {
    // Calculates docs to move
    uint256 btcToMove = mocLibConfig.bucketTransferAmount(btcAmount, mocState.leverage(bucket));
    uint256 docsToMove = mocState.btcToDoc(btcToMove);

    if (onMinting) {
      /* Should not happen when minting bpro because it's
      not possible to mint more than max bprox but is
      useful when trying to calculate inrate before minting */
      return bproxManager.getBucketNDoc(BUCKET_C0) > docsToMove ? bproxManager.getBucketNDoc(BUCKET_C0).sub(docsToMove) : 0;
    } else {
      return bproxManager.getBucketNDoc(BUCKET_C0).add(Math.min(docsToMove, bproxManager.getBucketNDoc(bucket)));
    }
  }

  /**
    @dev Returns the days to use for interests calculation
    @param countAllDays Value that represents if the calculation is based on mint or on redeem
    @return days [using dayPrecision]
   */
  function inrateDayCount(bool countAllDays) internal view returns(uint256) {
    uint256 daysToSettl = mocState.daysToSettlement();

    if (daysToSettl < mocLibConfig.dayPrecision) {
      return 0;
    }

    if (countAllDays) {
      return daysToSettl;
    }

    return daysToSettl.sub(mocLibConfig.dayPrecision);
  }

  modifier onlyOnceADay() {
    require(isDailyEnabled(), "Interest rate already payed today");
    _;
  }

  modifier onlyWhenBitProInterestsIsEnabled() {
    require(isBitProInterestEnabled(), "Interest rate of BitPro holders already payed this week");
    _;
  }

  /**
   * @dev Initialize the contracts with which it interacts
   */
  function initializeContracts() internal {
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = IMoCState(connector.mocState());
  }

  /**
   * @dev Initialize the parameters of the contract
   * @param _governor the address of the IGovernor contract
   * @param btcxMin Minimum interest rate [using mocPrecision]
   * @param btcxPower Power is a parameter for interest rate calculation [using noPrecision]
   * @param btcxMax Maximun interest rate [using mocPrecision]
   * @param _bitProRate BitPro holder interest rate [using mocPrecision]
   * @param blockSpanBitPro BitPro blockspan to configure payments periods[using mocPrecision]
   * @param bitProInterestsTarget Target address to transfer the weekly BitPro holders interest
   */
  function initializeValues(
    address _governor,
    uint256 btcxMin,
    uint256 btcxPower,
    uint256 btcxMax,
    uint256 _bitProRate,
    address payable commissionsAddressTarget,
    //uint256 commissionRateParam,
    uint256 blockSpanBitPro,
    address payable bitProInterestsTarget,
    uint256 _docTmin,
    uint256 _docPower,
    uint256 _docTmax
  ) internal {
    governor = IGovernor(_governor);
    btcxParams.tMin = btcxMin;
    btcxParams.power = btcxPower;
    btcxParams.tMax = btcxMax;
    bitProRate = _bitProRate;
    bitProInterestAddress = bitProInterestsTarget;
    bitProInterestBlockSpan = blockSpanBitPro;
    //commissionRate = commissionRateParam;
    commissionsAddress = commissionsAddressTarget;
    docTmin = _docTmin;
    docPower = _docPower;
    docTmax = _docTmax;
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/

  // Transaction types
  uint8 public constant MINT_BPRO_FEES_RBTC = 1;
  uint8 public constant REDEEM_BPRO_FEES_RBTC = 2;
  uint8 public constant MINT_DOC_FEES_RBTC = 3;
  uint8 public constant REDEEM_DOC_FEES_RBTC = 4;
  uint8 public constant MINT_BTCX_FEES_RBTC = 5;
  uint8 public constant REDEEM_BTCX_FEES_RBTC = 6;
  uint8 public constant MINT_BPRO_FEES_MOC = 7;
  uint8 public constant REDEEM_BPRO_FEES_MOC = 8;
  uint8 public constant MINT_DOC_FEES_MOC = 9;
  uint8 public constant REDEEM_DOC_FEES_MOC = 10;
  uint8 public constant MINT_BTCX_FEES_MOC = 11;
  uint8 public constant REDEEM_BTCX_FEES_MOC = 12;

  mapping(uint8 => uint256) public commissionRatesByTxType;

  /** END UPDATE V0112: 24/09/2020 **/

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
