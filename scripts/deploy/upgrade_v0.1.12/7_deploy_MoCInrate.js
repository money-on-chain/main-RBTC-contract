/* eslint-disable no-console */
const MoCInrate = artifacts.require('./MoCInrate.sol');

const { getConfig, getNetwork, saveConfig } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Link MoCHelperLib
    console.log('Link MoCHelperLib');
    MoCInrate.link('MoCHelperLib', config.implementationAddresses.MoCHelperLib);

    // Deploy contract implementation
    console.log('Deploy MoCInrate');
    const mocInrate = await MoCInrate.new();

    // Save implementation address to config file
    config.implementationAddresses.MoCInrate = mocInrate.address;
    saveConfig(config, configPath);

    console.log('MoCInrate implementation address: ', mocInrate.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
