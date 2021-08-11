/* eslint-disable no-console */
const CommissionSplitter = artifacts.require('./CommissionSplitter.sol');

const { getConfig, getNetwork, saveConfig } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Deploy new CommissionSplitter implementationxs
    console.log('Deploy CommissionSplitter');
    const commissionSplitter = await CommissionSplitter.new();

    // Save implementation address to config file
    config.implementationAddresses.CommissionSplitter = commissionSplitter.address;
    saveConfig(config, configPath);

    console.log('CommissionSplitter implementation address: ', commissionSplitter.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
