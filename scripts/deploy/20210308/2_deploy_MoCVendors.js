/* eslint-disable no-console */
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');
const MoCVendors = artifacts.require('./MoCVendors.sol');

const deployConfig = require('./deployConfig.json');
const utils = require('../../../migrations/utils');
const allConfigs = require('../../../migrations/configs/config');

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Deploy contract
    const { deployUpgradable } = await utils.makeUtils(
      artifacts,
      currentNetwork,
      allConfigs[currentNetwork],
      owner,
      deployer
    );
    const index = 10;
    await deployUpgradable(MoCSettlement, MoCState, index);

    const addresses = await utils.getContractAddresses();
    const mocVendors = await MoCVendors.at(addresses.mocVendors);

    // Initialize contract
    await mocVendors.initialize(
      deployConfig[currentNetwork].addresses.MoCConnector, // proxy address
      deployConfig[currentNetwork].addresses.Governor, // proxy address
      allConfigs[currentNetwork].vendorMoCDepositAddress,
      allConfigs[currentNetwork].vendorRequiredMoCs
    );
    console.log('MoCVendors Initialized');

    // TODO: Save MoCVendors address to file
    console.log('MoCVendors address: ', addresses.mocVendors);
  } catch (error) {
    console.log(error);
  }

  callback();
};
