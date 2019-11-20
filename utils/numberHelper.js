const BigNumber = require('bignumber.js');

const toContract = number => {
  const bn = new BigNumber(number);
  return bn.toFixed(0);
};

const toBigNumber = number => {
  return new BigNumber(number);
};

module.exports = { toContract, toBigNumber };
