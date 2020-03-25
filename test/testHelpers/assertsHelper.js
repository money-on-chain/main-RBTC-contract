const { BigNumber } = require('bignumber.js');
const chai = require('chai');

const { BN, isBN } = web3.utils;

chai.use(require('chai-bn')(BN)).should();

const assertBig = precisionBN => (actual, expected, _msg, opt) => {
  let bnActual = actual;

  if (!isBN(actual)) {
    // String value probably provided by web3 getBalance
    bnActual = new BN(actual);
  }
  const bigNumberExpected = new BigNumber(expected);
  // This is a workaround to be able to expect floats
  const expectedWithPrecision = bigNumberExpected
    .times(precisionBN.toString())
    .integerValue()
    .toFixed();
  const bnExpected = new BN(expectedWithPrecision);
  if (opt && opt.significantDigits && bnExpected.toString().length > opt.significantDigits) {
    const insignificantDigits = bnExpected.toString().length - opt.significantDigits;
    const padding = new BN(10).pow(new BN(insignificantDigits));
    const downLimit = bnExpected.sub(padding);
    const upperLimit = bnExpected.add(padding);
    const extendedMsg = `${_msg} : Expecting ${bnActual.toString()} to be between ${downLimit.toString()} and ${upperLimit.toString()}, based on expected ${expected} with ${
      opt.significantDigits
    } significant digits`;
    return chai.expect(bnActual.gte(downLimit) && bnActual.lte(upperLimit), extendedMsg).to.be.true;
  }
  const extendedMsg = `${_msg} : Expecting ${bnActual.toString()} to be equal to ${bnExpected.toString()}`;
  return chai.expect(bnActual.eq(bnExpected), extendedMsg).to.be.true;
};

module.exports = precisions => {
  const { RESERVE_PRECISION, MOC_PRECISION } = precisions;

  return {
    assertBig: assertBig(new BN(1)),
    assertBigReserve: assertBig(RESERVE_PRECISION),
    assertBigRBTC: assertBig(RESERVE_PRECISION),
    assertBigDollar: assertBig(MOC_PRECISION),
    assertBigCb: assertBig(MOC_PRECISION),
    assertBigRate: assertBig(MOC_PRECISION),
    assertBigMax: assertBig(MOC_PRECISION)
  };
};
