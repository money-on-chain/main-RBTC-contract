const { BigNumber } = require('bignumber.js');
const chai = require('chai');
const { toContract, toBigNumber } = require('../../utils/numberHelper');
const { toContractBNNoPrec } = require('./formatHelper');

// Changers
const SetCommissionFinalAddressChanger = artifacts.require(
  './contracts/SetCommissionFinalAddressChanger.sol'
);
const SetCommissionMocProportionChanger = artifacts.require(
  './contracts/SetCommissionMocProportionChanger.sol'
);

const SETTLEMENT_STEPS = 100;
const BUCKET_C0 = web3.utils.asciiToHex('C0', 32);
const BUCKET_X2 = web3.utils.asciiToHex('X2', 32);

const { BN, isBN } = web3.utils;

chai.use(require('chai-bn')(BN)).should();

const zeroAddress = '0x0000000000000000000000000000000000000000';

const comissionsTxType = {
  MINT_BPRO_FEES_RBTC: new BN(1),
  REDEEM_BPRO_FEES_RBTC: new BN(2),
  MINT_DOC_FEES_RBTC: new BN(3),
  REDEEM_DOC_FEES_RBTC: new BN(4),
  MINT_BTCX_FEES_RBTC: new BN(5),
  REDEEM_BTCX_FEES_RBTC: new BN(6),
  MINT_BPRO_FEES_MOC: new BN(7),
  REDEEM_BPRO_FEES_MOC: new BN(8),
  MINT_DOC_FEES_MOC: new BN(9),
  REDEEM_DOC_FEES_MOC: new BN(10),
  MINT_BTCX_FEES_MOC: new BN(11),
  REDEEM_BTCX_FEES_MOC: new BN(12)
};

// Mock BTC price provider doesn't use second and third parameter
const setBitcoinPrice = btcPriceProvider => async btcPrice =>
  btcPriceProvider.post(toContract(btcPrice), 0, btcPriceProvider.address);

const getBitcoinPrice = btcPriceProvider => async () => {
  const priceValue = await btcPriceProvider.peek();
  return priceValue['0'];
};

// Mock MoC price provider doesn't use second and third parameter
const setMoCPrice = mocPriceProvider => async mocPrice =>
  mocPriceProvider.post(toContract(mocPrice), 0, mocPriceProvider.address);

const getMoCPrice = mocPriceProvider => async () => {
  const priceValue = await mocPriceProvider.peek();
  return priceValue['0'];
};

const setSmoothingFactor = (governor, mockMocStateChanger) => async _coeff => {
  const coeff = isBN(_coeff) ? _coeff : toContractBNNoPrec(_coeff);
  await mockMocStateChanger.setSmoothingFactor(coeff);
  const setSmooth = await governor.executeChange(mockMocStateChanger.address);

  return setSmooth;
};

const redeemFreeDoc = moc => async ({ userAccount, docAmount, vendorAccount }) => {
  let _vendorAccount = vendorAccount;
  if (!vendorAccount) {
    _vendorAccount = zeroAddress;
  }

  const docPrecision = await moc.getMocPrecision();
  const formattedAmount = toContract(docAmount * docPrecision);

  return _vendorAccount !== zeroAddress
    ? moc.redeemFreeDocVendors(formattedAmount, _vendorAccount, {
        from: userAccount
      })
    : moc.redeemFreeDoc(formattedAmount, { from: userAccount });
};

const calculateBitProHoldersInterest = moc => async () => moc.calculateBitProHoldersInterest();

const getBitProRate = moc => async () => moc.getBitProRate();

const getBitProInterestBlockSpan = moc => async () => moc.getBitProInterestBlockSpan();

const payBitProHoldersInterestPayment = moc => async () => moc.payBitProHoldersInterestPayment();

const isBitProInterestEnabled = moc => async () => moc.isBitProInterestEnabled();

const getBitProInterestAddress = moc => async () => moc.getBitProInterestAddress();

const mintMoCToken = mocToken => async (anotherAccount, initialBalance, owner) => {
  await mocToken.mint(anotherAccount, web3.utils.toWei(initialBalance.toString()), { from: owner });
};

const approveMoCToken = mocToken => async (anotherAccount, amount, owner) => {
  await mocToken.approve(anotherAccount, web3.utils.toWei(amount.toString()), { from: owner });
};

