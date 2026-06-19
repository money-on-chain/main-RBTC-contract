pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "moc-governance/contracts/Governance/Governed.sol";
import "moc-governance/contracts/Governance/IGovernor.sol";
import "./MoCLibConnection.sol";
import "./interface/IMoCState.sol";
import "./MoCBProxManager.sol";
import "./base/MoCBase.sol";
import "./interface/IMoCVendors.sol";
import "./interface/IMoCInrate.sol";

contract MoCInrateEvents {
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

  function isDailyEnabled() public view returns(bool) {
    return false;
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
