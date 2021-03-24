/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');

const MoCVendors = artifacts.require('./MoCVendors.sol');

const { getConfig, getNetwork, saveConfig } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Link MoCHelperLib
    console.log('Link MoCHelperLib');
    MoCVendors.link('MoCHelperLib', config.implementationAddresses.MoCHelperLib);

    // Deploy new MoCVendors implementation
    const mocVendors = await MoCVendors.new();

    // Save implementation address to config file
    config.implementationAddresses.MoCVendors = mocVendors.address;
    saveConfig(config, configPath);

    // Initialize contract
    const initData = await mocVendors.contract.methods
      .initialize(
        config.proxyAddresses.MoCConnector,
        config.implementationAddresses.Governor,
        config.valuesToAssign.vendorGuardianAddress
      )
      .encodeABI();
    console.log('MoCVendors Initialized');

    const proxyMocVendors = await AdminUpgradeabilityProxy.new(
      mocVendors.address,
      config.implementationAddresses.ProxyAdmin,
      initData
    );

    // Save proxy address to config file
    config.proxyAddresses.MoCVendors = proxyMocVendors.address;
    saveConfig(config, configPath);

    console.log('MoCVendors proxy address: ', proxyMocVendors.address);
    console.log('MoCVendors implementation address: ', mocVendors.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