const mintBPro = moc => async (
  from,
  reserveAmount,
  vendorAccount = zeroAddress,
  applyPrecision = true
) => {
  const reservePrecision = await moc.getReservePrecision();

  const reserveAmountToMint = applyPrecision
    ? toContract(reserveAmount * reservePrecision)
    : toContract(reserveAmount);

  return vendorAccount !== zeroAddress
    ? moc.mintBProVendors(reserveAmountToMint, vendorAccount, {
        from,
        value: reserveAmountToMint
      })
    : moc.mintBPro(reserveAmountToMint, { from, value: reserveAmountToMint });
};

const mintDoc = moc => async (from, reserveAmount, vendorAccount = zeroAddress) => {
  const reservePrecision = await moc.getReservePrecision();
  const reserveAmountWithReservePrecision = toContract(reserveAmount * reservePrecision);
  return vendorAccount !== zeroAddress
    ? moc.mintDocVendors(reserveAmountWithReservePrecision, vendorAccount, {
        from,
        value: reserveAmountWithReservePrecision
      })
    : moc.mintDoc(reserveAmountWithReservePrecision, {
        from,
        value: reserveAmountWithReservePrecision
      });
};

const mintBProx = moc => async (from, bucket, btcToMint, vendorAccount = zeroAddress, btcValue) => {
  // With this we make sure the amount sent is enough to pay the interests
  // and comissions for regular situations
  // TODO: Replace this with something more fancy
  const msgValue = btcValue || btcToMint * 2;
  const reservePrecision = await moc.getReservePrecision();
  return vendorAccount !== zeroAddress
    ? moc.mintBProxVendors(bucket, toContract(btcToMint * reservePrecision), vendorAccount, {
        from,
        value: toContract(msgValue * reservePrecision)
      })
    : moc.mintBProx(bucket, toContract(btcToMint * reservePrecision), {
        from,
        value: toContract(msgValue * reservePrecision)
      });
};

const redeemBProx = moc => async (from, bucket, amount, vendorAccount = zeroAddress) => {
  const reservePrecision = await moc.getReservePrecision();
  const amountWithPrecision = new BN(amount).mul(reservePrecision);
  return vendorAccount !== zeroAddress
    ? moc.redeemBProxVendors(bucket, toContract(amountWithPrecision), vendorAccount, {
        from
      })
    : moc.redeemBProx(bucket, toContract(amountWithPrecision), { from });
};

const rbtcNeededToMintBpro = (moc, mocState) => async bproAmount => {
  // TODO: manage max Bitpro with discount
  const mocPrecision = await moc.getMocPrecision();
  const bproTecPrice = await mocState.bproTecPrice();
  // Check discount rate
  const bproSpotDiscount = await mocState.bproSpotDiscountRate();
  const factor = mocPrecision.sub(bproSpotDiscount);
  const finalPrice = bproTecPrice.mul(factor).div(mocPrecision);

  const btcTotal = toContractBNNoPrec(bproAmount * finalPrice);
  return btcTotal;
};

const mintBProAmount = (moc, mocState, mocInrate, mocVendors) => async (
  account,
  bproAmount,
  vendorAccount,
  txType = comissionsTxType.MINT_BPRO_FEES_RBTC
) => {
  if (!bproAmount) {
    return;
  }

  const btcTotal = await rbtcNeededToMintBpro(moc, mocState)(bproAmount);
  // Sent more to pay commissions: if RBTC fees are used then get commission value,
  // otherwise commission is 0 RBTC
  const commissionRate = txType.eq(await mocInrate.MINT_BPRO_FEES_RBTC())
    ? await mocInrate.commissionRatesByTxType(txType)
    : 0;
  const mocPrecision = await moc.getMocPrecision();
  const commissionRbtcAmount =
    commissionRate > 0 ? btcTotal.mul(commissionRate).div(mocPrecision) : 0;

  let markup;
  if (vendorAccount === zeroAddress) {
    markup = 0;
  } else {
    ({ markup } = await mocVendors.vendors(vendorAccount));
  }
  const markupRbtcAmount = markup > 0 ? btcTotal.mul(markup).div(mocPrecision) : 0;

  const value = toContract(
    new BigNumber(btcTotal).plus(commissionRbtcAmount).plus(markupRbtcAmount)
  );

  return moc.mintBProVendors(toContract(btcTotal), vendorAccount, { from: account, value });
};

