pragma solidity 0.5.8;

import "zos-lib/contracts/Initializable.sol";

import "../../contracts/MoCLibConnection.sol";

contract MoCHelperLibHarness is MoCLibConnection, Initializable {
  function initialize() public initializer {
    initializePrecisions();
  }

  /**
    Calculates average interest using integral function

    @dev T =  Rate = a * (x ** b) + c
    @param tMax maxInterestRate [using mocPrecision]
    @param power factor [using noPrecision]
    @param tMin minInterestRate C0 doc amount [using mocPrecision]
    @param abRat1 initial abundance ratio [using mocPrecision]
    @param abRat2 final abundance ratio [using mocPrecision]
    @return average interest rate [using mocPrecision]
  */
  function inrateAvg(uint256 tMax, uint256 power, uint256 tMin, uint256 abRat1, uint256 abRat2)
  public view returns(uint256) {
    return mocLibConfig.inrateAvg(tMax, power, tMin, abRat1, abRat2);
  }

  /**
    Calculates spot interest rate that BProx owners should pay to BPro owners

    @dev Rate = tMax * (abRatio ** power) + tMin
    @param tMin min interest rate [using mocPrecision]
    @param power power to use in the formula [using NoPrecision]
    @param tMax max interest rate [using mocPrecision]
    @param abRatio bucket C0  abundance Ratio [using mocPrecision]

   */
  function spotInrate(uint256 tMax, uint256 power, uint256 tMin, uint256 abRatio) public view returns(uint256) {
    return mocLibConfig.spotInrate(tMax, power, tMin, abRatio);
  }

  /**
    Calculates potential interests function with given parameters

    @dev Rate = a * (x ** b) + c
    @param a maxInterestRate [using mocPrecision]
    @param b factor [using NoPrecision]
    @param c minInterestRate C0 doc amount [using mocPrecision]
    @param value global doc amount [using mocPrecision]
  */
  function potential(uint256 a, uint256 b, uint256 c, uint256 value)
  public view returns(uint256) {
    return mocLibConfig.potential(a, b, c, value);
  }

  /**
    Calculates average of the integral function

    @dev T = (
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
  function avgInt(uint256 a, uint256 b, uint256 c, uint256 value1, uint256 value2)
  public view returns(uint256) {
    return mocLibConfig.avgInt(a, b, c, value1, value2);
  }

  /**
    Calculates integral of the exponential function

    @dev T = c * (value) + (a * value ** (b + 1)) / (b + 1))
    @param a maxInterestRate [using mocPrecision]
    @param b factor [using NoPrecision]
    @param c minInterestRate C0 doc amount [using mocPrecision]
    @param value value to put in the function [using mocPrecision]
    @return integration result [using mocPrecision]

   */
  function integral(uint256 a, uint256 b, uint256 c, uint256 value)
  public view returns(uint256) {
    return mocLibConfig.integral(a, b, c, value);
  }

  /**
  * @dev Relation between docs in bucket 0 and Doc total supply
  * @param doc0 doc count in bucket 0 [using mocPrecision]
  * @param doct total doc supply [using mocPrecision]
  * @return abundance ratio [using mocPrecision]
  */
  function abundanceRatio(uint256 doc0, uint256 doct)
  public view returns(uint256) {
    return mocLibConfig.abundanceRatio(doc0, doct);
  }

  /**
    SpotDiscountRate = TPD * (utpdu - cob) / (uptdu -liq)

    @dev Returns the Ratio to apply to BPro Price in discount situations
    @param bproLiqDiscountRate Discount rate applied at Liquidation level coverage [using mocPrecision]
    @param liq Liquidation coverage threshold [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param cov Actual global Coverage threshold [using mocPrecision]
    @return Spot discount rate [using mocPrecision]
  **/
  function bproSpotDiscountRate(uint256 bproLiqDiscountRate, uint256 liq, uint256 utpdu, uint256 cov) public view returns(uint256) {
    return mocLibConfig.bproSpotDiscountRate(bproLiqDiscountRate, liq, utpdu, cov);
  }

  /**
    MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)

    @dev Max amount of BPro to available with discount
    @param nB Total BTC amount [using reservePrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bproUsdPrice bproUsdPrice [using mocPrecision]
    @param spotDiscount spot discount [using mocPrecision]
    @return Total BPro amount [using mocPrecision]
  **/
  function maxBProWithDiscount(
    uint256 nB, uint256 nDoc, uint256 utpdu,
    uint256 peg, uint256 btcPrice, uint256 bproUsdPrice, uint256 spotDiscount
  )
  public view returns(uint256)  {
    return mocLibConfig.maxBProWithDiscount(
      nB, nDoc, utpdu, peg, btcPrice, bproUsdPrice, spotDiscount
    );
  }

  /**

    @dev Calculates Locked bitcoin
    @param btcPrice BTC price [using mocPrecision]
    @param nDoc Docs amount [using mocPrecision]
    @param peg peg value
    @return Locked bitcoin [using reservePrecision]
  **/
  function lockedBitcoin(uint256 btcPrice, uint256 nDoc, uint256 peg)
  public view returns(uint256) {
    return mocLibConfig.lockedBitcoin(btcPrice, nDoc, peg);
  }

  /**
    @dev Calculates price at liquidation event as a relation between the doc total supply
    and the amount of RBTC available to distribute
    @param rbtcAmount RBTC to distribute [using reservePrecision]
    @param nDoc Docs amount [using mocPrecision]
    @return Price at liquidation event [using mocPrecision]
  **/
  function liquidationPrice(uint256 rbtcAmount, uint256 nDoc)
  public view returns(uint256) {
    return mocLibConfig.liquidationPrice(rbtcAmount, nDoc);
  }

  /**
   TPbtc = (nB-LB) / nTP

    @dev Calculates BPro BTC price
    @param nB Total BTC amount [using reservePrecision]
    @param lb Locked bitcoins amount [using reservePrecision]
    @param nTP BPro amount [using mocPrecision]
    @return BPro BTC price [using reservePrecision]
  **/
  function bproTecPrice(uint256 nB, uint256 lb, uint256 nTP)
  public view returns(uint256) {
    return mocLibConfig.bproTecPrice(nB, lb, nTP);
  }

  /**
   BProxInBPro = bproxTecPrice / bproPrice

    @dev Calculates BPro BTC price
    @param bproxTecPrice BProx BTC price [using reservePrecision]
    @param bproPrice Trog BTC price [using reservePrecision]
    @return BProx price in BPro [using mocPrecision]
  **/
  function bproxBProPrice(uint256 bproxTecPrice, uint256 bproPrice)
  public view returns(uint256) {
    return mocLibConfig.bproxBProPrice(bproxTecPrice, bproPrice);
  }

  /**
   TPbtc = (price)* (1 - discountRate)

    @dev Returns a new value with the discountRate applied
    @param price Price [using SomePrecision]
    @param discountRate Discount rate to apply [using mocPrecision]
    @return Price with discount applied [using SomePrecision]
  **/
  function applyDiscountRate(uint256 price, uint256 discountRate)
  public view returns(uint256) {
    return applyDiscountRate(price, discountRate);
  }

  /**
   TPbtc = price * interestRate

    @dev Returns the amount of interest to pay
    @param value Cost to apply interest [using SomePrecision]
    @param interestRate Interest rate to apply [using mocPrecision]
    @return Interest cost based on the value and interestRate [using SomePrecision]
  **/
  function getInterestCost(uint256 value, uint256 interestRate)
  public view returns(uint256) {
    return mocLibConfig.getInterestCost(value, interestRate);
  }

  /**
    Coverage = nB / LB

    @dev Calculates Coverage
    @param nB Total BTC amount [using reservePrecision]
    @param lB Locked bitcoins amount [using reservePrecision]
    @return Coverage [using mocPrecision]
  **/
  function coverage(uint256 nB, uint256 lB)
  public view returns(uint256) {
    return mocLibConfig.coverage(nB, lB);
  }

 /**
  Leverage = C / (C - 1)

    @dev Calculates Leverage
    @param cov Coverage [using mocPrecision]
    @return Leverage [using mocPrecision]
  **/
  function leverageFromCoverage(uint256 cov)
  public view returns(uint256) {
    return mocLibConfig.leverageFromCoverage(cov);
  }

 /**
  Leverage = nB / (nB - lB)

    @dev Calculates Leverage
    @param nB Total BTC amount [using reservePrecision]
    @param lB Locked bitcoins amount [using reservePrecision]
    @return Leverage [using mocPrecision]
  **/
  function leverage(uint256 nB, uint256 lB)
  public view returns(uint256) {
    return mocLibConfig.leverage(nB, lB);
  }

  /**
    @dev Price in BTC of the amount of Docs
    @param amount Total BTC amount [using reservePrecision]
    @param btcPrice BTC price [using mocPrecision]
    @return Total value [using reservePrecision]
  **/
  function docsBtcValue(uint256 amount,uint256 peg, uint256 btcPrice)
  public view returns(uint256) {
    return docsBtcValue(amount, peg, btcPrice);
  }

 /**
    @dev Price in RBTC of the amount of BPros
    @param bproAmount amount of BPro [using mocPrecision]
    @param bproBtcPrice BPro price in RBTC [using reservePrecision]
    @return Total value [using reservePrecision]
  **/
  function bproBtcValue(uint256 bproAmount, uint256 bproBtcPrice)
  public view returns(uint256) {
    return mocLibConfig.bproBtcValue(bproAmount, bproBtcPrice);
  }

  /**
   MaxDoc = ((nB*B)-(Cobj*B/Bcons*nDoc*PEG))/(PEG*(Cobj*B/BCons-1))

    @dev Max amount of Docs to issue
    @param nB Total BTC amount [using reservePrecision]
    @param cobj Target Coverage [using mocPrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bCons BTC conservative price [using mocPrecision]
    @return Total Docs amount [using mocPrecision]
  **/
  function maxDoc(uint256 nB, uint256 cobj, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons)
  public view returns(uint256) {
    return mocLibConfig.maxDoc(nB, cobj, nDoc, peg, btcPrice, bCons);
  }

  /**
   MaxBPro = ((nB*B)-(Cobj*nDoc*PEG))/TPusd

    @dev Max amount of BPro to redeem
    @param nB Total BTC amount [using reservePrecision]
    @param cobj Target Coverage [using mocPrecision]
    @param nDoc Target Coverage [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bCons BTC conservative price [using mocPrecision]
    @param bproUsdPrice bproUsdPrice [using mocPrecision]
    @return Total BPro amount [using mocPrecision]
  **/
  function maxBPro(
    uint256 nB, uint256 cobj, uint256 nDoc, uint256 peg,
    uint256 btcPrice, uint256 bCons, uint256 bproUsdPrice
  )
  public view returns(uint256) {
    return mocLibConfig.maxBPro(
      nB, cobj, nDoc, peg, btcPrice, bCons, bproUsdPrice
    );
  }

  /**
    @dev Calculates the total BTC price of the amount of BPros
    @param amount Amount of BPro [using mocPrecision]
    @param bproPrice BPro BTC Price [using reservePrecision]
    @return BPro total value in BTC [using reservePrecision]
  **/
  function totalBProInBtc(uint256 amount, uint256 bproPrice)
  public view returns(uint256) {
    return mocLibConfig.totalBProInBtc(amount, bproPrice);
  }

  /**
    @dev Calculates the equivalent in Docs of the btcAmount
    @param btcAmount BTC  amount [using reservePrecision]
    @param btcPrice BTC price [using mocPrecision]
    @return Equivalent Doc amount [using mocPrecision]
  **/
  function maxDocsWithBtc(uint256 btcAmount, uint256 btcPrice)
  public view returns(uint256) {
    return mocLibConfig.maxDocsWithBtc(btcAmount, btcPrice);
  }

  /**
    @dev Calculates the equivalent in BPro of the btcAmount
    @param btcAmount BTC amount [using reservePrecision]
    @param bproPrice BPro BTC price [using reservePrecision]
    @return Equivalent Bpro amount [using mocPrecision]
  **/
  function maxBProWithBtc(uint256 btcAmount, uint256 bproPrice)
  public view returns(uint256) {
    return mocLibConfig.maxBProWithBtc(btcAmount, bproPrice);
  }

  /**
    toMove = btcAmount * (lev - 1)

    @dev Calculates the Btc amount to move from C0 bucket to
    an L bucket when a BProx minting occurs
    @param btcAmount Total BTC amount [using reservePrecision]
    @param lev L bucket leverage [using mocPrecision]
    @return btc to move [using reservePrecision]
    **/
  function bucketTransferAmount(uint256 btcAmount, uint256 lev)
  public view returns(uint256) {
    return mocLibConfig.bucketTransferAmount(btcAmount, lev);
  }

   /**
    Maxbprox = nDOC/ (PEG*B*(lev-1))

    @dev Max amount of BTC allowed to be used to mint bprox
    @param nDoc number of DOC [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param lev leverage [using mocPrecision]
    @return Max bprox BTC value [using reservePrecision]
  **/
  function maxBProxBtcValue(uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 lev)
  public view returns(uint256)  {
    return mocLibConfig.maxBProxBtcValue(nDoc, peg, btcPrice, lev);
  }

  /**
    @dev Calculates the equivalent in MoC of the btcAmount
    @param btcAmount BTC  amount
    @param btcPrice BTC price
    @param mocPrice MoC price
    @return Equivalent MoC amount
  **/
  function maxMoCWithBtc(uint256 btcAmount, uint256 btcPrice, uint256 mocPrice)
  public view returns(uint256) {
    return mocLibConfig.maxMoCWithBtc(btcAmount, btcPrice, mocPrice);
  }

  /**
    @dev Calculates the equivalent in BTC of the MoC amount
    @param amount BTC  amount
    @param btcPrice BTC price
    @param mocPrice MoC price
    @return Equivalent MoC amount
  **/
  function mocBtcValue(uint256 amount, uint256 btcPrice, uint256 mocPrice)
  public view returns(uint256) {
    return mocLibConfig.mocBtcValue(amount, btcPrice, mocPrice);
  }

  function getPayableAddress(address account)
  public view returns (address payable) {
    return mocLibConfig.getPayableAddress(account);
  }
}
