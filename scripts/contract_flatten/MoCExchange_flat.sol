// SPDX-License-Identifier: 
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

// File: contracts/interface/IMoC.sol

pragma solidity ^0.5.8;

interface IMoC {
    function() external payable;

    function sendToAddress(address payable receiver, uint256 btcAmount) external returns(bool);
}

// File: contracts/interface/IMoCExchange.sol

pragma solidity ^0.5.8;

interface IMoCExchange {
    function getMoCTokenBalance(address owner, address spender) external view
    returns (uint256 mocBalance, uint256 mocAllowance);

    function mintBPro(address account, uint256 btcAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemBPro(address account, uint256 bproAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function mintDoc(address account, uint256 btcToMint, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemBProx(address payable account, bytes32 bucket, uint256 bproxAmount, address vendorAccount)
    external returns (uint256, uint256, uint256, uint256, uint256);

    function mintBProx(address payable account, bytes32 bucket, uint256 btcToMint, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemFreeDoc(address account, uint256 docAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemAllDoc(address origin, address payable destination) external
    returns (uint256);

    function forceRedeemBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice)
    external returns (bool);

    function redeemDocWithPrice(address payable userAddress, uint256 amount, uint256 btcPrice) external
    returns (bool, uint256);
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

// File: contracts/MoCExchange.sol

pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;












contract MoCExchangeEvents {
  event RiskProMint(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice,
    uint256 btcMarkup,
    uint256 mocMarkup,
    address vendorAccount
  );
  event RiskProWithDiscountMint(
    uint256 riskProTecPrice,
    uint256 riskProDiscountPrice,
    uint256 amount
  );
  event RiskProRedeem(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice,
    uint256 btcMarkup,
    uint256 mocMarkup,
    address vendorAccount
  );
  event StableTokenMint(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice,
    uint256 btcMarkup,
    uint256 mocMarkup,
    address vendorAccount
  );
  event StableTokenRedeem(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice,
    uint256 btcMarkup,
    uint256 mocMarkup,
    address vendorAccount
  );
  event FreeStableTokenRedeem(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 interests,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice,
    uint256 btcMarkup,
    uint256 mocMarkup,
    address vendorAccount
  );

  event RiskProxMint(
    bytes32 bucket,
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 interests,
    uint256 leverage,
    uint256 commission,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice,
    uint256 btcMarkup,
    uint256 mocMarkup,
    address vendorAccount
  );

  event RiskProxRedeem(
    bytes32 bucket,
    address indexed account,
    uint256 commission,
    uint256 amount,
    uint256 reserveTotal,
    uint256 interests,
    uint256 leverage,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice,
    uint256 btcMarkup,
    uint256 mocMarkup,
    address vendorAccount
  );
}


contract MoCExchange is MoCExchangeEvents, MoCBase, MoCLibConnection, IMoCExchange {
  using Math for uint256;
  using SafeMath for uint256;

  // Contracts
  IMoCState internal mocState;
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  address internal DEPRECATED_mocConverter;
  MoCBProxManager internal bproxManager;
  BProToken internal bproToken;
  DocToken internal docToken;
  IMoCInrate internal mocInrate;
  IMoC internal moc;

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
  */
  function initialize(address connectorAddress) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Public functions **/

  /**
   @dev Converts MoC commission from RBTC to MoC price
   @param owner address of token owner
   @param spender address of token spender
   @return MoC balance of owner and MoC allowance of spender
  */
  function getMoCTokenBalance(address owner, address spender) public view
  returns (uint256 mocBalance, uint256 mocAllowance) {
    mocBalance = 0;
    mocAllowance = 0;

    MoCToken mocToken = MoCToken(mocState.getMoCToken());

    if (address(mocToken) != address(0)) {
      // Get balance and allowance from sender
      mocBalance = mocToken.balanceOf(owner);
      mocAllowance = mocToken.allowance(owner, spender);
    }

    return (mocBalance, mocAllowance);
  }

  /**
   @dev Calculates commissions in MoC and BTC
   @param params Params defined in CommissionParamsStruct
   @return Commissions calculated in MoC price and bitcoin price; and Bitcoin and MoC prices
  */
  function calculateCommissionsWithPrices(CommissionParamsStruct memory params)
  public view
  returns (CommissionReturnStruct memory ret) {
    ret.btcPrice = mocState.getBitcoinPrice();
    ret.mocPrice = mocState.getMoCPrice();
    require(ret.btcPrice > 0, "BTC price zero");
    require(ret.mocPrice > 0, "MoC price zero");
    // Calculate vendor markup
    uint256 btcMarkup = mocInrate.calculateVendorMarkup(params.vendorAccount, params.amount);

    // Get balance and allowance from sender
    (uint256 mocBalance, uint256 mocAllowance) = getMoCTokenBalance(params.account, address(moc));
    if (mocAllowance == 0 || mocBalance == 0) {
      // Check commission rate in RBTC according to transaction type
      ret.btcCommission = mocInrate.calcCommissionValue(params.amount, params.txTypeFeesRBTC);
      ret.btcMarkup = btcMarkup;
      return ret;
      // Implicitly mocCommission = 0 and mocMarkup = 0
    }

    // Check commission rate in MoC according to transaction type
    uint256 mocCommissionInBtc = mocInrate.calcCommissionValue(params.amount, params.txTypeFeesMOC);

    // Calculate amount in MoC
    ret.mocCommission = ret.btcPrice.mul(mocCommissionInBtc).div(ret.mocPrice);
    // Implicitly btcCommission = 0
    ret.mocMarkup = ret.btcPrice.mul(btcMarkup).div(ret.mocPrice);
    // Implicitly btcMarkup = 0

    uint256 totalMoCFee = ret.mocCommission.add(ret.mocMarkup);

    // Check if there is enough balance of MoC
    if ((!(mocBalance >= totalMoCFee && mocAllowance >= totalMoCFee)) || (mocCommissionInBtc == 0)) {
      // Insufficient funds
      ret.mocCommission = 0;
      ret.mocMarkup = 0;

      // Check commission rate in RBTC according to transaction type
      ret.btcCommission = mocInrate.calcCommissionValue(params.amount, params.txTypeFeesRBTC);
      ret.btcMarkup = btcMarkup;
    }

    return ret;
  }

  /**
  * @dev BTC equivalent for the amount of bpro given applying the spotDiscountRate
  * @param bproAmount amount of BPro [using mocPrecision]
  * @param bproTecPrice price of BPro without discounts [using mocPrecision]
  * @param bproDiscountRate BPro discounts [using mocPrecision]
  * @return BTC amount
  */
  function bproDiscToBtc(uint256 bproAmount, uint256 bproTecPrice, uint256 bproDiscountRate) internal view returns(uint256) {
    uint256 totalBtcValue = mocLibConfig.totalBProInBtc(bproAmount, bproTecPrice);
    return mocLibConfig.applyDiscountRate(totalBtcValue, bproDiscountRate);
  }

  /** END UPDATE V0112: 24/09/2020 **/

  /**
   @dev Mint BPros and give it to the msg.sender
   @param account Address of minter
   @param btcAmount Amount in BTC to mint
   @param vendorAccount Vendor address
  */
  function mintBPro(address account, uint256 btcAmount, address vendorAccount)
    external
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256, uint256, uint256)
  {
    RiskProMintStruct memory details;

    details.bproRegularPrice = mocState.bproTecPrice();
    details.finalBProAmount = 0;
    details.btcValue = 0;

    if (mocState.state() == IMoCState.States.BProDiscount) {
      details.discountPrice = mocState.bproDiscountPrice();
      details.bproDiscountAmount = mocLibConfig.maxBProWithBtc(btcAmount, details.discountPrice);

      details.finalBProAmount = Math.min(
        details.bproDiscountAmount,
        mocState.maxBProWithDiscount()
      );
      details.btcValue = details.finalBProAmount == details.bproDiscountAmount
        ? btcAmount
        // Converts BTC to BPro with discount up to the discount limit
        : bproDiscToBtc(
          details.finalBProAmount,
          details.bproRegularPrice,
          mocState.bproSpotDiscountRate()
        );

      emit RiskProWithDiscountMint(
        details.bproRegularPrice,
        details.discountPrice,
        details.finalBProAmount
      );
    }

    if (btcAmount != details.btcValue) {
      // Converts BTC to BPro
      details.regularBProAmount = mocLibConfig.maxBProWithBtc(
        btcAmount.sub(details.btcValue),
        details.bproRegularPrice
      );
      details.finalBProAmount = details.finalBProAmount.add(details.regularBProAmount);
    }

    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    CommissionParamsStruct memory params;
    params.account = account;
    params.amount = btcAmount;
    params.txTypeFeesMOC = mocInrate.MINT_BPRO_FEES_MOC();
    params.txTypeFeesRBTC = mocInrate.MINT_BPRO_FEES_RBTC();
    params.vendorAccount = vendorAccount;

    (details.commission) = calculateCommissionsWithPrices(params);

    mintBProInternal(account, btcAmount, details, vendorAccount);

    return (
      btcAmount,
      details.commission.btcCommission,
      details.commission.mocCommission,
      details.commission.btcMarkup,
      details.commission.mocMarkup
    );
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
   @dev Sender burns his BProS and redeems the equivalent BTCs
   @param account Address of the redeeemer
   @param bproAmount Amount of BPros to be redeemed
   @param vendorAccount Vendor address
   @return bitcoins to transfer to the redeemer and commission spent (in BTC and MoC), using [using reservePrecision]
  */
  function redeemBPro(address account, uint256 bproAmount, address vendorAccount)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256, uint256, uint256)
  {
    RiskProRedeemStruct memory details;

    uint256 userBalance = bproToken.balanceOf(account);
    uint256 userAmount = Math.min(bproAmount, userBalance);

    details.bproFinalAmount = Math.min(userAmount, mocState.absoluteMaxBPro());
    uint256 totalBtc = mocLibConfig.totalBProInBtc(details.bproFinalAmount, mocState.bproTecPrice());

    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    CommissionParamsStruct memory params;
    params.account = account;
    params.amount = totalBtc;
    params.txTypeFeesMOC = mocInrate.REDEEM_BPRO_FEES_MOC();
    params.txTypeFeesRBTC = mocInrate.REDEEM_BPRO_FEES_RBTC();
    params.vendorAccount = vendorAccount;

    (details.commission) = calculateCommissionsWithPrices(params);
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/

    // Mint token
    bproToken.burn(account, details.bproFinalAmount);

    // Update Buckets
    bproxManager.substractValuesFromBucket(
      BUCKET_C0,
      totalBtc,
      0,
      details.bproFinalAmount
    );

    details.btcTotalWithoutCommission = totalBtc.sub(details.commission.btcCommission).sub(details.commission.btcMarkup);

    redeemBProInternal(account, details, vendorAccount);

    return (
      details.btcTotalWithoutCommission,
      details.commission.btcCommission,
      details.commission.mocCommission,
      details.commission.btcMarkup,
      details.commission.mocMarkup
    );
  }

  /**
   @dev Redeems the requested amount for the account, or the max amount of free docs possible.
   @param account Address of the redeeemer
   @param docAmount Amount of Docs to redeem [using mocPrecision]
   @param vendorAccount Vendor address
   @return bitcoins to transfer to the redeemer and commission spent (in BTC and MoC), using [using reservePrecision]
  */
  function redeemFreeDoc(address account, uint256 docAmount, address vendorAccount)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256, uint256, uint256)
  {
    if (docAmount <= 0) {
      return (0, 0, 0, 0, 0);
    } else {
      FreeStableTokenRedeemStruct memory details;
      details.finalDocAmount = Math.min(
        docAmount,
        Math.min(mocState.freeDoc(), docToken.balanceOf(account))
      );
      uint256 docsBtcValue = mocState.docsToBtc(details.finalDocAmount);

      details.btcInterestAmount = mocInrate.calcDocRedInterestValues(
        details.finalDocAmount,
        docsBtcValue
      );
      details.finalBtcAmount = docsBtcValue.sub(details.btcInterestAmount);

      /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
      CommissionParamsStruct memory params;
      params.account = account;
      params.amount = details.finalBtcAmount;
      params.txTypeFeesMOC = mocInrate.REDEEM_DOC_FEES_MOC();
      params.txTypeFeesRBTC = mocInrate.REDEEM_DOC_FEES_RBTC();
      params.vendorAccount = vendorAccount;

      (details.commission) = calculateCommissionsWithPrices(params);

      /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/

      doDocRedeem(account, details.finalDocAmount, docsBtcValue);
      bproxManager.payInrate(BUCKET_C0, details.btcInterestAmount);

      redeemFreeDocInternal(account, details, vendorAccount);

      return (details.finalBtcAmount.sub(details.commission.btcCommission).sub(details.commission.btcMarkup), details.commission.btcCommission, details.commission.mocCommission, details.commission.btcMarkup, details.commission.mocMarkup);
    }
  }

  /**
   @dev Mint Max amount of Docs and give it to the msg.sender
   @param account minter user address
   @param btcToMint btc amount the user intents to convert to DoC [using rbtPresicion]
   @param vendorAccount Vendor address
   @return the actual amount of btc used and the btc commission (in BTC and MoC) for them [using rbtPresicion]
  */
  function mintDoc(address account, uint256 btcToMint, address vendorAccount)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256, uint256, uint256)
  {
    StableTokenMintStruct memory details;

    // Docs to issue with tx value amount
    if (btcToMint > 0) {
      uint256 btcPrice = mocState.getBitcoinPrice();
      details.docs = mocLibConfig.maxDocsWithBtc(btcToMint, btcPrice); //btc to doc
      details.docAmount = Math.min(details.docs, mocState.absoluteMaxDoc());
      details.totalCost = details.docAmount == details.docs
        ? btcToMint
        : mocLibConfig.docsBtcValue(details.docAmount, mocState.peg(), btcPrice); //docs to btc

      // Mint Token
      docToken.mint(account, details.docAmount);

      // Update Buckets
      bproxManager.addValuesToBucket(BUCKET_C0, details.totalCost, details.docAmount, 0);

      /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
      CommissionParamsStruct memory params;
      params.account = account;
      params.amount = details.totalCost;
      params.txTypeFeesMOC = mocInrate.MINT_DOC_FEES_MOC();
      params.txTypeFeesRBTC = mocInrate.MINT_DOC_FEES_RBTC();
      params.vendorAccount = vendorAccount;

      (details.commission) = calculateCommissionsWithPrices(params);

      mintDocInternal(account, details, vendorAccount);

      /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/

      return (details.totalCost, details.commission.btcCommission, details.commission.mocCommission, details.commission.btcMarkup, details.commission.mocMarkup);
    }

    return (0, 0, 0, 0, 0);
  }

  /**
   @dev User DoCs get burned and he receives the equivalent BTCs in return
   @param userAddress Address of the user asking to redeem
   @param amount Verified amount of Docs to be redeemed [using mocPrecision]
   @param btcPrice bitcoin price [using mocPrecision]
   @return true and commission spent (in BTC and MoC) if btc send was completed, false if fails.
  */
  function redeemDocWithPrice(
    address payable userAddress,
    uint256 amount,
    uint256 btcPrice
  ) public onlyWhitelisted(msg.sender) returns (bool, uint256) {
    StableTokenRedeemStruct memory details;

    details.totalBtc = mocLibConfig.docsBtcValue(amount, mocState.peg(), btcPrice); //doc to btc

    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Check commission rate in RBTC according to transaction type
    details.commission.btcCommission = mocInrate.calcCommissionValue(details.totalBtc, mocInrate.REDEEM_DOC_FEES_RBTC());
    details.commission.btcMarkup = 0;
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/

    details.btcToRedeem = details.totalBtc.sub(details.commission.btcCommission).sub(details.commission.btcMarkup);

    bool result = moc.sendToAddress(userAddress, details.btcToRedeem);

    details.reserveTotal = details.totalBtc.sub(details.commission.btcCommission).sub(details.commission.btcMarkup);
    details.commission.btcPrice = btcPrice;
    details.commission.mocCommission = 0;
    details.commission.mocPrice = 0;
    details.commission.mocMarkup = 0;

    // If sends fail, then no redemption is executed
    if (result) {
      doDocRedeem(userAddress, amount, details.totalBtc);
      redeemDocWithPriceInternal(userAddress, amount, details, address(0));
    }

    return (result, details.commission.btcCommission);
  }

  /**
   @dev Allow redeem on liquidation state, user DoCs get burned and he receives
   the equivalent RBTCs according to liquidationPrice
   @param origin address owner of the DoCs
   @param destination address to send the RBTC
   @return The amount of RBTC in sent for the redemption or 0 if send does not succed
  */
  function redeemAllDoc(address origin, address payable destination)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256)
  {
    uint256 userDocBalance = docToken.balanceOf(origin);
    if (userDocBalance == 0) return 0;

    uint256 liqPrice = mocState.getLiquidationPrice();
    // [USD * RBTC / USD]
    uint256 totalRbtc = mocLibConfig.docsBtcValue(userDocBalance, mocState.peg(), liqPrice); //docs to btc

    // If send fails we don't burn the tokens
    if (moc.sendToAddress(destination, totalRbtc)) {
      docToken.burn(origin, userDocBalance);
      emit StableTokenRedeem(
        origin,
        userDocBalance,
        totalRbtc,
        0,
        liqPrice,
        0,
        0,
        0,
        0,
        address(0)
      );

      return totalRbtc;
    } else {
      return 0;
    }
  }

  /**
   @dev BUCKET Bprox minting. Mints Bprox for the specified bucket
   @param account owner of the new minted Bprox
   @param bucket bucket name
   @param btcToMint rbtc amount to mint [using reservePrecision]
   @param vendorAccount Vendor address
   @return total RBTC Spent (btcToMint more interest) and commission spent (in BTC and MoC) [using reservePrecision]
  */
  function mintBProx(address payable account, bytes32 bucket, uint256 btcToMint, address vendorAccount)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256, uint256, uint256)
  {
    if (btcToMint > 0) {
      RiskProxMintStruct memory details;

      details.lev = mocState.leverage(bucket);

      details.finalBtcToMint = Math.min(
        btcToMint,
        mocState.maxBProxBtcValue(bucket)
      );

      // Get interest and the adjusted BProAmount
      details.btcInterestAmount = mocInrate.calcMintInterestValues(
        bucket,
        details.finalBtcToMint
      );

      // pay interest
      bproxManager.payInrate(BUCKET_C0, details.btcInterestAmount);

      details.bproxToMint = mocState.btcToBProx(details.finalBtcToMint, bucket);

      bproxManager.assignBProx(bucket, account, details.bproxToMint, details.finalBtcToMint);
      moveExtraFundsToBucket(BUCKET_C0, bucket, details.finalBtcToMint, details.lev);

      // Calculate leverage after mint
      details.lev = mocState.leverage(bucket);

      /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
      CommissionParamsStruct memory params;
      params.account = account;
      params.amount = details.finalBtcToMint;
      params.txTypeFeesMOC = mocInrate.MINT_BTCX_FEES_MOC();
      params.txTypeFeesRBTC = mocInrate.MINT_BTCX_FEES_RBTC();
      params.vendorAccount = vendorAccount;

      (details.commission) = calculateCommissionsWithPrices(params);

      mintBProxInternal(account, bucket, details, vendorAccount);
      /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/

      return (details.finalBtcToMint.add(details.btcInterestAmount), details.commission.btcCommission, details.commission.mocCommission, details.commission.btcMarkup, details.commission.mocMarkup);
    }

    return (0, 0, 0, 0, 0);
  }

