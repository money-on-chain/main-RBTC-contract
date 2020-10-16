pragma solidity 0.5.8;

import "./MoCLibConnection.sol";
import "./token/BProToken.sol";
import "./token/DocToken.sol";
import "./MoCInrate.sol";
import "./base/MoCBase.sol";
import "./MoC.sol";

contract MoCExchangeEvents {
  event RiskProMint(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice
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
    uint256 mocPrice
  );
  event StableTokenMint(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice
  );
  event StableTokenRedeem(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice
  );
  event FreeStableTokenRedeem(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 interests,
    uint256 reservePrice,
    uint256 mocCommissionValue,
    uint256 mocPrice
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
    uint256 mocPrice
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
    uint256 mocPrice
  );
}


contract MoCExchange is MoCExchangeEvents, MoCBase, MoCLibConnection {
  using Math for uint256;
  using SafeMath for uint256;

  // Contracts
  MoCState internal mocState;
  MoCConverter internal mocConverter;
  MoCBProxManager internal bproxManager;
  BProToken internal bproToken;
  DocToken internal docToken;
  MoCInrate internal mocInrate;
  MoC internal moc;

  function initialize(address connectorAddress) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
  }

  /**
   * @dev Mint BPros and give it to the msg.sender
   */
// solium-disable-next-line security/no-assign-params
  function mintBPro(address account, uint256 btcAmount, uint256 mocBalance, uint256 mocAllowance)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256)
  {
    RiskProMintStruct memory details;

    uint256 bproRegularPrice = mocState.bproTecPrice();
    details.finalBProAmount = 0;
    uint256 btcValue = 0;

    if (mocState.state() == MoCState.States.BProDiscount) {
      uint256 discountPrice = mocState.bproDiscountPrice();
      uint256 bproDiscountAmount = mocConverter.btcToBProDisc(btcAmount);

      details.finalBProAmount = Math.min(
        bproDiscountAmount,
        mocState.maxBProWithDiscount()
      );
      btcValue = details.finalBProAmount == bproDiscountAmount
        ? btcAmount
        : mocConverter.bproDiscToBtc(details.finalBProAmount);

      emit RiskProWithDiscountMint(
        bproRegularPrice,
        discountPrice,
        details.finalBProAmount
      );
    }

    if (btcAmount != btcValue) {
      uint256 regularBProAmount = mocConverter.btcToBPro(
        btcAmount.sub(btcValue)
      );
      details.finalBProAmount = details.finalBProAmount.add(regularBProAmount);
    }

    // START Upgrade V017
    // 01/11/2019 Limiting mint bpro (no with discount)
    // Only enter with no discount state
    if (mocState.state() != MoCState.States.BProDiscount) {
      uint256 availableBPro = Math.min(
        details.finalBProAmount,
        mocState.maxMintBProAvalaible()
      );
      if (availableBPro != details.finalBProAmount) {
        btcAmount = mocConverter.bproToBtc(availableBPro);
        details.finalBProAmount = availableBPro;

        if (btcAmount <= 0) {
          return (0, 0, 0);
        }
      }
    }
    // END Upgrade V017

    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Check commission rate in MoC according to transaction type
    details.mocCommissionInBtc = mocInrate.calcCommissionValue(btcAmount, mocInrate.MINT_BPRO_FEES_MOC());

    details.btcCommission = 0;

    // Check if there is enough balance of MoC
    if (mocBalance < details.mocCommissionInBtc || mocAllowance < details.mocCommissionInBtc) {
      // Insufficient funds
      details.mocCommissionInBtc = 0;
      // Check commission rate in RBTC according to transaction type
      details.btcCommission = mocInrate.calcCommissionValue(btcAmount, mocInrate.MINT_BPRO_FEES_RBTC());
    }

    details.mocCommission = mintBPro(account, details.btcCommission, details.finalBProAmount, btcAmount, details.mocCommissionInBtc);

    return (btcAmount, details.btcCommission, details.mocCommission);
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
   * @dev Sender burns his BProS and redeems the equivalent BTCs
   * @param bproAmount Amount of BPros to be redeemed
   * @param mocBalance MoC balance from sender
   * @param mocAllowance MoC allowance from sender
   * @return bitcoins to transfer to the redeemer and commission spent (in BTC and MoC), using [using reservePrecision]
   **/
  function redeemBPro(address account, uint256 bproAmount, uint256 mocBalance, uint256 mocAllowance)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256)
  {
    RiskProRedeemStruct memory details;

    uint256 userBalance = bproToken.balanceOf(account);
    uint256 userAmount = Math.min(bproAmount, userBalance);

    details.bproFinalAmount = Math.min(userAmount, mocState.absoluteMaxBPro());
    uint256 totalBtc = mocConverter.bproToBtc(details.bproFinalAmount);

    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Check commission rate in MoC according to transaction type
    details.mocCommissionInBtc = mocInrate.calcCommissionValue(totalBtc, mocInrate.REDEEM_BPRO_FEES_MOC());

    details.btcCommission = 0;

    // Check if there is enough balance of MoC
    if (mocBalance < details.mocCommissionInBtc || mocAllowance < details.mocCommissionInBtc) {
      // Insufficient funds
      details.mocCommissionInBtc = 0;
      // Check commission rate in RBTC according to transaction type
      details.btcCommission = mocInrate.calcCommissionValue(totalBtc, mocInrate.REDEEM_BPRO_FEES_RBTC());
    }
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

    // Mint token
    bproToken.burn(account, details.bproFinalAmount);

    // Update Buckets
    bproxManager.substractValuesFromBucket(
      BUCKET_C0,
      totalBtc,
      0,
      details.bproFinalAmount
    );

    details.btcTotalWithoutCommission = totalBtc.sub(details.btcCommission);

    uint256 btcPrice = mocState.getBitcoinPrice();
    uint256 mocPrice = mocState.getMoCPrice();

    // Calculate amount in MoC
    details.mocCommission = btcPrice.mul(details.mocCommissionInBtc).div(mocPrice);

    emit RiskProRedeem(
      account,
      details.bproFinalAmount,
      details.btcTotalWithoutCommission,
      details.btcCommission,
      btcPrice,
      details.mocCommission,
      mocPrice
    );

    return (details.btcTotalWithoutCommission, details.btcCommission, details.mocCommission);
  }

  /**
  * @dev Redeems the requested amount for the account, or the max amount of free docs possible.
  * @param account Address of the redeeemer
  * @param docAmount Amount of Docs to redeem [using mocPrecision]
  * @param mocBalance MoC balance from sender
  * @param mocAllowance MoC allowance from sender
  * @return bitcoins to transfer to the redeemer and commission spent (in BTC and MoC), using [using reservePrecision]

  */
  function redeemFreeDoc(address account, uint256 docAmount, uint256 mocBalance, uint256 mocAllowance)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256)
  {
    if (docAmount <= 0) {
      return (0, 0, 0);
    } else {
      FreeStableTokenRedeemStruct memory details;
      details.finalDocAmount = Math.min(
        docAmount,
        Math.min(mocState.freeDoc(), docToken.balanceOf(account))
      );
      uint256 docsBtcValue = mocConverter.docsToBtc(details.finalDocAmount);

      details.btcInterestAmount = mocInrate.calcDocRedInterestValues(
        details.finalDocAmount,
        docsBtcValue
      );
      details.finalBtcAmount = docsBtcValue.sub(details.btcInterestAmount);

      /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
      // Check commission rate in MoC according to transaction type
      details.mocCommissionInBtc = mocInrate.calcCommissionValue(details.finalBtcAmount, mocInrate.REDEEM_DOC_FEES_MOC());

      details.btcCommission = 0;

      // Check if there is enough balance of MoC
      if (mocBalance < details.mocCommissionInBtc || mocAllowance < details.mocCommissionInBtc) {
        // Insufficient funds
        details.mocCommissionInBtc = 0;
        // Check commission rate in RBTC according to transaction type
        details.btcCommission = mocInrate.calcCommissionValue(details.finalBtcAmount, mocInrate.REDEEM_DOC_FEES_RBTC());
      }
      /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

      doDocRedeem(account, details.finalDocAmount, docsBtcValue);
      bproxManager.payInrate(BUCKET_C0, details.btcInterestAmount);

      uint256 btcPrice = mocState.getBitcoinPrice();
      uint256 mocPrice = mocState.getMoCPrice();

      // Calculate amount in MoC
      details.mocCommission = btcPrice.mul(details.mocCommissionInBtc).div(mocPrice);

      emit FreeStableTokenRedeem(
        account,
        details.finalDocAmount,
        details.finalBtcAmount,
        details.btcCommission,
        details.btcInterestAmount,
        btcPrice,
        details.mocCommission,
        mocPrice
      );

      return (details.finalBtcAmount.sub(details.btcCommission), details.btcCommission, details.mocCommission);
    }
  }

  /**
   * @dev Mint Max amount of Docs and give it to the msg.sender
   * @param account minter user address
   * @param btcToMint btc amount the user intents to convert to DoC [using rbtPresicion]
   * @param mocBalance MoC balance from sender
   * @param mocAllowance MoC allowance from sender
   * @return the actual amount of btc used and the btc commission (in BTC and MoC) for them [using rbtPresicion]
   */
  function mintDoc(address account, uint256 btcToMint, uint256 mocBalance, uint256 mocAllowance)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256)
  {
    // Docs to issue with tx value amount
    if (btcToMint > 0) {
      uint256 docs = mocConverter.btcToDoc(btcToMint);
      uint256 docAmount = Math.min(docs, mocState.absoluteMaxDoc());
      uint256 totalCost = docAmount == docs
        ? btcToMint
        : mocConverter.docsToBtc(docAmount);

      // Mint Token
      docToken.mint(account, docAmount);

      // Update Buckets
      bproxManager.addValuesToBucket(BUCKET_C0, totalCost, docAmount, 0);

      /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
      // Check commission rate in MoC according to transaction type
      uint256 mocCommissionInBtc = mocInrate.calcCommissionValue(totalCost, mocInrate.MINT_DOC_FEES_MOC());

      uint256 btcCommission = 0;

      // Check if there is enough balance of MoC
      if (mocBalance < mocCommissionInBtc || mocAllowance < mocCommissionInBtc) {
        // Insufficient funds
        mocCommissionInBtc = 0;

        // Check commission rate in RBTC according to transaction type
        btcCommission = mocInrate.calcCommissionValue(totalCost, mocInrate.MINT_DOC_FEES_RBTC());
      }
      /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

      uint256 btcPrice = mocState.getBitcoinPrice();
      uint256 mocPrice = mocState.getMoCPrice();

      // Calculate amount in MoC
      uint256 mocCommission = btcPrice.mul(mocCommissionInBtc).div(mocPrice);

      emit StableTokenMint(
        account,
        docAmount,
        totalCost,
        btcCommission,
        btcPrice,
        mocCommission,
        mocPrice
      );

      return (totalCost, btcCommission, mocCommission);
    }

    return (0, 0, 0);
  }

  /**
   * @dev User DoCs get burned and he receives the equivalent BTCs in return
   * @param userAddress Address of the user asking to redeem
   * @param amount Verified amount of Docs to be redeemed [using mocPrecision]
   * @param btcPrice bitcoin price [using mocPrecision]
   * @return true and commission spent (in BTC and MoC) if btc send was completed, false if fails.
   **/
  function redeemDocWithPrice(
    address payable userAddress,
    uint256 amount,
    uint256 btcPrice
  ) public onlyWhitelisted(msg.sender) returns (bool, uint256) {
    uint256 totalBtc = mocConverter.docsToBtcWithPrice(amount, btcPrice);

    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Check commission rate in RBTC according to transaction type
    uint256 btcCommission = mocInrate.calcCommissionValue(totalBtc, mocInrate.REDEEM_DOC_FEES_RBTC());
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

    uint256 btcToRedeem = totalBtc.sub(btcCommission);

    bool result = moc.sendToAddress(userAddress, btcToRedeem);

    // If sends fail, then no redemption is executed
    if (result) {
      doDocRedeem(userAddress, amount, totalBtc);
      emit StableTokenRedeem(
        userAddress,
        amount,
        totalBtc.sub(btcCommission),
        btcCommission,
        btcPrice,
        0,
        0
      );
    }

    return (result, btcCommission);
  }

  /**
   * @dev Allow redeem on liquidation state, user DoCs get burned and he receives
   * the equivalent RBTCs according to liquidationPrice
   * @param origin address owner of the DoCs
   * @param destination address to send the RBTC
   * @return The amount of RBTC in sent for the redemption or 0 if send does not succed
   **/
  function redeemAllDoc(address origin, address payable destination)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256)
  {
    uint256 userDocBalance = docToken.balanceOf(origin);
    if (userDocBalance == 0) return 0;

    uint256 liqPrice = mocState.getLiquidationPrice();
    // [USD * RBTC / USD]
    uint256 totalRbtc = mocConverter.docsToBtcWithPrice(
      userDocBalance,
      liqPrice
    );

    // If send fails we don't burn the tokens
    if (moc.sendToAddress(destination, totalRbtc)) {
      docToken.burn(origin, userDocBalance);
      emit StableTokenRedeem(origin, userDocBalance, totalRbtc, 0, liqPrice, 0, 0);

      return totalRbtc;
    } else {
      return 0;
    }
  }

  /**
    @dev  Mint the amount of BPros
    @param account Address that will owned the BPros
    @param bproAmount Amount of BPros to mint [using mocPrecision]
    @param rbtcValue RBTC cost of the minting [using reservePrecision]
  */
  function mintBPro(
    address account,
    uint256 btcCommission,
    uint256 bproAmount,
    uint256 rbtcValue,
    uint256 mocCommissionInBtc
  ) public onlyWhitelisted(msg.sender) 
    returns (uint256) {
    bproToken.mint(account, bproAmount);
    bproxManager.addValuesToBucket(BUCKET_C0, rbtcValue, 0, bproAmount);

    uint256 btcPrice = mocState.getBitcoinPrice();
    uint256 mocPrice = mocState.getMoCPrice();

    // Calculate amount in MoC
    uint256 mocCommission = btcPrice.mul(mocCommissionInBtc).div(mocPrice);

    emit RiskProMint(
      account,
      bproAmount,
      rbtcValue,
      btcCommission,
      btcPrice,
      mocCommission,
      mocPrice
    );

    return mocCommission;
  }

  /**
   * @dev BUCKET Bprox minting. Mints Bprox for the specified bucket
   * @param account owner of the new minted Bprox
   * @param bucket bucket name
   * @param btcToMint rbtc amount to mint [using reservePrecision]
   * @param mocBalance MoC balance from sender
   * @param mocAllowance MoC allowance from sender
   * @return total RBTC Spent (btcToMint more interest) and commission spent (in BTC and MoC) [using reservePrecision]
   **/
  function mintBProx(address payable account, bytes32 bucket, uint256 btcToMint, uint256 mocBalance, uint256 mocAllowance)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256, uint256)
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

      details.bproxToMint = mocConverter.btcToBProx(details.finalBtcToMint, bucket);

      bproxManager.assignBProx(bucket, account, details.bproxToMint, details.finalBtcToMint);
      moveExtraFundsToBucket(BUCKET_C0, bucket, details.finalBtcToMint, details.lev);

      // Calculate leverage after mint
      details.lev = mocState.leverage(bucket);

      /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
      // Check commission rate in MoC according to transaction type
      details.mocCommissionInBtc = mocInrate.calcCommissionValue(details.finalBtcToMint, mocInrate.MINT_BTCX_FEES_MOC());

      details.btcCommission = 0;

      // Check if there is enough balance of MoC
      if (mocBalance < details.mocCommissionInBtc || mocAllowance < details.mocCommissionInBtc) {
        // Insufficient funds
        details.mocCommissionInBtc = 0;

        // Check commission rate in RBTC according to transaction type
        details.btcCommission = mocInrate.calcCommissionValue(details.finalBtcToMint, mocInrate.MINT_BTCX_FEES_RBTC());
      }
      /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

      uint256 btcPrice = mocState.getBitcoinPrice();
      uint256 mocPrice = mocState.getMoCPrice();

      // Calculate amount in MoC
      details.mocCommission = btcPrice.mul(details.mocCommissionInBtc).div(mocPrice);

      emit RiskProxMint(
        bucket,
        account,
        details.bproxToMint,
        details.finalBtcToMint,
        details.btcInterestAmount,
        details.lev,
        details.btcCommission,
        btcPrice,
        details.mocCommission,
        mocPrice
      );

      return (details.finalBtcToMint.add(details.btcInterestAmount), details.btcCommission, details.mocCommission);
    }

    return (0, 0, 0);
  }

  /**
   * @dev Sender burns his BProx, redeems the equivalent amount of BPros, return
   * the "borrowed" DOCs and recover pending interests
   * @param account user address to redeem bprox from
   * @param bucket Bucket where the BProxs are hold
   * @param bproxAmount Amount of BProxs to be redeemed [using mocPrecision]
   * @param mocBalance MoC balance from sender
   * @param mocAllowance MoC allowance from sender
   * @return the actual amount of btc to redeem and the btc commission (in BTC and MoC) for them [using reservePrecision]
   **/
  function redeemBProx(
    address payable account,
    bytes32 bucket,
    uint256 bproxAmount,
    uint256 mocBalance,
    uint256 mocAllowance
  ) public onlyWhitelisted(msg.sender) returns (uint256, uint256, uint256) {
    // Revert could cause not evaluating state changing
    if (bproxManager.bproxBalanceOf(bucket, account) == 0) {
      return (0, 0, 0);
    }

    uint256 totalBtcRedeemed;
    uint256 mocCommission;
    uint256 btcCommission;

    (totalBtcRedeemed, btcCommission, mocCommission) = redeemBProxInternal(account, bucket, bproxAmount, mocBalance, mocAllowance);

    return (totalBtcRedeemed, btcCommission, mocCommission);
  }

  /**
   * @dev Internal function to avoid stack too deep errors
   * @param account user address to redeem bprox from
   * @param bucket Bucket where the BProxs are hold
   * @param bproxAmount Amount of BProxs to be redeemed [using mocPrecision]
   * @param mocBalance MoC balance from sender
   * @param mocAllowance MoC allowance from sender
   * @return the actual amount of btc to redeem and the btc commission (in BTC and MoC) for them [using reservePrecision]
   **/
  function redeemBProxInternal(
    address payable account,
    bytes32 bucket,
    uint256 bproxAmount,
    uint256 mocBalance,
    uint256 mocAllowance
  ) internal returns (uint256, uint256, uint256) {
    RiskProxRedeemStruct memory details;
    // Calculate leverage before the redeem
    details.bucketLev = mocState.leverage(bucket);
    // Get redeemable value
    uint256 bproxToRedeem = Math.min(bproxAmount, bproxManager.bproxBalanceOf(bucket, account));
    uint256 rbtcToRedeem = mocConverter.bproxToBtc(bproxToRedeem, bucket);
    // //Pay interests
    details.rbtcInterests = recoverInterests(bucket, rbtcToRedeem);

    // Burn Bprox
    burnBProxFor(
      bucket,
      account,
      bproxToRedeem,
      mocState.bucketBProTecPrice(bucket)
    );

    if (bproxManager.getBucketNBPro(bucket) == 0) {
      // If there is no BProx left, empty bucket for rounding remnant
      bproxManager.emptyBucket(bucket, BUCKET_C0);
    } else {
      // Move extra value from L bucket to C0
      moveExtraFundsToBucket(bucket, BUCKET_C0, rbtcToRedeem, details.bucketLev);
    }

    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    // Check commission rate in MoC according to transaction type
    details.mocCommissionInBtc = mocInrate.calcCommissionValue(rbtcToRedeem, mocInrate.REDEEM_BTCX_FEES_MOC());

    details.btcCommission = 0;

    // Check if there is enough balance of MoC
    if (mocBalance < details.mocCommissionInBtc || mocAllowance < details.mocCommissionInBtc) {
      // Insufficient funds
      details.mocCommissionInBtc = 0;

      // Check commission rate in RBTC according to transaction type
      details.btcCommission = mocInrate.calcCommissionValue(rbtcToRedeem, mocInrate.REDEEM_BTCX_FEES_RBTC());
    }
    /** END UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/

    details.btcTotalWithoutCommission = rbtcToRedeem.sub(details.btcCommission);

    uint256 btcPrice = mocState.getBitcoinPrice();
    uint256 mocPrice = mocState.getMoCPrice();

    // Calculate amount in MoC
    uint256 mocCommission = btcPrice.mul(details.mocCommissionInBtc).div(mocPrice);

    emit RiskProxRedeem(
      bucket,
      account,
      details.btcCommission,
      bproxAmount,
      details.btcTotalWithoutCommission,
      details.rbtcInterests,
      details.bucketLev,
      btcPrice,
      details.mocCommission,
      mocPrice
    );

    return (details.btcTotalWithoutCommission.add(details.rbtcInterests), details.btcCommission, details.mocCommission);
  }

  /**
    @dev Burns user BProx and sends the equivalent amount of RBTC
    to the account without caring if transaction succeeds
    @param bucket Bucket where the BProxs are hold
    @param account user address to redeem bprox from
    @param bproxAmount Amount of BProx to redeem [using mocPrecision]
    @param bproxPrice Price of one BProx in RBTC [using reservePrecision]
    @return result of the RBTC sending transaction [using reservePrecision]
  **/
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

  **/
  function burnBProxFor(
    bytes32 bucket,
    address payable account,
    uint256 bproxAmount,
    uint256 bproxPrice
  ) public onlyWhitelisted(msg.sender) returns (uint256) {
    // Calculate total RBTC
    uint256 btcTotalAmount = mocConverter.bproToBtcWithPrice(
      bproxAmount,
      bproxPrice
    );
    bproxManager.removeBProx(bucket, account, bproxAmount, btcTotalAmount);

    return btcTotalAmount;
  }

  /**
    @dev Calculates the amount of RBTC that one bucket should move to another in
    BProx minting/redemption. This extra makes BProx more leveraging than BPro.
    @param bucketFrom Origin bucket from which the BTC are moving
    @param bucketTo Destination bucket to which the BTC are moving
    @param totalBtc Amount of BTC moving between buckets [using reservePrecision]
    @param lev lev of the L bucket [using mocPrecision]
  **/
  function moveExtraFundsToBucket(
    bytes32 bucketFrom,
    bytes32 bucketTo,
    uint256 totalBtc,
    uint256 lev
  ) internal {
    uint256 btcToMove = mocLibConfig.bucketTransferAmount(totalBtc, lev);
    uint256 docsToMove = mocConverter.btcToDoc(btcToMove);

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
   * @dev Returns RBTCs for user in concept of interests refund
   * @param bucket Bucket where the BProxs are hold
   * @param rbtcToRedeem Total RBTC value of the redemption [using reservePrecision]
   * @return Interests [using reservePrecision]
   **/
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
    moc = MoC(connector.moc());
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = MoCState(connector.mocState());
    mocConverter = MoCConverter(connector.mocConverter());
    mocInrate = MoCInrate(connector.mocInrate());
  }


  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0110: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  struct RiskProxRedeemStruct{
    uint256 btcCommission;
    uint256 btcTotalWithoutCommission;
    uint256 rbtcInterests;
    uint256 bucketLev;
    uint256 mocCommission;
    uint256 mocCommissionInBtc;
  }

  struct RiskProxMintStruct{
    uint256 bproxToMint;
    uint256 finalBtcToMint;
    uint256 btcInterestAmount;
    uint256 lev;
    uint256 btcCommission;
    uint256 mocCommission;
    uint256 mocCommissionInBtc;
  }

  struct RiskProRedeemStruct{
    uint256 bproFinalAmount;
    uint256 btcTotalWithoutCommission;
    uint256 btcCommission;
    uint256 mocCommission;
    uint256 mocCommissionInBtc;
  }

  struct FreeStableTokenRedeemStruct{
    uint256 finalDocAmount;
    uint256 finalBtcAmount;
    uint256 btcCommission;
    uint256 btcInterestAmount;
    uint256 mocCommission;
    uint256 mocCommissionInBtc;
  }

  struct RiskProMintStruct{
    uint256 finalBProAmount;
    uint256 btcCommission;
    uint256 mocCommission;
    uint256 mocCommissionInBtc;
  }

  /** END UPDATE V0110: 24/09/2020 **/

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
