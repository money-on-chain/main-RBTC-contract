pragma solidity ^0.5.8;

import "moc-governance/contracts/Governance/Governed.sol";
import "./MoCLibConnection.sol";
import "./MoCState_v017.sol";
import "./MoCBProxManager.sol";
import "./MoCConverter.sol";
import "./base/MoCBase.sol";

contract MoCInrateEvents_v017 {
  event InrateDailyPay(uint256 amount, uint256 daysToSettlement, uint256 nReserveBucketC0);
  event RiskProHoldersInterestPay(uint256 amount, uint256 nReserveBucketC0BeforePay);
}

contract MoCInrateStructs_017 {
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
}


contract MoCInrate_v017 is MoCInrateEvents_v017, MoCInrateStructs_017, MoCBase, MoCLibConnection, Governed {
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
  // commissionRate [using mocPrecision]
  uint256 public commissionRate;

  /**CONTRACTS**/
  MoCState_v017 internal mocState;
  MoCConverter internal mocConverter;
  MoCBProxManager internal bproxManager;

  /************************************/
  /***** UPGRADE v017       ***********/
  /************************************/

  /** START UPDATE V017: 01/11/2019 **/

  // Upgrade to support red doc inrate parameter
  uint256 public docTmin;
  uint256 public docPower;
  uint256 public docTmax;

  // to check is already initialized upgrade v017
  bool internal upgrade_v017;

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

  function initialize_v017(
    uint256 _docTmin,
    uint256 _docPower,
    uint256 _docTmax
  ) public {

    require(upgrade_v017 == false, "Already Initialized");

    docTmin = _docTmin;
    docPower = _docPower;
    docTmax = _docTmax;

    upgrade_v017 = true;

  }

  /** END UPDATE V017: 01/11/2019 **/

  function initialize(
    address connectorAddress,
    address _governor,
    uint256 btcxTmin,
    uint256 btcxPower,
    uint256 btcxTmax,
    uint256 _bitProRate,
    uint256 blockSpanBitPro,
    address payable bitProInterestTargetAddress,
    address payable commissionsAddressTarget,
    uint256 commissionRateParam
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(
      _governor,
      btcxTmin,
      btcxPower,
      btcxTmax,
      _bitProRate,
      commissionsAddressTarget,
      commissionRateParam,
      blockSpanBitPro,
      bitProInterestTargetAddress
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
  function getBitProRate() public view returns(uint256){
    return bitProRate;
  }

  function getCommissionRate() public view returns(uint256) {
    return commissionRate;
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
  function getBitProInterestAddress() public view returns(address payable){
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
    @dev Sets the commission rate for Mint/Redeem transactions
    @param newCommissionRate New commission rate
   */
  function setCommissionRate(uint256 newCommissionRate) public onlyAuthorizedChanger() {
    commissionRate = newCommissionRate;
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
    @dev returns the amount of BTC to pay in concept of interest
    to bucket C0
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

  /**
    @dev calculates the Commission rate from the passed RBTC amount for mint/redeem operations
    @param rbtcAmount Total value from which apply the Commission rate [using reservePrecision]
    @return finalCommissionAmount [using reservePrecision]
  */
  function calcCommissionValue(uint256 rbtcAmount)
  public view returns(uint256) {
    uint256 finalCommissionAmount = rbtcAmount.mul(commissionRate).div(mocLibConfig.mocPrecision);
    return finalCommissionAmount;
  }

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
    @dev This function calculates the interest to return
    if a user redeem all Btcx in existance
    @param bucket Bucket to use to calculate interest
    @return Interests [using reservePrecision]
  */
  function calcFullRedeemInterestValue(bytes32 bucket) internal view returns(uint256) {
    // Value in RBTC of all BProxs in the bucket
    uint256 fullBProxRbtcValue = mocConverter.bproxToBtc(bproxManager.getBucketNBPro(bucket), bucket);
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
    uint256 docsToMove = mocConverter.btcToDoc(btcToMove);

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

    if (daysToSettl < mocLibConfig.dayPrecision){
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
    mocState = MoCState_v017(connector.mocState());
    mocConverter = MoCConverter(connector.mocConverter());
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
    uint256 commissionRateParam,
    uint256 blockSpanBitPro,
    address payable bitProInterestsTarget
  ) internal {
    governor = IGovernor(_governor);
    btcxParams.tMin = btcxMin;
    btcxParams.power = btcxPower;
    btcxParams.tMax = btcxMax;
    bitProRate = _bitProRate;
    bitProInterestAddress = bitProInterestsTarget;
    bitProInterestBlockSpan = blockSpanBitPro;
    commissionRate = commissionRateParam;
    commissionsAddress = commissionsAddressTarget;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[46] private upgradeGap;
}
