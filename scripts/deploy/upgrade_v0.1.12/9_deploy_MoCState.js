/* eslint-disable no-console */
const MoCState = artifacts.require('./MoCState.sol');
const MoCStateMock = artifacts.require('./mocks/MoCStateMock.sol');

const { getConfig, getNetwork, saveConfig } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Link MoCHelperLib
    console.log('Link MoCHelperLib');
    MoCState.link('MoCHelperLib', config.implementationAddresses.MoCHelperLib);

    // Deploy contract implementation
    console.log('Deploy MoCState');
    let mocState;
    if (network === 'development') {
      mocState = await MoCStateMock.new();
    } else {
      mocState = await MoCState.new();
    }

    // Save implementation address to config file
    config.implementationAddresses.MoCState = mocState.address;
    saveConfig(config, configPath);

    console.log('MoCState implementation address: ', mocState.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
