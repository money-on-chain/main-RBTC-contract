/* eslint-disable no-console */
const MoCSettlement = artifacts.require('./MoCSettlement.sol');

const { getConfig, getNetwork, saveConfig } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Deploy contract implementation
    console.log('Deploy MoCSettlement');
    const mocSettlement = await MoCSettlement.new();

    // Save implementation address to config file
    config.implementationAddresses.MoCSettlement = mocSettlement.address;
    saveConfig(config, configPath);

    console.log('MoCSettlement implementation address: ', mocSettlement.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
