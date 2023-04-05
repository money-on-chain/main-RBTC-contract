/* eslint-disable no-console */
const CommissionSplitterV3 = artifacts.require('./auxiliar/CommissionSplitterV3.sol');
const { getConfig, getNetwork } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const commissionSplitterV3Address = config.proxyAddresses.CommissionSplitterV3;
    const commissionSplitterV3 = await CommissionSplitterV3.at(commissionSplitterV3Address);

    const contractInfo = {};
    contractInfo.outputAddress_1 = await commissionSplitterV3.outputAddress_1();
    contractInfo.outputAddress_2 = await commissionSplitterV3.outputAddress_2();
    contractInfo.outputProportion_1 = await commissionSplitterV3.outputProportion_1();

    console.log('Contract storage');

    if (contractInfo.outputAddress_1.toLowerCase() === config.CommissionSplitterV3.outputAddress_1.toLowerCase()) {
      console.log('OK. 1. outputAddress_1: ', contractInfo.outputAddress_1);
    } else {
      console.log('ERROR. 1. outputAddress_1: ', contractInfo.outputAddress_1);
    }

    if (contractInfo.outputAddress_2.toLowerCase() === config.CommissionSplitterV3.outputAddress_2.toLowerCase()) {
      console.log('OK. 2. outputAddress_2: ', contractInfo.outputAddress_2);
    } else {
      console.log('ERROR. 2. outputAddress_2: ', contractInfo.outputAddress_2);
    }

    if (
      contractInfo.outputProportion_1.toString() === config.CommissionSplitterV3.outputProportion_1
    ) {
      console.log('OK. 3. outputProportion_1: ', contractInfo.outputProportion_1.toString());
    } else {
      console.log('ERROR. 3. outputProportion_1: ', contractInfo.outputProportion_1.toString());
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