  /**
   @dev Sender burns his BProx, redeems the equivalent amount of BPros, return
   the "borrowed" DOCs and recover pending interests
   @param account user address to redeem bprox from
   @param bucket Bucket where the BProxs are hold
   @param bproxAmount Amount of BProxs to be redeemed [using mocPrecision]
   @param vendorAccount Vendor address
   @return the actual amount of btc to redeem and the btc commission (in BTC and MoC) for them [using reservePrecision]
  */
  function redeemBProx(
    address payable account,
    bytes32 bucket,
    uint256 bproxAmount,
    address vendorAccount
  ) public onlyWhitelisted(msg.sender) returns (uint256, uint256, uint256, uint256, uint256) {
    // Revert could cause not evaluating state changing
    if (bproxManager.bproxBalanceOf(bucket, account) == 0) {
      return (0, 0, 0, 0, 0);
    }
    RiskProxRedeemStruct memory details;
    details.bproxPrice = mocState.bucketBProTecPrice(bucket);
    // Calculate leverage before the redeem
    details.bucketLev = mocState.leverage(bucket);
    // Get redeemable value
    details.bproxToRedeem = Math.min(bproxAmount, bproxManager.bproxBalanceOf(bucket, account));
    details.rbtcToRedeem = mocLibConfig.bproBtcValue(details.bproxToRedeem, details.bproxPrice);
    // Pay interests
    // Update 2020-03-31
    // No recover interest in BTCX Redemption
    // details.rbtcInterests = recoverInterests(bucket, details.rbtcToRedeem);
    details.rbtcInterests = 0;

    // Burn Bprox
    burnBProxFor(
      bucket,
      account,
      details.bproxToRedeem,
      details.bproxPrice
    );

    if (bproxManager.getBucketNBPro(bucket) == 0) {
      // If there is no BProx left, empty bucket for rounding remnant
      bproxManager.emptyBucket(bucket, BUCKET_C0);
    } else {
      // Move extra value from L bucket to C0
      moveExtraFundsToBucket(bucket, BUCKET_C0, details.rbtcToRedeem, details.bucketLev);
    }

    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    CommissionParamsStruct memory params;
    params.account = account;
    params.amount = details.rbtcToRedeem;
    params.txTypeFeesMOC = mocInrate.REDEEM_BTCX_FEES_MOC();
    params.txTypeFeesRBTC = mocInrate.REDEEM_BTCX_FEES_RBTC();
    params.vendorAccount = vendorAccount;

    (details.commission) = calculateCommissionsWithPrices(params);

    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/

    details.btcTotalWithoutCommission = details.rbtcToRedeem.sub(details.commission.btcCommission).sub(details.commission.btcMarkup);
    details.totalBtcRedeemed = details.btcTotalWithoutCommission.add(details.rbtcInterests);

    redeemBProxInternal(account, bucket, bproxAmount, details, vendorAccount);

    return (
      details.totalBtcRedeemed,
      details.commission.btcCommission,
      details.commission.mocCommission,
      details.commission.btcMarkup,
      details.commission.mocMarkup
    );
  }

