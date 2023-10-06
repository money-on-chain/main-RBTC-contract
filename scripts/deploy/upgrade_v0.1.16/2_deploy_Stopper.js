/* eslint-disable no-console */
const Stopper = artifacts.require('./governance/StopperV2.sol');
const { getConfig, getNetwork, saveConfig } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Deploy contract implementation
    console.log('Deploying Stopper ...');
    const stopper = await Stopper.new();

    // Save implementation address to config file
    config.governanceImplementationAddresses.Stopper = stopper.address;

    saveConfig(config, configPath);

    console.log('Stopper implementation address: ', stopper.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
