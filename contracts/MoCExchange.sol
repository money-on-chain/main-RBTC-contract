pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "./MoCLibConnection.sol";
import "./token/BProToken.sol";
import "./token/DocToken.sol";
import "./interface/IMoCInrate.sol";
import "./base/MoCBase.sol";
import "./token/MoCToken.sol";
import "./MoCBProxManager.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "./interface/IMoC.sol";
import "./interface/IMoCExchange.sol";
import "./interface/IMoCState.sol";

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