const mintDocAmount = (moc, btcPriceProvider, mocInrate, mocVendors) => async (
  account,
  docsToMint,
  vendorAccount,
  txType = comissionsTxType.MINT_DOC_FEES_RBTC
) => {
  if (!docsToMint) {
    return;
  }
  const reservePrecision = await moc.getReservePrecision();
  const mocPrecision = await moc.getMocPrecision();
  const formattedAmount = toBigNumber(docsToMint).times(mocPrecision);
  const btcPrice = await getBitcoinPrice(btcPriceProvider)();
  const btcTotal = formattedAmount.times(reservePrecision).div(btcPrice);
  // Sent more to pay commissions: if RBTC fees are used then get commission value,
  // otherwise commission is 0 RBTC
  const commissionRate = txType.eq(await mocInrate.MINT_DOC_FEES_RBTC())
    ? await mocInrate.commissionRatesByTxType(txType)
    : 0;

  const commissionRbtcAmount =
    commissionRate > 0
      ? toBigNumber(btcTotal)
          .times(commissionRate)
          .div(mocPrecision)
      : 0;

  const vendor = await mocVendors.vendors(vendorAccount);
  const { markup } = vendor;
  const markupRbtcAmount =
    markup > 0
      ? toBigNumber(btcTotal)
          .times(markup)
          .div(mocPrecision)
      : 0;

  const value = toContract(btcTotal.plus(commissionRbtcAmount).plus(markupRbtcAmount));

  return moc.mintDocVendors(toContract(btcTotal), vendorAccount, { from: account, value });
};

const mintBProxAmount = (moc, mocState, mocInrate, mocVendors) => async (
  account,
  bucket,
  bproxAmount,
  vendorAccount,
  txType = comissionsTxType.MINT_BTCX_FEES_RBTC
) => {
  if (!bproxAmount) {
    return;
  }

  const tproTecPrice = await mocState.bucketBProTecPrice(BUCKET_X2);
  const btcTotal = toContractBNNoPrec(bproxAmount * tproTecPrice);

  const btcInterestAmount = await mocInrate.calcMintInterestValues(bucket, btcTotal);

  // Sent more to pay commissions: if RBTC fees are used then get commission value,
  // otherwise commission is 0 RBTC
  const commissionRate = txType.eq(await mocInrate.MINT_BTCX_FEES_RBTC())
    ? await mocInrate.commissionRatesByTxType(txType)
    : 0;
  const mocPrecision = await moc.getMocPrecision();
  const commissionRbtcAmount =
    commissionRate > 0 ? btcTotal.mul(commissionRate).div(mocPrecision) : 0;

  const vendor = await mocVendors.vendors(vendorAccount);
  const { markup } = vendor;
  const markupRbtcAmount = markup > 0 ? btcTotal.mul(markup).div(mocPrecision) : 0;

  // Multiply commission by 3 to avoid rounding issues
  const value = btcInterestAmount
    .add(toContractBNNoPrec(commissionRbtcAmount))
    .add(toContractBNNoPrec(markupRbtcAmount))
    .add(btcTotal)
    .add(btcTotal);

  return moc.mintBProxVendors(bucket, btcTotal, vendorAccount, { from: account, value });
};

const redeemBPro = moc => async (from, amount, vendorAccount = zeroAddress) => {
  const reservePrecision = await moc.getReservePrecision();
  return vendorAccount !== zeroAddress
    ? moc.redeemBProVendors(toContract(amount * reservePrecision), vendorAccount, { from })
    : moc.redeemBPro(toContract(amount * reservePrecision), { from });
};

const getDoCBalance = docToken => async address => docToken.balanceOf(address);

const getBProBalance = bproToken => async address => bproToken.balanceOf(address);

const getMoCBalance = mocToken => async address => mocToken.balanceOf(address);

const getMoCAllowance = mocToken => async (owner, spender) => mocToken.allowance(owner, spender);

const getReserveBalance = async address => new BN(await web3.eth.getBalance(address));

// Runs settlement with a default fixed step count
const executeSettlement = moc => () => moc.runSettlement(SETTLEMENT_STEPS);

const getRedeemRequestAt = moc => async index => moc.getRedeemRequestAt(index);

const getBProxBalance = bprox => async (bucket, address) => bprox.bproxBalanceOf(bucket, address);

