const BigNumber = require('bignumber.js');

const { BN, isBN } = web3.utils;

const toContractBN = unitsPrecision => (number, precision = 'NONE') => {
  if (isBN(number)) {
    return number;
  }

  // This is a workaround to be able to create BN from strings
  const bigNumber = new BigNumber(number);
  const finalBig = bigNumber.times(unitsPrecision[precision]);

  return new BN(finalBig.integerValue().toFixed());
};

// To use internally with no precision
const toContractBNNoPrec = toContractBN({ NONE: 1 });

module.exports = {
  toContractBN,
  toContractBNNoPrec
};