  /**
    @dev Burns user BProx and sends the equivalent amount of RBTC
    to the account without caring if transaction succeeds
    @param bucket Bucket where the BProxs are hold
    @param account user address to redeem bprox from
    @param bproxAmount Amount of BProx to redeem [using mocPrecision]
    @param bproxPrice Price of one BProx in RBTC [using reservePrecision]
    @return result of the RBTC sending transaction [using reservePrecision]
  */
  function forceRedeemBProx(
    bytes32 bucket,
    address payable account,
    uint256 bproxAmount,
    uint256 bproxPrice
  ) public onlyWhitelisted(msg.sender) returns (bool) {
    // Do burning part of the redemption
    uint256 btcTotalAmount = burnBProxFor(
      bucket,
      account,
      bproxAmount,
      bproxPrice
    );

    // Send transaction can only fail for external code
    // if transaction fails, user will lost his RBTC and BProx
    return moc.sendToAddress(account, btcTotalAmount);
  }

  /**
    @dev Burns user BProx
    @param bucket Bucket where the BProxs are hold
    @param account user address to redeem bprox from
    @param bproxAmount Amount of BProx to redeem [using mocPrecision]
    @param bproxPrice Price of one BProx in RBTC [using reservePrecision]
    @return Bitcoin total value of the redemption [using reservePrecision]
  */
  function burnBProxFor(
    bytes32 bucket,
    address payable account,
    uint256 bproxAmount,
    uint256 bproxPrice
  ) public onlyWhitelisted(msg.sender) returns (uint256) {
    // Calculate total RBTC
    uint256 btcTotalAmount = mocLibConfig.bproBtcValue(
      bproxAmount,
      bproxPrice
    );
    bproxManager.removeBProx(bucket, account, bproxAmount, btcTotalAmount);

    return btcTotalAmount;
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Internal functions **/

  /**
   @dev Internal function to avoid stack too deep errors
  */
  function redeemBProxInternal(
    address account,
    bytes32 bucket,
    uint256 bproxAmount,
    RiskProxRedeemStruct memory details,
    address vendorAccount
  ) internal {
    emit RiskProxRedeem(
      bucket,
      account,
      details.commission.btcCommission,
      bproxAmount,
      details.btcTotalWithoutCommission,
      details.rbtcInterests,
      details.bucketLev,
      details.commission.btcPrice,
      details.commission.mocCommission,
      details.commission.mocPrice,
      details.commission.btcMarkup,
      details.commission.mocMarkup,
      vendorAccount
    );
  }

  /**
   @dev Internal function to avoid stack too deep errors
  */
  function mintBProInternal(address account, uint256 btcAmount, RiskProMintStruct memory details, address vendorAccount) internal {
    bproToken.mint(account, details.finalBProAmount);
    bproxManager.addValuesToBucket(BUCKET_C0, btcAmount, 0, details.finalBProAmount);

    emit RiskProMint(
      account,
      details.finalBProAmount,
      btcAmount,
      details.commission.btcCommission,
      details.commission.btcPrice,
      details.commission.mocCommission,
      details.commission.mocPrice,
      details.commission.btcMarkup,
      details.commission.mocMarkup,
      vendorAccount
    );
  }

  /**
   @dev Internal function to avoid stack too deep errors
  */
  function mintBProxInternal(address account, bytes32 bucket, RiskProxMintStruct memory details, address vendorAccount) internal {
    emit RiskProxMint(
      bucket,
      account,
      details.bproxToMint,
      details.finalBtcToMint,
      details.btcInterestAmount,
      details.lev,
      details.commission.btcCommission,
      details.commission.btcPrice,
      details.commission.mocCommission,
      details.commission.mocPrice,
      details.commission.btcMarkup,
      details.commission.mocMarkup,
      vendorAccount
    );
  }

  /**
   @dev Internal function to avoid stack too deep errors
  */
  function mintDocInternal(address account, StableTokenMintStruct memory details, address vendorAccount) internal {
    emit StableTokenMint(
      account,
      details.docAmount,
      details.totalCost,
      details.commission.btcCommission,
      details.commission.btcPrice,
      details.commission.mocCommission,
      details.commission.mocPrice,
      details.commission.btcMarkup,
      details.commission.mocMarkup,
      vendorAccount
    );
  }

  /**
   @dev Internal function to avoid stack too deep errors
  */
  function redeemFreeDocInternal(address account, FreeStableTokenRedeemStruct memory details, address vendorAccount) internal {
    emit FreeStableTokenRedeem(
      account,
      details.finalDocAmount,
      details.finalBtcAmount,
      details.commission.btcCommission,
      details.btcInterestAmount,
      details.commission.btcPrice,
      details.commission.mocCommission,
      details.commission.mocPrice,
      details.commission.btcMarkup,
      details.commission.mocMarkup,
      vendorAccount
    );
  }

  /**
   @dev Internal function to avoid stack too deep errors
  */
  function redeemBProInternal(address account, RiskProRedeemStruct memory details, address vendorAccount) internal {
    emit RiskProRedeem(
      account,
      details.bproFinalAmount,
      details.btcTotalWithoutCommission,
      details.commission.btcCommission,
      details.commission.btcPrice,
      details.commission.mocCommission,
      details.commission.mocPrice,
      details.commission.btcMarkup,
      details.commission.mocMarkup,
      vendorAccount
    );
  }

  /**
   @dev Internal function to avoid stack too deep errors
  */
  function redeemDocWithPriceInternal(address account, uint256 amount, StableTokenRedeemStruct memory details, address vendorAccount) internal {
    emit StableTokenRedeem(
      account, //userAddress,
      amount,
      details.reserveTotal,
      details.commission.btcCommission,
      details.commission.btcPrice,
      details.commission.mocCommission,
      details.commission.mocPrice,
      details.commission.btcMarkup,
      details.commission.mocMarkup,
      vendorAccount
    );
  }

  /** END UPDATE V0112: 24/09/2020 **/

  /**
    @dev Calculates the amount of RBTC that one bucket should move to another in
    BProx minting/redemption. This extra makes BProx more leveraging than BPro.
    @param bucketFrom Origin bucket from which the BTC are moving
    @param bucketTo Destination bucket to which the BTC are moving
    @param totalBtc Amount of BTC moving between buckets [using reservePrecision]
    @param lev lev of the L bucket [using mocPrecision]
  */
  function moveExtraFundsToBucket(
    bytes32 bucketFrom,
    bytes32 bucketTo,
    uint256 totalBtc,
    uint256 lev
  ) internal {
    uint256 btcToMove = mocLibConfig.bucketTransferAmount(totalBtc, lev);
    uint256 docsToMove = mocState.btcToDoc(btcToMove);

    uint256 btcToMoveFinal = Math.min(
      btcToMove,
      bproxManager.getBucketNBTC(bucketFrom)
    );
    uint256 docsToMoveFinal = Math.min(
      docsToMove,
      bproxManager.getBucketNDoc(bucketFrom)
    );

    bproxManager.moveBtcAndDocs(
      bucketFrom,
      bucketTo,
      btcToMoveFinal,
      docsToMoveFinal
    );
  }

  /**
   @dev Returns RBTCs for user in concept of interests refund
   @param bucket Bucket where the BProxs are hold
   @param rbtcToRedeem Total RBTC value of the redemption [using reservePrecision]
   @return Interests [using reservePrecision]
  */
  function recoverInterests(bytes32 bucket, uint256 rbtcToRedeem)
    internal
    returns (uint256)
  {
    uint256 rbtcInterests = mocInrate.calcFinalRedeemInterestValue(
      bucket,
      rbtcToRedeem
    );

    return bproxManager.recoverInrate(BUCKET_C0, rbtcInterests);
  }

  function doDocRedeem(address userAddress, uint256 docAmount, uint256 totalBtc)
    internal
  {
    docToken.burn(userAddress, docAmount);
    bproxManager.substractValuesFromBucket(BUCKET_C0, totalBtc, docAmount, 0);
  }

  function initializeContracts() internal {
    moc = IMoC(connector.moc());
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = IMoCState(connector.mocState());
    mocInrate = IMoCInrate(connector.mocInrate());
  }


  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Structs **/

  struct RiskProxRedeemStruct{
    uint256 totalBtcRedeemed;
    uint256 btcTotalWithoutCommission;
    uint256 rbtcInterests;
    uint256 bucketLev;
    uint256 bproxToRedeem;
    uint256 rbtcToRedeem;
    uint256 bproxPrice;
    CommissionReturnStruct commission;
  }

  struct RiskProxMintStruct{
    uint256 bproxToMint;
    uint256 finalBtcToMint;
    uint256 btcInterestAmount;
    uint256 lev;
    CommissionReturnStruct commission;
  }

  struct RiskProRedeemStruct{
    uint256 bproFinalAmount;
    uint256 btcTotalWithoutCommission;
    CommissionReturnStruct commission;
  }

  struct FreeStableTokenRedeemStruct{
    uint256 finalDocAmount;
    uint256 finalBtcAmount;
    uint256 btcInterestAmount;
    CommissionReturnStruct commission;
  }

  struct RiskProMintStruct{
    uint256 bproRegularPrice;
    uint256 btcValue;
    uint256 discountPrice;
    uint256 bproDiscountAmount;
    uint256 regularBProAmount;
    uint256 availableBPro;
    uint256 finalBProAmount;
    CommissionReturnStruct commission;
  }

  struct StableTokenMintStruct{
    uint256 docs;
    uint256 docAmount;
    uint256 totalCost;
    CommissionReturnStruct commission;
  }

  struct CommissionParamsStruct{
    address account; // Address of the user doing the transaction
    uint256 amount; // Amount from which commissions are calculated
    uint8 txTypeFeesMOC; // Transaction type if fees are paid in MoC
    uint8 txTypeFeesRBTC; // Transaction type if fees are paid in RBTC
    address vendorAccount; // Vendor address
  }

  struct CommissionReturnStruct{
    uint256 btcCommission;
    uint256 mocCommission;
    uint256 btcPrice;
    uint256 mocPrice;
    uint256 btcMarkup;
    uint256 mocMarkup;
  }

  struct StableTokenRedeemStruct{
    uint256 reserveTotal;
    uint256 btcToRedeem;
    uint256 totalBtc;
    CommissionReturnStruct commission;
  }

  /** END UPDATE V0112: 24/09/2020 **/

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
