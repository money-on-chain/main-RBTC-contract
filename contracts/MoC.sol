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
    initializeContracts();
    initializeGovernanceContracts(stopperAddress, governorAddress, startStoppable);
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
  function mintBPro(uint256 btcToMint) public payable whenNotPaused() transitionState() {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Get balance and allowance from sender
    (uint256 mocBalance, uint256 mocAllowance) = getMocTokenBalance(msg.sender, address(this));

    // Pass balance and allowance parameters to exchange
    // Calculate commissions in exchange
    uint256 totalBtcSpent;
    uint256 btcCommission;
    uint256 mocCommission;
    (totalBtcSpent, btcCommission, mocCommission) = mocExchange.mintBPro(msg.sender, btcToMint, mocBalance, mocAllowance);

    totalBtcSpent = transferMocComission(msg.sender, msg.value, totalBtcSpent, btcCommission, mocCommission);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

    // Need to update general State
    mocState.addToRbtcInSystem(msg.value);
    // Calculate change
    uint256 change = msg.value.sub(totalBtcSpent);
    doTransfer(msg.sender, change);
    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), btcCommission);
  }

  /**
   * @dev Redeems Bpro Tokens and pays the comissions of the operation in RBTC
     @param bproAmount Amout in Bpro
   */
  function redeemBPro(uint256 bproAmount) public whenNotPaused() transitionState() atLeastState(MoCState.States.AboveCobj) {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 mocBalance, uint256 mocAllowance) = getMocTokenBalance(msg.sender, address(this));

    // Pass balance and allowance parameters to exchange
    // Calculate commissions in exchange
    uint256 btcAmount;
    uint256 btcCommission;
    uint256 mocCommission;
    (btcAmount, btcCommission, mocCommission) = mocExchange.redeemBPro(msg.sender, bproAmount, mocBalance, mocAllowance);

    doTransfer(msg.sender, btcAmount);

    // Check if there is enough balance of MoC
    redeemWithMocFees(msg.sender, btcCommission, mocCommission);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
   * @dev Mint Doc tokens and pays the commisions of the operation
   * @param btcToMint Amount in RBTC to mint
   */
  function mintDoc(uint256 btcToMint) public payable whenNotPaused() transitionState() atLeastState(MoCState.States.AboveCobj) {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Get balance and allowance from sender
    (uint256 mocBalance, uint256 mocAllowance) = getMocTokenBalance(msg.sender, address(this));

    // Pass balance and allowance parameters to exchange
    // Calculate commissions in exchange
    uint256 totalBtcSpent;
    uint256 btcCommission;
    uint256 mocCommission;
    (totalBtcSpent, btcCommission, mocCommission) = mocExchange.mintDoc(msg.sender, btcToMint, mocBalance, mocAllowance);

    totalBtcSpent = transferMocComission(msg.sender, msg.value, totalBtcSpent, btcCommission, mocCommission);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

    // Need to update general State
    mocState.addToRbtcInSystem(msg.value);

    // Calculate change
    uint256 change = msg.value.sub(totalBtcSpent);
    doTransfer(msg.sender, change);

    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), btcCommission);
  }

  /**
     @dev Redeems Bprox Tokens and pays the comissions of the operation in RBTC
     @param bucket Bucket to reedem, for example X2
     @param bproxAmount Amount in Bprox
   */
  function redeemBProx(bytes32 bucket, uint256 bproxAmount) public
  whenNotPaused() whenSettlementReady() availableBucket(bucket) notBaseBucket(bucket)
  transitionState() bucketStateTransition(bucket) {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Get balance and allowance from sender
    (uint256 mocBalance, uint256 mocAllowance) = getMocTokenBalance(msg.sender, address(this));

    // Pass balance and allowance parameters to exchange
    // Calculate commissions in exchange
    uint256 totalBtcRedeemed;
    uint256 btcCommission;
    uint256 mocCommission;
    (totalBtcRedeemed, btcCommission, mocCommission) = mocExchange.redeemBProx(msg.sender, bucket, bproxAmount, mocBalance, mocAllowance);

    doTransfer(msg.sender, totalBtcRedeemed);

    // Check if there is enough balance of MoC
    redeemWithMocFees(msg.sender, btcCommission, mocCommission);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
  * @dev BUCKET bprox minting
  * @param bucket Name of the bucket used
  * @param btcToMint amount to mint on RBTC
  **/
  function mintBProx(bytes32 bucket, uint256 btcToMint) public payable
  whenNotPaused() whenSettlementReady() availableBucket(bucket) notBaseBucket(bucket)
  transitionState() bucketStateTransition(bucket) {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Get balance and allowance from sender
    (uint256 mocBalance, uint256 mocAllowance) = getMocTokenBalance(msg.sender, address(this));

    // Pass balance and allowance parameters to exchange
    // Calculate commissions in exchange
    uint256 totalBtcSpent;
    uint256 btcCommission;
    uint256 mocCommission;
    (totalBtcSpent, btcCommission, mocCommission) = mocExchange.mintBProx(msg.sender, bucket, btcToMint, mocBalance, mocAllowance);

    totalBtcSpent = transferMocComission(msg.sender, msg.value, totalBtcSpent, btcCommission, mocCommission);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

    // Need to update general State
    mocState.addToRbtcInSystem(msg.value);
    // Calculate change
    uint256 change = msg.value.sub(totalBtcSpent);
    doTransfer(msg.sender, change);

    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), btcCommission);
  }

  /**
  * @dev Redeems the requested amount for the msg.sender, or the max amount of free docs possible.
  * @param docAmount Amount of Docs to redeem.
  */
  function redeemFreeDoc(uint256 docAmount) public whenNotPaused() transitionState() {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Get balance and allowance from sender
    (uint256 mocBalance, uint256 mocAllowance) = getMocTokenBalance(msg.sender, address(this));

    // Pass balance and allowance parameters to exchange
    // Calculate commissions in exchange
    uint256 btcAmount;
    uint256 btcCommission;
    uint256 mocCommission;
    (btcAmount, btcCommission, mocCommission) = mocExchange.redeemFreeDoc(msg.sender, docAmount, mocBalance, mocAllowance);

    doTransfer(msg.sender, btcAmount);

    // Check if there is enough balance of MoC
    redeemWithMocFees(msg.sender, btcCommission, mocCommission);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
  * @dev Allow redeem on liquidation state, user DoCs get burned and he receives
  * the equivalent BTCs if can be covered, or the maximum available
  **/
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
  * @dev Pays the BitPro interest and transfers it to the address mocInrate.bitProInterestAddress
  * BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function payBitProHoldersInterestPayment() public whenNotPaused() {
    uint256 toPay = mocInrate.payBitProHoldersInterestPayment();
    if (doSend(mocInrate.getBitProInterestAddress(), toPay)) {
      bproxManager.substractValuesFromBucket(BUCKET_C0, toPay, 0, 0);
    }
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
      pauseBProToken();
      sendRbtcRemainder();
      liquidationExecuted = true;
    }
  }

  /**
    @dev Transfer the value that not corresponds to
    Doc Collateral
  */
  function sendRbtcRemainder() internal {
    uint256 bitProRBTCValue = mocState.getRbtcRemainder();
    doTransfer(mocInrate.commissionsAddress(), bitProRBTCValue);
  }

  function initializeContracts() internal {
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = MoCState(connector.mocState());
    settlement = MoCSettlement(connector.mocSettlement());
    mocConverter = MoCConverter(connector.mocConverter());
    mocExchange = MoCExchange(connector.mocExchange());
    mocInrate = MoCInrate(connector.mocInrate());
    mocBurnout = MoCBurnout(connector.mocBurnout());
    mocToken = MoCToken(mocState.getMoCToken());
  }

  function initializeGovernanceContracts(address stopperAddress, address governorAddress, bool startStoppable) internal {
    Stoppable.initialize(stopperAddress, IGovernor(governorAddress), startStoppable);
  }

  function pauseBProToken() internal {
    if (!bproToken.paused()) {
      bproToken.pause();
    }
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0110: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Internal functions **/

  // solium-disable-next-line security/no-assign-params
  function transferMocComission(address sender, uint256 value, uint256 totalBtcSpent, uint256 btcCommission, uint256 mocCommission)
  internal returns(uint256) {
    // Check if there is enough balance of MoC
    if (mocCommission > 0) {
      // Transfer MoC from sender to this contract
      mocToken.transferFrom(sender, address(this), mocCommission);
      // Transfer MoC to commissions address
      mocToken.transfer(mocInrate.commissionsAddress(), mocCommission);
    } else {
      // Check commission rate in RBTC according to transaction type
      totalBtcSpent = totalBtcSpent.add(btcCommission);
      require(totalBtcSpent <= value, "amount is not enough");
    }
    return totalBtcSpent;
  }

  function redeemWithMocFees(address sender, uint256 btcCommission, uint256 mocCommission) internal {
    // Check if there is enough balance of MoC
    if (mocCommission > 0) {
      // Transfer MoC from sender to this contract
      mocToken.transferFrom(sender, address(this), mocCommission);
      // Transfer MoC to commissions address
      mocToken.transfer(mocInrate.commissionsAddress(), mocCommission);
    } else {
      // Transfer commissions to commissions address
      doTransfer(mocInrate.commissionsAddress(), btcCommission);
    }
  }

  function getMocTokenBalance(address owner, address spender) internal view returns (uint256, uint256) {
    uint256 mocBalance = 0;
    uint256 mocAllowance = 0;

    if (address(mocToken) != address(0)) {
      // Get balance and allowance from sender
      mocBalance = mocToken.balanceOf(owner);
      mocAllowance = mocToken.allowance(owner, spender);
    }

    return (mocBalance, mocAllowance);
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
    require(settlement.isSettlementReady(), "Only when settlement is ready");
    _;
  }

  modifier atState(MoCState.States _state) {
    require(mocState.state() == _state, "Cannot be called at this state");
    _;
  }

  modifier atLeastState(MoCState.States _state) {
    require(mocState.state() >= _state, "Cannot be called at this state");
    _;
  }

  modifier atMostState(MoCState.States _state) {
    require(mocState.state() <= _state, "Cannot be called at this state");
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
    require(!bproxManager.isBucketBase(bucket), "Shouldn't be a base type bucket");
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


  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0110: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  //MoCToken mocToken;
  MoCToken mocToken;
  /** END UPDATE V0110: 24/09/2020 **/

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
