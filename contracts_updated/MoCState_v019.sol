pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/Math.sol";
import "./interface/BtcPriceProvider.sol";
import "./MoCEMACalculator.sol";
import "./base/MoCBase.sol";
import "./MoCLibConnection.sol";
import "./MoCBProxManager.sol";
import "./token/DocToken.sol";
import "./token/BProToken.sol";
import "./MoCSettlement.sol";
import "moc-governance/contracts/Governance/Governed.sol";
import "moc-governance/contracts/Governance/IGovernor.sol";

contract MoCState_v019 is MoCLibConnection, MoCBase, MoCEMACalculator {
  using Math for uint256;
  using SafeMath for uint256;

  // This is the current state.
  States public state;

  event StateTransition(States newState);
  event PriceProviderUpdated(address oldAddress, address newAddress);
  // Contracts
  BtcPriceProvider internal btcPriceProvider;
  MoCSettlement internal mocSettlement;
  MoCConverter internal mocConverter;
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

  function initialize(
    address connectorAddress,
    address _governor,
    address _btcPriceProvider,
    uint256 _liq,
    uint256 _utpdu,
    uint256 _maxDiscRate,
    uint256 _dayBlockSpan,
    uint256 _ema,
    uint256 _smoothFactor,
    uint256 _emaBlockSpan,
    uint256 _maxMintBPro
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(_governor, _btcPriceProvider,_liq, _utpdu, _maxDiscRate, _dayBlockSpan, _maxMintBPro);
    initializeMovingAverage(_ema, _smoothFactor, _emaBlockSpan);
  }

  /**
  * @param rate Discount rate at liquidation level [using mocPrecision]
  **/
  function setMaxDiscountRate(uint256 rate) public onlyAuthorizedChanger() {
    require(rate < mocLibConfig.mocPrecision, "rate is lower than mocPrecision");

    bproMaxDiscountRate = rate;
  }

    /**
   * @dev return the value of the BPro max discount rate configuration param
   * @return bproMaxDiscountRate BPro max discount rate
   */
  function getMaxDiscountRate() public view returns(uint256) {
    return bproMaxDiscountRate;
  }

  /**
  * @dev Defines how many blocks there are in a day
  * @param blockSpan blocks there are in a day
  **/
  function setDayBlockSpan(uint256 blockSpan) public onlyAuthorizedChanger() {
    dayBlockSpan = blockSpan;
  }

  /**
  * @dev Sets a new BTCProvider contract
  * @param btcProviderAddress blocks there are in a day
  **/
  function setBtcPriceProvider(address btcProviderAddress) public onlyAuthorizedChanger() {
    address oldBtcPriceProviderAddress = address(btcPriceProvider);
    btcPriceProvider = BtcPriceProvider(btcProviderAddress);
    emit PriceProviderUpdated(oldBtcPriceProviderAddress, address(btcPriceProvider));
  }

  /**
  * @dev Gets the BTCPriceProviderAddress
  * @return btcPriceProvider blocks there are in a day
  **/
  function getBtcPriceProvider() public view returns(address) {
    return address(btcPriceProvider);
  }
  /**
   * @dev Gets how many blocks there are in a day
   * @return blocks there are in a day
   */
  function getDayBlockSpan() public view returns(uint256) {
    return dayBlockSpan;
  }
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

/**
  * @dev Subtract the btc amount passed by parameter to the total Bitcoin Amount
  * @param btcAmount Amount that will be subtract to rbtcInSystem
  */
  function subtractRbtcFromSystem(uint256 btcAmount) public onlyWhitelisted(msg.sender) {
    rbtcInSystem = rbtcInSystem.sub(btcAmount);
  }

  /**
  * @dev btcAmount Add the btc amount passed by parameter to the total Bitcoin Amount
  * @param btcAmount Amount that will be added to rbtcInSystem
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
    * @dev Amount of Bitcoins in the system excluding
    * BTCx values and interests holdings
    */
  function collateralRbtcInSystem() public view returns(uint256) {
    uint256 rbtcInBtcx = mocConverter.bproxToBtc(bproxManager.getBucketNBPro(BUCKET_X2),BUCKET_X2);
    uint256 rbtcInBag = bproxManager.getInrateBag(BUCKET_C0);

    return rbtcInSystem.sub(rbtcInBtcx).sub(rbtcInBag);
  }

  /** @dev GLOBAL Coverage
    * @return coverage [using mocPrecision]
    */
  function globalCoverage() public view returns(uint256) {
    uint256 lB = globalLockedBitcoin();

    return mocLibConfig.coverage(collateralRbtcInSystem(), lB);
  }

  /**
  * @dev BUCKET lockedBitcoin
  * @param bucket Name of the bucket used
  * @return lockedBitcoin amount [using reservePrecision]
  */
  function lockedBitcoin(bytes32 bucket) public view returns(uint256) {
    uint256 nDoc = bproxManager.getBucketNDoc(bucket);

    return mocLibConfig.lockedBitcoin(getBitcoinPrice(), nDoc, peg);
  }

  /**
  * @dev Gets RBTC in BitPro within specified bucket
  * @param bucket Name of the bucket used
  * @return Bitcoin amount of BitPro in Bucket [using reservePrecision]
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
  * @dev Gets the RBTC in the contract that not corresponds
    to Doc collateral
  * @return RBTC remainder [using reservePrecision]
  */
  function getRbtcRemainder() public view returns(uint256) {
    uint256 lB = globalLockedBitcoin();

    if ( lB >= rbtcInSystem ){
      return 0;
    }

    return rbtcInSystem.sub(lB);
  }

  /**
  * @dev BUCKET Coverage
  * @param bucket Name of the bucket used
  * @return coverage [using coveragePrecision]
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
  * @dev Abundance ratio, receives tha amount of doc to use the value of doc0 and Doc total supply
  * @return abundance ratio [using mocPrecision]
  */
  function abundanceRatio(uint256 doc0) public view returns(uint256) {
    return mocLibConfig.abundanceRatio(doc0, docTotalSupply());
  }

  /**
  * @dev Relation between docs in bucket 0 and Doc total supply
  * @return abundance ratio [using mocPrecision]
  */
  function currentAbundanceRatio() public view returns(uint256) {
    return abundanceRatio(getBucketNDoc(BUCKET_C0));
  }

  /**
  * @dev BUCKET Leverage
  * @param bucket Name of the bucket used
  * @return coverage [using mocPrecision]
  */
  function leverage(bytes32 bucket) public view returns(uint256) {
    uint256 cov = coverage(bucket);

    return mocLibConfig.leverageFromCoverage(cov);
  }

  /**
  * @dev GLOBAL maxDoc
  * @return abundance ratio [using mocPrecision]
  */
  function globalMaxDoc() public view returns(uint256) {
    return mocLibConfig.maxDoc(collateralRbtcInSystem(), cobj(), docTotalSupply(), peg, getBitcoinPrice(), getBcons());
  }

  /**
  * @return amount of docs in bucket 0, that can be redeemed outside of settlement [using mocPrecision]
  */
  function freeDoc() public view returns(uint256) {
    return bproxManager.getBucketNDoc(BUCKET_C0);
  }

  /**
  * @dev BUCKET maxDoc
  * @return abundance ratio [using mocPrecision]
  */
  function maxDoc(bytes32 bucket) public view returns(uint256) {
    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 nDoc = bproxManager.getBucketNDoc(bucket);
    uint256 bktCobj = bproxManager.getBucketCobj(bucket);

    return mocLibConfig.maxDoc(nB, bktCobj, nDoc, peg, getBitcoinPrice(), getBcons());
  }

  /**
  * @dev GLOBAL maxBPro
  * @return maxBPro for redeem [using reservePrecision]
  */
  function globalMaxBPro() public view returns(uint256) {
    uint256 bproPrice = bproUsdPrice();

    return mocLibConfig.maxBPro(
      collateralRbtcInSystem(), cobj(), docTotalSupply(), peg, getBitcoinPrice(), getBcons(), bproPrice
    );
  }

  /**
  * @dev ABSOLUTE maxDoc
  * @return maxDoc to issue [using mocPrecision]
  */
  function absoluteMaxDoc() public view returns(uint256) {
    return Math.min(globalMaxDoc(), maxDoc(BUCKET_C0));
  }

  /** @dev BUCKET maxBPro to redeem / mint
      @param bucket Name of the bucket used
    * @return maxBPro for redeem [using mocPrecision]
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
  * @dev GLOBAL max bprox to mint
  * @param bucket Name of the bucket used
  * @return maxBProx [using reservePrecision]
  */
  function maxBProx(bytes32 bucket) public view returns(uint256) {
    uint256 maxBtc = maxBProxBtcValue(bucket);

    return mocLibConfig.maxBProWithBtc(maxBtc, bucketBProTecPrice(bucket));
  }

  /**
  * @dev GLOBAL max bprox to mint
  * @param bucket Name of the bucket used
  * @return maxBProx BTC value to mint [using reservePrecision]
  */
  function maxBProxBtcValue(bytes32 bucket) public view returns(uint256) {
    uint256 nDoc0 = bproxManager.getBucketNDoc(BUCKET_C0);
    uint256 bucketLev = leverage(bucket);

    return mocLibConfig.maxBProxBtcValue(nDoc0, peg, getBitcoinPrice(), bucketLev);
  }

  /** @dev ABSOLUTE maxBPro
  * @return maxDoc to issue [using mocPrecision]
  */
  function absoluteMaxBPro() public view returns(uint256) {
    return Math.min(globalMaxBPro(), maxBPro(BUCKET_C0));
  }

  /**
  * @dev DISCOUNT maxBPro
  * @return maxBPro for mint with discount [using mocPrecision]
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
  * @dev GLOBAL lockedBitcoin
  * @return lockedBitcoin amount [using reservePrecision]
  */
  function globalLockedBitcoin() public view returns(uint256) {
    return mocLibConfig.lockedBitcoin(getBitcoinPrice(), docTotalSupply(), peg);
  }

  /**
  * @dev BTC price of BPro
  * @return the BPro Tec Price [using reservePrecision]
  */
  function bproTecPrice() public view returns(uint256) {
    return bucketBProTecPrice(BUCKET_C0);
  }

  /**
  * @dev BUCKET BTC price of BPro
  * @param bucket Name of the bucket used
  * @return the BPro Tec Price [using reservePrecision]
  */
  function bucketBProTecPrice(bytes32 bucket) public view returns(uint256) {
    uint256 nBPro = bproxManager.getBucketNBPro(bucket);
    uint256 lb = lockedBitcoin(bucket);
    uint256 nB = bproxManager.getBucketNBTC(bucket);

    return mocLibConfig.bproTecPrice(nB, lb, nBPro);
  }

  /**
  * @dev BTC price of BPro with spot discount applied
  * @return the BPro Tec Price [using reservePrecision]
  */
  function bproDiscountPrice() public view returns(uint256) {
    uint256 bproTecprice = bproTecPrice();
    uint256 discountRate = bproSpotDiscountRate();

    return mocLibConfig.applyDiscountRate(bproTecprice, discountRate);
  }

  /**
  * @dev BPro USD PRICE
  * @return the BPro USD Price [using mocPrecision]
  */
  function bproUsdPrice() public view returns(uint256) {
    uint256 bproBtcPrice = bproTecPrice();
    uint256 btcPrice = getBitcoinPrice();

    return btcPrice.mul(bproBtcPrice).div(mocLibConfig.reservePrecision);
  }

 /**
  * @dev GLOBAL max bprox to mint
  * @param bucket Name of the bucket used
  * @return max BPro allowed to be spent to mint BProx [using reservePrecision]
  **/
  function maxBProxBProValue(bytes32 bucket) public view returns(uint256) {
    uint256 btcValue = maxBProxBtcValue(bucket);

    return mocLibConfig.maxBProWithBtc(btcValue, bproTecPrice());
  }

  /**
  * @dev BUCKET BProx price in BPro
  * @param bucket Name of the bucket used
  * @return BProx BPro Price [using mocPrecision]
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
  * @dev GLOBAL BTC Discount rate to apply to BProPrice.
  * @return BPro discount rate [using DISCOUNT_PRECISION].
   */
  function bproSpotDiscountRate() public view returns(uint256) {
    uint256 cov = globalCoverage();

    return mocLibConfig.bproSpotDiscountRate(bproMaxDiscountRate, liq, utpdu, cov);
  }

  /**
    @dev Calculates the number of days to next settlement based dayBlockSpan
   */
  function daysToSettlement() public view returns(uint256) {
    return blocksToSettlement().mul(mocLibConfig.dayPrecision).div(dayBlockSpan);
  }

  /**
    @dev Number of blocks to settlement
   */
  function blocksToSettlement() public view returns(uint256) {
    if (mocSettlement.nextSettlementBlock() <= block.number) {
      return 0;
    }

    return mocSettlement.nextSettlementBlock().sub(block.number);
  }

  /**
   * @dev Verifies if forced liquidation is reached checking if globalCoverage <= liquidation (currently 1.04)
   * @return true if liquidation state is reached, false otherwise
   */
  function isLiquidationReached() public view returns(bool) {
    uint256 cov = globalCoverage();
    if (state != States.Liquidated && cov <= liq)
      return true;
    return false;
  }

  /**
    @dev Returns the price to use for doc redeem in a liquidation event
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
   * @dev return the value of the liq threshold configuration param
   * @return liq threshold, currently 1.04
   */
  function getLiq() public view returns(uint256) {
    return liq;
  }

  /**
   * @dev sets the value of the liq threshold configuration param
   * @param _liq liquidation threshold
   */
  function setLiq(uint _liq) public onlyAuthorizedChanger(){
    liq = _liq;
  }

  /**
   * @dev return the value of the utpdu threshold configuration param
   * @return utpdu Universal TPro discount sales coverage threshold
   */
  function getUtpdu() public view returns(uint256) {
    return utpdu;
  }

  /**
   * @dev sets the value of the utpdu threshold configuration param
   * @param _utpdu Universal TPro discount sales coverage threshold
   */
  function setUtpdu(uint _utpdu) public onlyAuthorizedChanger(){
    utpdu = _utpdu;
  }

  /**
   * @dev returns the relation between DOC and dollar. By default it is 1.
   * @return peg relation between DOC and dollar
   */
  function getPeg() public view returns(uint256) {
    return peg;
  }

  /**
   * @dev sets the relation between DOC and dollar. By default it is 1.
   * @param _peg relation between DOC and dollar
   */
  function setPeg(uint _peg) public onlyAuthorizedChanger(){
    peg = _peg;
  }

  function nextState() public {
    // There is no coming back from Liquidation
    if (state == States.Liquidated)
      return;

    States prevState = state;
    calculateBitcoinMovingAverage();
    uint256 cov = globalCoverage();
    if (cov <= liq) {
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
    uint256 _maxMintBPro) internal {
    liq = _liq;
    utpdu = _utpdu;
    bproMaxDiscountRate = _maxDiscRate;
    dayBlockSpan = _dayBlockSpan;
    governor = IGovernor(_governor);
    btcPriceProvider = BtcPriceProvider(_btcPriceProvider);
    // Default values
    state = States.AboveCobj;
    peg = 1;
    maxMintBPro = _maxMintBPro;
  }

  function initializeContracts() internal  {
    mocSettlement = MoCSettlement(connector.mocSettlement());
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocConverter = MoCConverter(connector.mocConverter());
  }

  /************************************/
  /***** UPGRADE v017       ***********/
  /************************************/

  /** START UPDATE V017: 01/11/2019 **/

  // Max value posible to mint of BPro
  uint256 public maxMintBPro;

  /**
  * @param _maxMintBPro [using mocPrecision]
  **/
  function setMaxMintBPro(uint256 _maxMintBPro) public onlyAuthorizedChanger() {
    maxMintBPro = _maxMintBPro;
  }

   /**
   * @dev return Max value posible to mint of BPro
   * @return maxMintBPro
   */
  function getMaxMintBPro() public view returns(uint256) {
    return maxMintBPro;
  }

  /**
  * @dev return the bpro available to mint
  * @return maxMintBProAvalaible  [using mocPrecision]
  */
  function maxMintBProAvalaible() public view returns(uint256) {

    uint256 totalBPro = bproTotalSupply();
    uint256 maxiMintBPro = getMaxMintBPro();

    if (totalBPro >= maxiMintBPro) {
      return 0;
    }

    uint256 availableMintBPro = maxiMintBPro.sub(totalBPro);

    return availableMintBPro;
  }

  /** END UPDATE V017: 01/11/2019 **/

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
