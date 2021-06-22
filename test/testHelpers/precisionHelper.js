const { BN } = web3.utils;

const unitsMapping = {
  nDoCs: 'MAX',
  nDoCgl: 'MAX',
  liq: 'MAX',
  utpdu: 'MAX',
  peg: 'PEG',
  nBPro: 'BTC',
  nBProx: 'BTC',
  initialnB: 'BTC',
  btcPrice: 'MAX',
  B: 'MAX',
  nDocsBtcAmount: 'BTC',
  bproBtcAmount: 'BTC',
  globalLockedBitcoin: 'BTC',
  globalCoverage: 'MAX',
  globalMaxDoc: 'MAX',
  globalMaxBPro: 'BTC',
  bproTecPrice: 'BTC',
  bproUsdPrice: 'MAX',
  maxBPro: 'BTC',
  lockedBitcoin: 'BTC',
  coverage: 'MAX',
  leverage: 'MAX',
  discount: 'RAT',
  nB: 'BTC',
  lB: 'BTC',
  Co: 'MAX',
  tMax: 'RAT',
  tMin: 'RAT',
  bitProRate: 'RAT',
  days: 'DAY',
  doc0: 'MAX',
  doct: 'MAX',
  inrate: 'RAT',
  inratePost: 'RAT',
  inrateAvg: 'RAT'
};

module.exports = async moc => {
  const [RESERVE_PRECISION, DAY_PRECISION, MOC_PRECISION] = await Promise.all([
    moc.getReservePrecision(),
    moc.getDayPrecision(),
    moc.getMocPrecision()
  ]);
  const unitsPrecision = {
    BTC: RESERVE_PRECISION,
    MOC: MOC_PRECISION,
    USD: MOC_PRECISION,
    COV: MOC_PRECISION,
    RAT: MOC_PRECISION,
    DAY: DAY_PRECISION,
    MAX: MOC_PRECISION,
    PEG: new BN(1),
    NONE: new BN(1)
  };
  return {
    RESERVE_PRECISION,
    MOC_PRECISION,
    DAY_PRECISION,
    unitsPrecision,
    unitsMapping
  };
};
