/* eslint-disable no-console */
const MoC = artifacts.require('./MoC.sol');

const { getConfig, getNetwork, saveConfig } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Deploy contract implementation
    console.log('Deploying MoC ...');
    const moc = await MoC.new();

    // Save implementation address to config file
    config.mocImplementationAddresses.MoC = moc.address;

    saveConfig(config, configPath);

    console.log('MoC implementation address: ', moc.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
