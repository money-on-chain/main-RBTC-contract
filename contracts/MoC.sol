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
import "./MoCBurnout.sol";
import "./base/MoCBase.sol";
import "moc-governance/contracts/Stopper/Stoppable.sol";
import "moc-governance/contracts/Governance/IGovernor.sol";
import "./token/MoCToken.sol";
import "./MoCVendors.sol";

contract MoCEvents {
  event BucketLiquidation(bytes32 bucket);

  event SetMoCContract(address mocAddress);
}

contract MoC is MoCEvents, MoCLibConnection, MoCBase, Stoppable  {
  using SafeMath for uint256;

  // Contracts
  DocToken internal docToken;
  BProToken internal bproToken;
  MoCBProxManager internal bproxManager;
  MoCState internal mocState;
  MoCConverter internal mocConverter;
  MoCSettlement internal settlement;
  MoCExchange internal mocExchange;
  MoCInrate internal mocInrate;
  MoCBurnout public mocBurnout;

  // Indicates if Rbtc remainder was sent and
  // BProToken was paused
  bool internal liquidationExecuted;

  // Fallback
  //TODO: We must research if fallback function is really needed.
  function() external payable whenNotPaused() transitionState() {
    bproxManager.addValuesToBucket(BUCKET_C0, msg.value, 0, 0);
    mocState.addToRbtcInSystem(msg.value);
  }

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
    mocBurnout = MoCBurnout(connector.mocBurnout());
    //initializeGovernanceContracts
    Stoppable.initialize(stopperAddress, IGovernor(governorAddress), startStoppable);
  }

  /****************************INTERFACE*******************************************/

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
    @dev returns current redeem queue size
   */
  function redeemQueueSize() public view returns(uint256) {
    return settlement.redeemQueueSize();
  }

  /**
    @dev returns the total amount of Docs in the redeem queue for redeemer
    @param redeemer address for which ^ is computed
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
    @dev Mints BPRO and pays the comissions of the operation.
    @param btcToMint Amount un BTC to mint
   */
  function mintBPro(uint256 btcToMint, address vendorAccount) public payable whenNotPaused() transitionState() {
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
   * @dev Redeems Bpro Tokens and pays the comissions of the operation
     @param bproAmount Amout in Bpro
   */
  function redeemBPro(uint256 bproAmount, address vendorAccount)
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
   * @dev Mint Doc tokens and pays the commisions of the operation
   * @param btcToMint Amount in RBTC to mint
   */
  function mintDoc(uint256 btcToMint, address vendorAccount)
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
     @dev Redeems Bprox Tokens and pays the comissions of the operation in RBTC
     @param bucket Bucket to reedem, for example X2
     @param bproxAmount Amount in Bprox
   */
  function redeemBProx(bytes32 bucket, uint256 bproxAmount, address vendorAccount) public
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
  * @dev BUCKET bprox minting
  * @param bucket Name of the bucket used
  * @param btcToMint amount to mint on RBTC
  **/
  function mintBProx(bytes32 bucket, uint256 btcToMint, address vendorAccount) public payable
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
  * @dev Redeems the requested amount for the msg.sender, or the max amount of free docs possible.
  * @param docAmount Amount of Docs to redeem.
  */
  function redeemFreeDoc(uint256 docAmount, address vendorAccount) public whenNotPaused() transitionState() {
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
  * @dev Allow redeem on liquidation state, user DoCs get burned and he receives
  * the equivalent BTCs if can be covered, or the maximum available
  **/
  function redeemAllDoc() public {
    require(mocState.state() == MoCState.States.Liquidated, "Not Liquidated state");
    mocExchange.redeemAllDoc(msg.sender, msg.sender);
  }

  /**
    @dev Moves the daily amount of interest rate to C0 bucket
  */
  function dailyInratePayment() public whenNotPaused() {
    mocInrate.dailyInratePayment();
  }

  /**
  * @dev Pays the BitPro interest and transfers it to the address mocInrate.bitProInterestAddress
  * BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function payBitProHoldersInterestPayment() public whenNotPaused() {
    uint256 toPay = mocInrate.payBitProHoldersInterestPayment();
    if (doSend(mocInrate.getBitProInterestAddress(), toPay)) {
      bproxManager.substractValuesFromBucket(BUCKET_C0, toPay, 0, 0);
    }
    bproxManager.substractValuesFromBucket(BUCKET_C0, toPay, 0, 0);
  }

  /**
  * @dev Calculates BitPro holders holder interest by taking the total amount of RBCs available on Bucket 0.
  * BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function calculateBitProHoldersInterest() public view returns(uint256, uint256) {
    return mocInrate.calculateBitProHoldersInterest();
  }

  function getBitProInterestAddress() public view returns(address payable) {
    return mocInrate.getBitProInterestAddress();
  }

  function getBitProRate() public view returns(uint256) {
    return mocInrate.getBitProRate();
  }

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
    @dev Returns true if blockSpan number of blocks has pass since last execution
  */
  function isSettlementEnabled() public view returns(bool) {
    return settlement.isSettlementEnabled();
  }

  /**
   * @dev Checks if bucket liquidation is reached.
   * @return true if bucket liquidation is reached, false otherwise
   */
  function isBucketLiquidationReached(bytes32 bucket) public view returns(bool) {
    if (mocState.coverage(bucket) <= mocState.liq()) {
      return true;
    }
    return false;
  }

  function evalBucketLiquidation(bytes32 bucket) public availableBucket(bucket) notBaseBucket(bucket) whenSettlementReady() {
    if (mocState.coverage(bucket) <= mocState.liq()) {
      bproxManager.liquidateBucket(bucket, BUCKET_C0);

      emit BucketLiquidation(bucket);
    }
  }

  /**
  * @dev Set Burnout address.
  * @param burnoutAddress Address to which the funds will be sent on liquidation.
  */
  function setBurnoutAddress(address payable burnoutAddress) public whenNotPaused() atLeastState(MoCState.States.BProDiscount) {
    mocBurnout.pushBurnoutAddress(msg.sender, burnoutAddress);
  }

  /**
  * @dev Get Burnout address.
  */
  function getBurnoutAddress() public view returns(address) {
    return mocBurnout.getBurnoutAddress(msg.sender);
  }

  /**
  * @dev Evaluates if liquidation state has been reached and runs liq if that's the case
  */
  function evalLiquidation(uint256 steps) public {
    mocState.nextState();

    if (mocState.state() == MoCState.States.Liquidated) {
      liquidate();
      mocBurnout.executeBurnout(steps);
    }
  }

  /**
  * @dev Runs all settlement process
  */
  function runSettlement(uint256 steps) public whenNotPaused() transitionState() {
    uint256 accumCommissions = settlement.runSettlement(steps);

    // Transfer accums commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), accumCommissions);
  }

  /**
  * @dev Send RBTC to a user and update RbtcInSystem in MoCState
  * @return result of the transaction
  **/
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
    }
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0110: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Internal functions **/

  // solium-disable-next-line security/no-assign-params, max-len
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

    transferMocCommission(sender, mocCommission, vendorAccount, mocMarkup, totalMoCFee);

    transferBtcCommission(mocLibConfig.getPayableAddress(vendorAccount), btcCommission, btcMarkup);

    // Need to update general State
    mocState.addToRbtcInSystem(value);
    // Calculate change
    uint256 change = value.sub(totalBtcSpent);
    doTransfer(sender, change);
  }

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
          mocVendors.getTotalPaidInMoC(vendorAccount).add(totalMoCFee) <= mocVendors.getStaking(vendorAccount)) {
        // Transfer MoC to vendor address
        mocToken.transfer(vendorAccount, mocMarkup);
        // Update vendor's markup
        mocVendors.updatePaidMarkup(vendorAccount, mocMarkup, 0, mocMarkup);
        // Set commission to transfer
        totalMoCFee = mocCommission;
      }
      // Transfer MoC to commissions address
        mocToken.transfer(mocInrate.commissionsAddress(), totalMoCFee);
    }
  }

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
    } else {
      transferBtcCommission(mocLibConfig.getPayableAddress(vendorAccount), btcCommission, btcMarkup);
    }

    transferMocCommission(sender, mocCommission, vendorAccount, mocMarkup, totalMoCFee);
  }

  function transferBtcCommission(address payable vendorAccount, uint256 btcCommission, uint256 btcMarkup) internal {
    MoCVendors mocVendors = MoCVendors(mocState.getMoCVendors());

    uint256 totalBtcFee = btcCommission.add(btcMarkup);
    (uint256 totalMoCFee, , ) = mocExchange.convertToMoCPrice(totalBtcFee);
    (uint256 btcMarkupInMoC, , ) = mocExchange.convertToMoCPrice(btcMarkup);

    // Transfer vendor markup in MoC
    if (mocVendors.getIsActive(vendorAccount) &&
        mocVendors.getTotalPaidInMoC(vendorAccount).add(totalMoCFee) <= mocVendors.getStaking(vendorAccount)) {
      // Transfer RBTC to vendor address
      doTransfer(vendorAccount, btcMarkup);
      // Update vendor's markup
      mocVendors.updatePaidMarkup(vendorAccount, 0, btcMarkup, btcMarkupInMoC);
      // Transfer RBTC to commissions address
      doTransfer(mocInrate.commissionsAddress(), btcCommission);
    } else {
      // Transfer MoC to commissions address
      doTransfer(mocInrate.commissionsAddress(), totalBtcFee);
    }
  }

  /** END UPDATE V0110: 24/09/2020 **/

  /**
  * @dev Transfer using transfer function and updates global RBTC register in MoCState
  **/
  function doTransfer(address payable receiver, uint256 btcAmount) private {
    mocState.subtractRbtcFromSystem(btcAmount);
    receiver.transfer(btcAmount);
  }

  /**
  * @dev Transfer using send function and updates global RBTC register in MoCState
  * @return Execution result
  **/
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
    require(settlement.isSettlementReady(), "Settlement is not ready");
    _;
  }

  modifier atLeastState(MoCState.States _state) {
    require(mocState.state() >= _state, "Can't call it at this state");
    _;
  }

  modifier bucketStateTransition(bytes32 bucket) {
    evalBucketLiquidation(bucket);
    _;
  }

  modifier availableBucket(bytes32 bucket) {
    require (bproxManager.isAvailableBucket(bucket), "Bucket not available");
    _;
  }

  modifier notBaseBucket(bytes32 bucket) {
    require(!bproxManager.isBucketBase(bucket), "shouldn't be base bucket");
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
