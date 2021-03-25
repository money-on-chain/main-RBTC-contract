/* eslint-disable no-console */
const MoCLib = artifacts.require('./MoCHelperLib.sol');

const MoC = artifacts.require('./MoC.sol');
const MoCConverter = artifacts.require('./MoCConverter.sol');
const MoCState = artifacts.require('./MoCState.sol');
const MoCExchange = artifacts.require('./MoCExchange.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCVendors = artifacts.require('./MoCVendors.sol');

const { getConfig, getNetwork, saveConfig } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    // const [owner] = await web3.eth.getAccounts();

    // Deploy new MoCHelperLib implementation
    console.log('Deploy MoCHelperLib');
    const mocHelperLib = await MoCLib.new();

    // Save implementation address to config file
    config.implementationAddresses.MoCHelperLib = mocHelperLib.address;
    saveConfig(config, configPath);

    console.log('MoCHelperLib implementation address: ', mocHelperLib.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