const getUserBalances = (bproToken, docToken, bproxManager, mocToken) => async account => {
  const [doc, bpro, bpro2x, rbtc, moc] = await Promise.all([
    docToken.balanceOf(account),
    bproToken.balanceOf(account),
    bproxManager.bproxBalanceOf(BUCKET_X2, account),
    web3.eth.getBalance(account),
    mocToken.balanceOf(account)
  ]);

  return { doc, bpro, bpro2x, rbtc, moc };
};

const getGlobalState = mocState => async () => {
  const [
    coverage,
    nB,
    adjNB,
    nBPro,
    nDoc,
    inrateBag,
    nBProx2,
    bproTecPrice,
    abRatio
  ] = await Promise.all([
    mocState.globalCoverage(),
    mocState.rbtcInSystem(),
    mocState.collateralRbtcInSystem(),
    mocState.bproTotalSupply(),
    mocState.docTotalSupply(),
    mocState.getInrateBag(BUCKET_C0),
    mocState.getBucketNBPro(BUCKET_X2),
    mocState.bproTecPrice(),
    mocState.currentAbundanceRatio()
  ]);

  return { coverage, nB, adjNB, nBPro, nDoc, inrateBag, nBProx2, bproTecPrice, abRatio };
};

const getBucketState = mocState => async bucket => {
  const [coverage, leverage, lB, nB, nBPro, nDoc, inrateBag, bproxTecPrice] = await Promise.all([
    mocState.coverage(bucket),
    mocState.leverage(bucket),
    mocState.lockedBitcoin(bucket),
    mocState.getBucketNBTC(bucket),
    mocState.getBucketNBPro(bucket),
    mocState.getBucketNDoc(bucket),
    mocState.getInrateBag(bucket),
    mocState.bucketBProTecPrice(bucket)
  ]);

  return { coverage, leverage, lB, nB, nBPro, nDoc, inrateBag, bproxTecPrice };
};

const bucketStateToString = state =>
  Object.keys(state).reduce(
    (last, key) => `${last}${key}: ${state[key].toString()}
  `,
    ''
  );

const bucketString = moc => async bucket => {
  const bucketState = await getBucketState(moc)(bucket);
  return bucketStateToString(bucketState);
};

const logBucket = moc => async bucket => {
  // eslint-disable-next-line no-console
  console.log(await bucketString(moc)(bucket));
};

const setFinalCommissionAddress = (commissionSplitter, governor) => async finalAddress => {
  const setCommissionAddressChanger = await SetCommissionFinalAddressChanger.new(
    commissionSplitter.address,
    finalAddress
  );

  return governor.executeChange(setCommissionAddressChanger.address);
};

const setMocCommissionProportion = (commissionSplitter, governor) => async proportion => {
  const setCommissionMocProportionChanger = await SetCommissionMocProportionChanger.new(
    commissionSplitter.address,
    proportion
  );

  return governor.executeChange(setCommissionMocProportionChanger.address);
};

const getCommissionsArrayNonZero = (moc, mocInrate) => async () => {
  let mocPrecision = 10 ** 18;
  if (typeof moc !== 'undefined') {
    mocPrecision = await moc.getMocPrecision();
  }

  const ret = [
    {
      txType: (await mocInrate.MINT_BPRO_FEES_RBTC()).toString(),
      fee: BigNumber(0.001)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_RBTC()).toString(),
      fee: BigNumber(0.002)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_RBTC()).toString(),
      fee: BigNumber(0.003)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_RBTC()).toString(),
      fee: BigNumber(0.004)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_RBTC()).toString(),
      fee: BigNumber(0.005)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_RBTC()).toString(),
      fee: BigNumber(0.006)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BPRO_FEES_MOC()).toString(),
      fee: BigNumber(0.007)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_MOC()).toString(),
      fee: BigNumber(0.008)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_MOC()).toString(),
      fee: BigNumber(0.009)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_MOC()).toString(),
      fee: BigNumber(0.01)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_MOC()).toString(),
      fee: BigNumber(0.011)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_MOC()).toString(),
      fee: BigNumber(0.012)
        .times(mocPrecision)
        .toString()
    }
  ];
  return ret;
};

const getCommissionsArrayInvalidLength = async () => {
  const ret = [];
  const length = 60;
  const mocPrecision = 10 ** 18;

  for (let i = 1; i <= length; i++) {
    ret.push({
      txType: i.toString(),
      fee: BigNumber(i)
        .times(mocPrecision)
        .toString()
    });
  }

  return ret;
};

