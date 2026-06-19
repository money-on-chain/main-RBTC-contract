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
  // Kept for ABI/backward compatibility, discount mint path is disabled.
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

      details.finalBtcAmount = docsBtcValue;

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
      0,
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

  /** END UPDATE V0112: 24/09/2020 **/

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
