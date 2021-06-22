/* eslint-disable no-console */
const ProxyAdmin = artifacts.require('ProxyAdmin');
const MoCInrate = artifacts.require('./MoCInrate.sol');

const BigNumber = require('bignumber.js');
const { getConfig, getNetwork } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const newConfigPath = `${__dirname}/deployConfig-${network}.json`;
    const newConfig = getConfig(network, newConfigPath);
    const originalConfigPath = `${__dirname}/deployConfig-${network}-original.json`;
    const originalConfig = getConfig(network, originalConfigPath);

    // Getting the keys we want to compare
    const comparisonKeys = [
      'MoC',
      'MoCExchange',
      'MoCSettlement',
      'CommissionSplitter',
      'MoCInrate',
      'MoCState',
      'MoCVendors'
    ];

    const proxyAdmin = await ProxyAdmin.at(originalConfig.implementationAddresses.ProxyAdmin);

    console.log('------------------------------------------------------------');

    // Comparing the values
    comparisonKeys.forEach(async key => {
      const newValue = await proxyAdmin.getProxyImplementation(newConfig.proxyAddresses[key]);
      console.log(`Comparing: ${key}:`);
      console.log(`Original value: ${originalConfig.implementationAddresses[key]}`);
      console.log(`New value from ProxyAdmin: ${newValue}`);
      console.log(`New value from configuration: ${newConfig.implementationAddresses[key]}`);

      if (newConfig.implementationAddresses[key] === newValue) {
        console.log('\x1b[32m%s\x1b[0m', 'Implementation addresses match');
      } else {
        console.log('\x1b[31m%s\x1b[0m', 'Implementation addresses do not match');
      }
      if (newConfig.implementationAddresses[key] !== originalConfig.implementationAddresses[key]) {
        console.log('\x1b[32m%s\x1b[0m', 'Value updated');
      } else {
        console.log('\x1b[31m%s\x1b[0m', 'Value did not update');
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
      console.log('\x1b[32m%s\x1b[0m', 'Values are the same');
    } else {
      console.log('\x1b[31m%s\x1b[0m', 'Values are not the same');
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
