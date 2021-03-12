/* eslint-disable no-console */
const MoCInrate = artifacts.require('./MoCInrate.sol');

const BigNumber = require('bignumber.js');
const { getConfig, getNetwork } = require('./helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const newConfig = getConfig(network);
    const originalConfig = getConfig(network, `deployConfig-${network}-original.json`);

    // Getting the keys we want to compare
    const comparisonKeys = [
      'MoC',
      'MoCConnector',
      'MoCExchange',
      'MoCSettlement',
      'MoCInrate',
      'MoCConverter',
      'MoCState',
      'MoCVendors',
      'MoCHelperLib'
    ];

    console.log('------------------------------------------------------------');

    // Comparing the values
    comparisonKeys.forEach(key => {
      console.log(`Comparing: ${key}:`);
      console.log(`Original value: ${originalConfig.implementationAddresses[key]}`);
      console.log(`New value: ${newConfig.implementationAddresses[key]}`);
      if (newConfig.implementationAddresses[key] !== originalConfig.implementationAddresses[key]) {
        console.log('Value updated');
      } else {
        console.log('Value did not update');
      }
      console.log('------------------------------------------------------------');
    });

    // Testing if some values have been updated
    const mocPrecision = 10 ** 18;
    const newFee = BigNumber(newConfig.valuesToAssign.commissionRates.MINT_BPRO_FEES_RBTC).times(
      mocPrecision
    );

    // Get value from contract
    const mocInrate = await MoCInrate.at(newConfig.proxyAddresses.MoCInrate);
    const valueFromContract = await mocInrate.commissionRatesByTxType(
      await mocInrate.MINT_BPRO_FEES_RBTC()
    );
    console.log('Obtaining: MINT_BPRO_FEES_RBTC:');
    console.log(`New fee: ${newFee.toString()}`);
    console.log(`Value from contract: ${valueFromContract.toString()}`);
    if (newFee.eq(valueFromContract)) {
      console.log('Values are the same');
    } else {
      console.log('Values are not the same');
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
