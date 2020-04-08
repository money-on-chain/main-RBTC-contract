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
    uint256 reservePrice
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
    uint256 reservePrice
  );
  event StableTokenMint(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice
  );
  event StableTokenRedeem(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 reservePrice
  );
  event FreeStableTokenRedeem(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 interests,
    uint256 reservePrice
  );

  event RiskProxMint(
    bytes32 bucket,
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 interests,
    uint256 leverage,
    uint256 commission,
    uint256 reservePrice
  );

  event RiskProxRedeem(
    bytes32 bucket,
    address indexed account,
    uint256 commission,
    uint256 amount,
    uint256 reserveTotal,
    uint256 interests,
    uint256 leverage,
    uint256 reservePrice
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
  function mintBPro(address account, uint256 btcAmount)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256)
  {
    uint256 bproRegularPrice = mocState.bproTecPrice();
    uint256 finalBProAmount = 0;
    uint256 btcValue = 0;

    if (mocState.state() == MoCState.States.BProDiscount) {
      uint256 discountPrice = mocState.bproDiscountPrice();
      uint256 bproDiscountAmount = mocConverter.btcToBProDisc(btcAmount);

      finalBProAmount = Math.min(
        bproDiscountAmount,
        mocState.maxBProWithDiscount()
      );
      btcValue = finalBProAmount == bproDiscountAmount
        ? btcAmount
        : mocConverter.bproDiscToBtc(finalBProAmount);

      emit RiskProWithDiscountMint(
        bproRegularPrice,
        discountPrice,
        finalBProAmount
      );
    }

    if (btcAmount != btcValue) {
      uint256 regularBProAmount = mocConverter.btcToBPro(
        btcAmount.sub(btcValue)
      );
      finalBProAmount = finalBProAmount.add(regularBProAmount);
    }

    // START Upgrade V017
    // 01/11/2019 Limiting mint bpro (no with discount)
    // Only enter with no discount state
    if (mocState.state() != MoCState.States.BProDiscount) {
      uint256 availableBPro = Math.min(
        finalBProAmount,
        mocState.maxMintBProAvalaible()
      );
      if (availableBPro != finalBProAmount) {
        btcAmount = mocConverter.bproToBtc(availableBPro);
        finalBProAmount = availableBPro;

        if (btcAmount <= 0) {
          return (0, 0);
        }
      }
    }
    // END Upgrade V017

    uint256 btcCommissionPaid = mocInrate.calcCommissionValue(btcAmount);

    mintBPro(account, btcCommissionPaid, finalBProAmount, btcAmount);

    return (btcAmount, btcCommissionPaid);
  }

  /**
   * @dev Sender burns his BProS and redeems the equivalent BTCs
   * @param bproAmount Amount of BPros to be redeemed
   * @return bitcoins to transfer to the redeemer and commission spent, using [using reservePrecision]
   **/
  function redeemBPro(address account, uint256 bproAmount)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256)
  {
    uint256 userBalance = bproToken.balanceOf(account);
    uint256 userAmount = Math.min(bproAmount, userBalance);

    uint256 bproFinalAmount = Math.min(userAmount, mocState.absoluteMaxBPro());
    uint256 totalBtc = mocConverter.bproToBtc(bproFinalAmount);

    uint256 btcCommission = mocInrate.calcCommissionValue(totalBtc);

    // Mint token
    bproToken.burn(account, bproFinalAmount);

    // Update Buckets
    bproxManager.substractValuesFromBucket(
      BUCKET_C0,
      totalBtc,
      0,
      bproFinalAmount
    );

    uint256 btcTotalWithoutCommission = totalBtc.sub(btcCommission);

    emit RiskProRedeem(
      account,
      bproFinalAmount,
      btcTotalWithoutCommission,
      btcCommission,
      mocState.getBitcoinPrice()
    );

    return (btcTotalWithoutCommission, btcCommission);
  }

  /**
  * @dev Redeems the requested amount for the account, or the max amount of free docs possible.
  * @param account Address of the redeeemer
  * @param docAmount Amount of Docs to redeem [using mocPrecision]
  * @return bitcoins to transfer to the redeemer and commission spent, using [using reservePrecision]

  */
  function redeemFreeDoc(address account, uint256 docAmount)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256)
  {
    if (docAmount <= 0) {
      return (0, 0);
    } else {
      uint256 finalDocAmount = Math.min(
        docAmount,
        Math.min(mocState.freeDoc(), docToken.balanceOf(account))
      );
      uint256 docsBtcValue = mocConverter.docsToBtc(finalDocAmount);

      uint256 btcInterestAmount = mocInrate.calcDocRedInterestValues(
        finalDocAmount,
        docsBtcValue
      );
      uint256 finalBtcAmount = docsBtcValue.sub(btcInterestAmount);
      uint256 btcCommission = mocInrate.calcCommissionValue(finalBtcAmount);

      doDocRedeem(account, finalDocAmount, docsBtcValue);
      bproxManager.payInrate(BUCKET_C0, btcInterestAmount);

      emit FreeStableTokenRedeem(
        account,
        finalDocAmount,
        finalBtcAmount,
        btcCommission,
        btcInterestAmount,
        mocState.getBitcoinPrice()
      );

      return (finalBtcAmount.sub(btcCommission), btcCommission);
    }
  }

  /**
   * @dev Mint Max amount of Docs and give it to the msg.sender
   * @param account minter user address
   * @param btcToMint btc amount the user intents to convert to DoC [using rbtPresicion]
   * @return the actual amount of btc used and the btc commission for them [using rbtPresicion]
   */
  function mintDoc(address account, uint256 btcToMint)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256)
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

      uint256 btcCommission = mocInrate.calcCommissionValue(totalCost);

      emit StableTokenMint(
        account,
        docAmount,
        totalCost,
        btcCommission,
        mocState.getBitcoinPrice()
      );

      return (totalCost, btcCommission);
    }

    return (0, 0);
  }

  /**
   * @dev User DoCs get burned and he receives the equivalent BTCs in return
   * @param userAddress Address of the user asking to redeem
   * @param amount Verified amount of Docs to be redeemed [using mocPrecision]
   * @param btcPrice bitcoin price [using mocPrecision]
   * @return true and commission spent if btc send was completed, false if fails.
   **/
  function redeemDocWithPrice(
    address payable userAddress,
    uint256 amount,
    uint256 btcPrice
  ) public onlyWhitelisted(msg.sender) returns (bool, uint256) {
    uint256 totalBtc = mocConverter.docsToBtcWithPrice(amount, btcPrice);

    uint256 commissionSpent = mocInrate.calcCommissionValue(totalBtc);
    uint256 btcToRedeem = totalBtc.sub(commissionSpent);

    bool result = moc.sendToAddress(userAddress, btcToRedeem);

    // If sends fail, then no redemption is executed
    if (result) {
      doDocRedeem(userAddress, amount, totalBtc);
      emit StableTokenRedeem(
        userAddress,
        amount,
        totalBtc.sub(commissionSpent),
        commissionSpent,
        btcPrice
      );
    }

    return (result, commissionSpent);
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
      emit StableTokenRedeem(origin, userDocBalance, totalRbtc, 0, liqPrice);

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
    uint256 rbtcValue
  ) public onlyWhitelisted(msg.sender) {
    bproToken.mint(account, bproAmount);
    bproxManager.addValuesToBucket(BUCKET_C0, rbtcValue, 0, bproAmount);

    emit RiskProMint(
      account,
      bproAmount,
      rbtcValue,
      btcCommission,
      mocState.getBitcoinPrice()
    );
  }

  /**
   * @dev BUCKET Bprox minting. Mints Bprox for the specified bucket
   * @param account owner of the new minted Bprox
   * @param bucket bucket name
   * @param btcToMint rbtc amount to mint [using reservePrecision]
   * @return total RBTC Spent (btcToMint more interest) and commission spent [using reservePrecision]
   **/
  function mintBProx(address payable account, bytes32 bucket, uint256 btcToMint)
    public
    onlyWhitelisted(msg.sender)
    returns (uint256, uint256)
  {
    if (btcToMint > 0) {
      uint256 lev = mocState.leverage(bucket);

      uint256 finalBtcToMint = Math.min(
        btcToMint,
        mocState.maxBProxBtcValue(bucket)
      );

      // Get interest and the adjusted BProAmount
      uint256 btcInterestAmount = mocInrate.calcMintInterestValues(
        bucket,
        finalBtcToMint
      );

      // pay interest
      bproxManager.payInrate(BUCKET_C0, btcInterestAmount);

      uint256 bproxToMint = mocConverter.btcToBProx(finalBtcToMint, bucket);

      bproxManager.assignBProx(bucket, account, bproxToMint, finalBtcToMint);
      moveExtraFundsToBucket(BUCKET_C0, bucket, finalBtcToMint, lev);

      // Calculate leverage after mint
      lev = mocState.leverage(bucket);

      uint256 btcCommission = mocInrate.calcCommissionValue(finalBtcToMint);

      emit RiskProxMint(
        bucket,
        account,
        bproxToMint,
        finalBtcToMint,
        btcInterestAmount,
        lev,
        btcCommission,
        mocState.getBitcoinPrice()
      );

      return (finalBtcToMint.add(btcInterestAmount), btcCommission);
    }

    return (0, 0);
  }

  /**
   * @dev Sender burns his BProx, redeems the equivalent amount of BPros, return
   * the "borrowed" DOCs and recover pending interests
   * @param account user address to redeem bprox from
   * @param bucket Bucket where the BProxs are hold
   * @param bproxAmount Amount of BProxs to be redeemed [using mocPrecision]
   * @return the actual amount of btc to redeem and the btc commission for them [using reservePrecision]
   **/
  function redeemBProx(
    address payable account,
    bytes32 bucket,
    uint256 bproxAmount
  ) public onlyWhitelisted(msg.sender) returns (uint256, uint256) {
    // Revert could cause not evaluating state changing
    if (bproxManager.bproxBalanceOf(bucket, account) == 0) {
      return (0, 0);
    }

    // Calculate leverage before the redeem
    uint256 bucketLev = mocState.leverage(bucket);
    // Get redeemable value
    uint256 userBalance = bproxManager.bproxBalanceOf(bucket, account);
    uint256 bproxToRedeem = Math.min(bproxAmount, userBalance);
    uint256 rbtcToRedeem = mocConverter.bproxToBtc(bproxToRedeem, bucket);
    // //Pay interests
    uint256 rbtcInterests = recoverInterests(bucket, rbtcToRedeem);

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
      moveExtraFundsToBucket(bucket, BUCKET_C0, rbtcToRedeem, bucketLev);
    }

    uint256 btcCommission = mocInrate.calcCommissionValue(rbtcToRedeem);

    uint256 btcTotalWithoutCommission = rbtcToRedeem.sub(btcCommission);

    emit RiskProxRedeem(
      bucket,
      account,
      btcCommission,
      bproxAmount,
      btcTotalWithoutCommission,
      rbtcInterests,
      bucketLev,
      mocState.getBitcoinPrice()
    );

    return (btcTotalWithoutCommission.add(rbtcInterests), btcCommission);
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

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