const getCommissionsArrayChangingTest = async () => {
  const ret = [];
  const length = 12;
  const mocPrecision = 10 ** 18;

  for (let i = 1; i <= length; i++) {
    ret.push({
      txType: i.toString(),
      fee: BigNumber(i * 2)
        .times(mocPrecision)
        .toString()
    });
  }

  return ret;
};

const registerVendor = (moc, mocVendors) => async (vendorAccount, markup, from) => {
  let mocPrecision = 10 ** 18;
  if (typeof moc !== 'undefined') {
    mocPrecision = await moc.getMocPrecision();
  }

  // Register vendor
  return mocVendors.registerVendor(
    vendorAccount,
    toContractBNNoPrec(markup * mocPrecision).toString(),
    {
      from
    }
  );
};

const consolePrintTestVariables = obj => {
  for (let i = 0; i < Object.keys(obj).length; i++) {
    const variableName = Object.keys(obj)[i];
    // eslint-disable-next-line no-console
    console.log(`${variableName}: ${obj[variableName].toString()}`);
  }
};

module.exports = async contracts => {
  const {
    doc,
    bpro,
    moc,
    mocState,
    bprox,
    btcPriceProvider,
    mocInrate,
    governor,
    mockMocStateChanger,
    commissionSplitter,
    mocToken,
    mocPriceProvider,
    mocVendors
  } = contracts;

  return {
    setBitcoinPrice: setBitcoinPrice(btcPriceProvider),
    getBitcoinPrice: getBitcoinPrice(btcPriceProvider),
    getDoCBalance: getDoCBalance(doc),
    getBProBalance: getBProBalance(bpro),
    getBProxBalance: getBProxBalance(bprox),
    getReserveBalance,
    getUserBalances: getUserBalances(bpro, doc, bprox, mocToken),
    setSmoothingFactor: setSmoothingFactor(governor, mockMocStateChanger),
    redeemFreeDoc: redeemFreeDoc(moc),
    mintBPro: mintBPro(moc),
    mintDoc: mintDoc(moc),
    mintBProx: mintBProx(moc),
    redeemBProx: redeemBProx(moc),
    rbtcNeededToMintBpro: rbtcNeededToMintBpro(moc, mocState),
    mintBProAmount: mintBProAmount(moc, mocState, mocInrate, mocVendors),
    mintDocAmount: mintDocAmount(moc, btcPriceProvider, mocInrate, mocVendors),
    mintBProxAmount: mintBProxAmount(moc, mocState, mocInrate, mocVendors),
    redeemBPro: redeemBPro(moc),
    calculateBitProHoldersInterest: calculateBitProHoldersInterest(moc),
    getBitProRate: getBitProRate(moc),
    getBitProInterestBlockSpan: getBitProInterestBlockSpan(moc),
    getBitProInterestAddress: getBitProInterestAddress(moc),
    payBitProHoldersInterestPayment: payBitProHoldersInterestPayment(moc),
    isBitProInterestEnabled: isBitProInterestEnabled(moc),
    executeSettlement: executeSettlement(moc),
    getGlobalState: getGlobalState(mocState),
    getBucketState: getBucketState(mocState),
    logBucket: logBucket(mocState),
    getRedeemRequestAt: getRedeemRequestAt(moc),
    setFinalCommissionAddress: setFinalCommissionAddress(commissionSplitter, governor),
    setMocCommissionProportion: setMocCommissionProportion(commissionSplitter, governor),
    mintMoCToken: mintMoCToken(mocToken),
    getMoCBalance: getMoCBalance(mocToken),
    approveMoCToken: approveMoCToken(mocToken),
    getMoCAllowance: getMoCAllowance(mocToken),
    comissionsTxType,
    getCommissionsArrayNonZero: getCommissionsArrayNonZero(moc, mocInrate),
    getCommissionsArrayInvalidLength,
    getCommissionsArrayChangingTest,
    BUCKET_C0,
    BUCKET_X2,
    zeroAddress,
    setMoCPrice: setMoCPrice(mocPriceProvider),
    getMoCPrice: getMoCPrice(mocPriceProvider),
    registerVendor: registerVendor(moc, mocVendors),
    consolePrintTestVariables
  };
};
