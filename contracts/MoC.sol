pragma solidity 0.5.8;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./MoCLibConnection.sol";
import "./token/DocToken.sol";
import "./token/BProToken.sol";
import "./MoCBProxManager.sol";
import "./MoCState.sol";
import "./MoCConverter.sol";
import "./MoCSettlement.sol";
import "./MoCExchange.sol";
import "./base/MoCBase.sol";
import "moc-governance/contracts/Stopper/Stoppable.sol";
import "moc-governance/contracts/Governance/IGovernor.sol";
import "./token/MoCToken.sol";
import "./MoCVendors.sol";

contract MoCEvents {
  event BucketLiquidation(bytes32 bucket);
  event ContractLiquidated(address mocAddress);
}

contract MoC is MoCEvents, MoCLibConnection, MoCBase, Stoppable  {
  using SafeMath for uint256;

  /// @dev Contracts.
  DocToken internal docToken;
  BProToken internal bproToken;
  MoCBProxManager internal bproxManager;
  MoCState internal mocState;
  MoCConverter internal mocConverter;
  MoCSettlement internal settlement;
  MoCExchange internal mocExchange;
  MoCInrate internal mocInrate;
  /// @dev 'MoCBurnout' is deprecated. DO NOT use this variable.
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  address public DEPRECATED_mocBurnout;

  /// @dev Indicates if Rbtc remainder was sent and BProToken was paused
  bool internal liquidationExecuted;

  //TODO: We must research if fallback function is really needed.
  /**
    @dev Fallback function
  */
  function() external payable whenNotPaused() transitionState() {
    bproxManager.addValuesToBucket(BUCKET_C0, msg.value, 0, 0);
    mocState.addToRbtcInSystem(msg.value);
  }

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
    @param governorAddress Governor contract address
    @param stopperAddress Stopper contract address
    @param startStoppable Indicates if the contract starts being unstoppable or not
  */
  function initialize(
    address connectorAddress,
    address governorAddress,
    address stopperAddress,
    bool startStoppable
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    //initializeContracts
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = MoCState(connector.mocState());
    settlement = MoCSettlement(connector.mocSettlement());
    mocConverter = MoCConverter(connector.mocConverter());
    mocExchange = MoCExchange(connector.mocExchange());
    mocInrate = MoCInrate(connector.mocInrate());
    //initializeGovernanceContracts
    Stoppable.initialize(stopperAddress, IGovernor(governorAddress), startStoppable);
  }

  /****************************INTERFACE*******************************************/

  /**
    @dev Gets the BProx balance of an address
    @param bucket Name of the bucket
    @param account Address
    @return BProx balance of the address
  */
  function bproxBalanceOf(bytes32 bucket, address account) public view returns(uint256) {
    return bproxManager.bproxBalanceOf(bucket, account);
  }

  /**
    @dev Gets the RedeemRequest at the queue index position
    @param index queue position to get
    @return redeemer's address and amount he submitted
  */
  function getRedeemRequestAt(uint256 index) public view returns(address, uint256) {
    return settlement.getRedeemRequestAt(index);
  }

  /**
    @dev Returns current redeem queue size
    @return redeem queue size
   */
  function redeemQueueSize() public view returns(uint256) {
    return settlement.redeemQueueSize();
  }

  /**
    @dev Returns the total amount of Docs in the redeem queue for redeemer
    @param redeemer address for which ^ is computed
    @return total amount of Docs in the redeem queue for redeemer
   */
  function docAmountToRedeem(address redeemer) public view returns(uint256) {
    return settlement.docAmountToRedeem(redeemer);
  }


  /**
  * @dev Creates or updates the amount of a Doc redeem Request from the msg.sender
  * @param docAmount Amount of Docs to redeem on settlement [using mocPrecision]
  */
  function redeemDocRequest(uint256 docAmount) public  whenNotPaused() whenSettlementReady() {
    settlement.addRedeemRequest(docAmount, msg.sender);
  }

  /**
    @dev Alters the redeem amount position for the redeemer
    @param isAddition true if adding amount to redeem, false to substract.
    @param delta the amount to add/substract to current position
  */
  function alterRedeemRequestAmount(bool isAddition, uint256 delta) public whenNotPaused() whenSettlementReady() {
    settlement.alterRedeemRequestAmount(isAddition, delta, msg.sender);
  }

  /**
    @dev Mints BPRO and pays the comissions of the operation (retrocompatible function).
    @dev Retrocompatible function.
    @param btcToMint Amount in BTC to mint
   */
  function mintBPro(uint256 btcToMint)
  public payable {
    mintBProVendors(btcToMint, address(0));
  }

  /**
    @dev Mints BPRO and pays the comissions of the operation.
    @param btcToMint Amount in BTC to mint
    @param vendorAccount Vendor address
   */
  function mintBProVendors(uint256 btcToMint, address vendorAccount)
  public payable
  whenNotPaused() transitionState() notInProtectionMode() {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 totalBtcSpent,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.mintBPro(msg.sender, btcToMint, vendorAccount);

    transferCommissions(
      msg.sender,
      msg.value,
      totalBtcSpent,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Redeems Bpro Tokens and pays the comissions of the operation (retrocompatible function).
    @param bproAmount Amount in Bpro
  */
  function redeemBPro(uint256 bproAmount)
  public {
    redeemBProVendors(bproAmount, address(0));
  }

  /**
    @dev Redeems Bpro Tokens and pays the comissions of the operation
    @param bproAmount Amount in Bpro
    @param vendorAccount Vendor address
  */
  function redeemBProVendors(uint256 bproAmount, address vendorAccount)
  public
  whenNotPaused() transitionState() atLeastState(MoCState.States.AboveCobj) {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 btcAmount,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.redeemBPro(msg.sender, bproAmount, vendorAccount);

    doTransfer(msg.sender, btcAmount);

    redeemWithMoCFees(msg.sender, btcCommission, mocCommission, vendorAccount, btcMarkup, mocMarkup);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Mint Doc tokens and pays the commisions of the operation (retrocompatible function).
    @dev Retrocompatible function.
    @param btcToMint Amount in RBTC to mint
  */
  function mintDoc(uint256 btcToMint)
  public payable {
    mintDocVendors(btcToMint, address(0));
  }

  /**
   * @dev Mint Doc tokens and pays the commisions of the operation
   * @param btcToMint Amount in RBTC to mint
   * @param vendorAccount Vendor address
   */
  function mintDocVendors(uint256 btcToMint, address vendorAccount)
  public payable
  whenNotPaused() transitionState() atLeastState(MoCState.States.AboveCobj) {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 totalBtcSpent,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.mintDoc(msg.sender, btcToMint, vendorAccount);

    transferCommissions(
      msg.sender,
      msg.value,
      totalBtcSpent,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Redeems Bprox Tokens and pays the comissions of the operation in RBTC (retrocompatible function).
    @dev Retrocompatible function.
    @param bucket Bucket to reedem, for example X2
    @param bproxAmount Amount in Bprox
  */
  function redeemBProx(bytes32 bucket, uint256 bproxAmount) public {
    redeemBProxVendors(bucket, bproxAmount, address(0));
  }

  /**
    @dev Redeems Bprox Tokens and pays the comissions of the operation in RBTC
    @param bucket Bucket to reedem, for example X2
    @param bproxAmount Amount in Bprox
    @param vendorAccount Vendor address
  */
  function redeemBProxVendors(bytes32 bucket, uint256 bproxAmount, address vendorAccount) public
  whenNotPaused() whenSettlementReady() availableBucket(bucket) notBaseBucket(bucket)
  transitionState() bucketStateTransition(bucket) {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 totalBtcRedeemed,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.redeemBProx(msg.sender, bucket, bproxAmount, vendorAccount);

    doTransfer(msg.sender, totalBtcRedeemed);

    redeemWithMoCFees(msg.sender, btcCommission, mocCommission, vendorAccount, btcMarkup, mocMarkup);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev BUCKET bprox minting (retrocompatible function).
    @dev Retrocompatible function.
    @param bucket Name of the bucket used
    @param btcToMint amount to mint on RBTC
  */
  function mintBProx(bytes32 bucket, uint256 btcToMint) public payable {
    mintBProxVendors(bucket, btcToMint, address(0));
  }

  /**
    @dev BUCKET bprox minting
    @param bucket Name of the bucket used
    @param btcToMint amount to mint on RBTC
    @param vendorAccount Vendor address
  */
  function mintBProxVendors(bytes32 bucket, uint256 btcToMint, address vendorAccount) public payable
  whenNotPaused() whenSettlementReady() availableBucket(bucket) notBaseBucket(bucket)
  transitionState() bucketStateTransition(bucket) {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 totalBtcSpent,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.mintBProx(msg.sender, bucket, btcToMint, vendorAccount);

    transferCommissions(
      msg.sender,
      msg.value,
      totalBtcSpent,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Redeems the requested amount for the msg.sender, or the max amount of free docs possible (retrocompatible function).
    @dev Retrocompatible function.
    @param docAmount Amount of Docs to redeem.
  */
  function redeemFreeDoc(uint256 docAmount)
  public {
    redeemFreeDocVendors(docAmount, address(0));
  }

  /**
    @dev Redeems the requested amount for the msg.sender, or the max amount of free docs possible.
    @param docAmount Amount of Docs to redeem.
    @param vendorAccount Vendor address
  */
  function redeemFreeDocVendors(uint256 docAmount, address vendorAccount)
  public
  whenNotPaused() transitionState() notInProtectionMode() {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 btcAmount,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.redeemFreeDoc(msg.sender, docAmount, vendorAccount);

    doTransfer(msg.sender, btcAmount);

    redeemWithMoCFees(msg.sender, btcCommission, mocCommission, vendorAccount, btcMarkup, mocMarkup);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Allow redeem on liquidation state, user DoCs get burned and he receives
    the equivalent BTCs if can be covered, or the maximum available
  */
  function redeemAllDoc() public atState(MoCState.States.Liquidated) {
    mocExchange.redeemAllDoc(msg.sender, msg.sender);
  }

  /**
    @dev Moves the daily amount of interest rate to C0 bucket
  */
  function dailyInratePayment() public whenNotPaused() {
    mocInrate.dailyInratePayment();
  }

  /**
    @dev Pays the BitPro interest and transfers it to the address mocInrate.bitProInterestAddress
    BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function payBitProHoldersInterestPayment() public whenNotPaused() {
    uint256 toPay = mocInrate.payBitProHoldersInterestPayment();
    if (doSend(mocInrate.getBitProInterestAddress(), toPay)) {
      bproxManager.substractValuesFromBucket(BUCKET_C0, toPay, 0, 0);
    }
  }

  /**
    @dev Calculates BitPro holders holder interest by taking the total amount of RBTCs available on Bucket 0.
    BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function calculateBitProHoldersInterest() public view returns(uint256, uint256) {
    return mocInrate.calculateBitProHoldersInterest();
  }

  /**
    @dev Gets the target address to transfer BitPro Holders rate
    @return Target address to transfer BitPro Holders interest
  */
  function getBitProInterestAddress() public view returns(address payable) {
    return mocInrate.getBitProInterestAddress();
  }

  /**
    @dev Gets the rate for BitPro Holders
    @return BitPro Rate
  */
  function getBitProRate() public view returns(uint256) {
    return mocInrate.getBitProRate();
  }

  /**
    @dev Gets the blockspan of BPRO that represents the frecuency of BitPro holders interest payment
    @return returns power of bitProInterestBlockSpan
  */
  function getBitProInterestBlockSpan() public view returns(uint256) {
    return mocInrate.getBitProInterestBlockSpan();
  }

  function isDailyEnabled() public view returns(bool) {
    return mocInrate.isDailyEnabled();
  }

  function isBitProInterestEnabled() public view returns(bool) {
    return mocInrate.isBitProInterestEnabled();
  }

  /**
    @dev Indicates if settlement is enabled
    @return Returns true if blockSpan number of blocks has passed since last execution; otherwise false
  */
  function isSettlementEnabled() public view returns(bool) {
    return settlement.isSettlementEnabled();
  }

  /**
    @dev Checks if bucket liquidation is reached.
    @param bucket Name of bucket.
    @return true if bucket liquidation is reached, false otherwise
  */
  function isBucketLiquidationReached(bytes32 bucket) public view returns(bool) {
    if (mocState.coverage(bucket) <= mocState.liq()) {
      return true;
    }
    return false;
  }

  function evalBucketLiquidation(bytes32 bucket) public availableBucket(bucket) notBaseBucket(bucket) whenSettlementReady() {
    if (isBucketLiquidationReached(bucket)) {
      bproxManager.liquidateBucket(bucket, BUCKET_C0);

      emit BucketLiquidation(bucket);
    }
  }

  /**
    @dev Evaluates if liquidation state has been reached and runs liq if that's the case
  */
  function evalLiquidation() public transitionState() {
    // DO NOTHING. Everything is handled in transitionState() modifier.
  }

  /**
    @dev Runs all settlement process
    @param steps Number of steps
  */
  function runSettlement(uint256 steps) public whenNotPaused() transitionState() {
    // Transfer accums commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), settlement.runSettlement(steps));
  }

  /**
    @dev Send RBTC to a user and update RbtcInSystem in MoCState
    @param receiver address of receiver
    @param btcAmount amount to transfer
    @return result of the transaction
  */
  function sendToAddress(address payable receiver, uint256 btcAmount) public onlyWhitelisted(msg.sender) returns(bool) {
    if (btcAmount == 0) {
      return true;
    }
    return doSend(receiver, btcAmount);
  }

  function liquidate() internal {
    if (!liquidationExecuted) {
      //pauseBProToken
      if (!bproToken.paused()) {
        bproToken.pause();
      }
      //sendRbtcRemainder
      doTransfer(mocInrate.commissionsAddress(), mocState.getRbtcRemainder());
      liquidationExecuted = true;

      emit ContractLiquidated(connector.moc());
    }
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0110: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Internal functions **/

  /**
    @dev Transfer mint operation fees (commissions + vendor markup)
    @param sender address of msg.sender
    @param value amount of msg.value
    @param totalBtcSpent amount in RBTC spent
    @param btcCommission commission amount in RBTC
    @param mocCommission commission amount in MoC
    @param vendorAccount address of vendor
    @param btcMarkup vendor markup in RBTC
    @param mocMarkup vendor markup in MoC
  */
  // solium-disable-next-line security/no-assign-params
  function transferCommissions(
    address payable sender,
    uint256 value,
    uint256 totalBtcSpent,
    uint256 btcCommission,
    uint256 mocCommission,
    address vendorAccount,
    uint256 btcMarkup,
    uint256 mocMarkup
  )
  internal {
    uint256 totalMoCFee;

    if (mocCommission > 0 && mocMarkup > 0) {
      totalMoCFee = mocCommission.add(mocMarkup);
    } else {
      totalBtcSpent = totalBtcSpent.add(btcCommission).add(btcMarkup);
      require(totalBtcSpent <= value, "amount is not enough");
    }

    // Need to update general State
    mocState.addToRbtcInSystem(value);

    transferMocCommission(sender, mocCommission, vendorAccount, mocMarkup, totalMoCFee);

    transferBtcCommission(mocLibConfig.getPayableAddress(vendorAccount), btcCommission, btcMarkup);

    // Calculate change
    uint256 change = value.sub(totalBtcSpent);
    doTransfer(sender, change);
  }

  /**
    @dev Transfer operation fees in MoC (commissions + vendor markup)
    @param sender address of msg.sender
    @param mocCommission commission amount in MoC
    @param vendorAccount address of vendor
    @param mocMarkup vendor markup in MoC
    @param totalMoCFee commission + vendor markup in MoC
  */
  // solium-disable-next-line security/no-assign-params
  function transferMocCommission(
    address sender,
    uint256 mocCommission,
    address vendorAccount,
    uint256 mocMarkup,
    uint256 totalMoCFee
  ) internal {
    MoCVendors mocVendors = MoCVendors(mocState.getMoCVendors());

    // If commission and markup are paid in MoC
    if (totalMoCFee > 0) {
      // Transfer MoC from sender to this contract
      MoCToken mocToken = MoCToken(mocState.getMoCToken());
      mocToken.transferFrom(sender, address(this), totalMoCFee);

      // Transfer vendor markup in MoC
      if (mocVendors.getIsActive(vendorAccount) &&
          mocVendors.getTotalPaidInMoC(vendorAccount).add(mocMarkup) <= mocVendors.getStaking(vendorAccount)) {
        // Update vendor's markup
        mocVendors.updatePaidMarkup(vendorAccount, mocMarkup, 0, mocMarkup);
        // Transfer MoC to vendor address
        mocToken.transfer(vendorAccount, mocMarkup);
        // Transfer MoC to commissions address
        mocToken.transfer(mocInrate.commissionsAddress(), mocCommission);
      } else {
        // Transfer MoC to commissions address
        mocToken.transfer(mocInrate.commissionsAddress(), totalMoCFee);
      }
    }
  }

  /**
    @dev Transfer redeem operation fees (commissions + vendor markup)
    @param sender address of msg.sender
    @param btcCommission commission amount in RBTC
    @param mocCommission commission amount in MoC
    @param vendorAccount address of vendor
    @param btcMarkup vendor markup in RBTC
    @param mocMarkup vendor markup in MoC
  */
  function redeemWithMoCFees(
    address sender,
    uint256 btcCommission,
    uint256 mocCommission,
    address vendorAccount,
    uint256 btcMarkup,
    uint256 mocMarkup
  )
   internal {
    uint256 totalMoCFee;

    if (mocCommission > 0 && mocMarkup > 0) {
      totalMoCFee = mocCommission.add(mocMarkup);
      transferMocCommission(sender, mocCommission, vendorAccount, mocMarkup, totalMoCFee);
    } else {
      transferBtcCommission(mocLibConfig.getPayableAddress(vendorAccount), btcCommission, btcMarkup);
    }
  }

  /**
    @dev Transfer operation fees in RBTC (commissions + vendor markup)
    @param vendorAccount address of vendor
    @param btcCommission commission amount in RBTC
    @param btcMarkup vendor markup in RBTC
  */
  function transferBtcCommission(address payable vendorAccount, uint256 btcCommission, uint256 btcMarkup) internal {
    MoCVendors mocVendors = MoCVendors(mocState.getMoCVendors());

    uint256 totalBtcFee = btcCommission.add(btcMarkup);
    (uint256 btcMarkupInMoC, , ) = mocExchange.convertToMoCPrice(btcMarkup);

    // Transfer vendor markup in MoC
    if (mocVendors.getIsActive(vendorAccount) &&
        mocVendors.getTotalPaidInMoC(vendorAccount).add(btcMarkupInMoC) <= mocVendors.getStaking(vendorAccount)) {
      // Update vendor's markup
      mocVendors.updatePaidMarkup(vendorAccount, 0, btcMarkup, btcMarkupInMoC);
      // Transfer RBTC to vendor address
      doTransfer(vendorAccount, btcMarkup);
      // Transfer RBTC to commissions address
      doTransfer(mocInrate.commissionsAddress(), btcCommission);
    } else {
      // Transfer MoC to commissions address
      doTransfer(mocInrate.commissionsAddress(), totalBtcFee);
    }
  }

  /** END UPDATE V0110: 24/09/2020 **/

  /**
    @dev Transfer using transfer function and updates global RBTC register in MoCState
    @param receiver address of receiver
    @param btcAmount amount in RBTC
  */
  function doTransfer(address payable receiver, uint256 btcAmount) private {
    mocState.subtractRbtcFromSystem(btcAmount);
    receiver.transfer(btcAmount);
  }

  /**
    @dev Transfer using send function and updates global RBTC register in MoCState
    @param receiver address of receiver
    @param btcAmount amount in RBTC
    @return Execution result
  */
  function doSend(address payable receiver, uint256 btcAmount) private returns(bool) {
    // solium-disable-next-line security/no-send
    bool result = receiver.send(btcAmount);

    if (result) {
      mocState.subtractRbtcFromSystem(btcAmount);
    }

    return result;
  }

  /***** STATE MODIFIERS *****/
  modifier whenSettlementReady() {
    require(settlement.isSettlementReady(), "Function can only be called when settlement is ready");
    _;
  }

  modifier atState(MoCState.States _state) {
    require(mocState.state() == _state, "Function cannot be called at this state.");
    _;
  }

  modifier atLeastState(MoCState.States _state) {
    require(mocState.state() >= _state, "Function cannot be called at this state.");
    _;
  }

  modifier atMostState(MoCState.States _state) {
    require(mocState.state() <= _state, "Function cannot be called at this state.");
    _;
  }

  modifier notInProtectionMode() {
    require(mocState.globalCoverage() > mocState.getProtected(), "Function cannot be called at protection mode.");
    _;
  }

  modifier bucketStateTransition(bytes32 bucket) {
    evalBucketLiquidation(bucket);
    _;
  }

  modifier availableBucket(bytes32 bucket) {
    require (bproxManager.isAvailableBucket(bucket), "Bucket is not available");
    _;
  }

  modifier notBaseBucket(bytes32 bucket) {
    require(!bproxManager.isBucketBase(bucket), "Bucket should not be a base type bucket");
    _;
  }

  modifier transitionState()
  {
    mocState.nextState();
    if (mocState.state() == MoCState.States.Liquidated) {
      liquidate();
    }
    else
      _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
