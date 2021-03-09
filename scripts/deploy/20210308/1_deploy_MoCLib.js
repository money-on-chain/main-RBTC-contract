const MoCLib = artifacts.require('./MoCHelperLib.sol');

const MoC = artifacts.require('./MoC.sol');
const MoCConverter = artifacts.require('./MoCConverter.sol');
const MoCState = artifacts.require('./MoCState.sol');
const MoCExchange = artifacts.require('./MoCExchange.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCVendors = artifacts.require('./MoCVendors.sol');

const deployConfig = require('./deployConfig.json');
const utils = require('../../../migrations/utils');
const allConfigs = require('../../../migrations/configs/config');

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Deploy new MoCHelperLib implementation
    await deployer.deploy(MoCLib);

    // Current network config values: allConfigs[currentNetwork]

    // Link MoCHelperLib
    await deployer.link(MoCLib, MoC);
    await deployer.link(MoCLib, MoCConverter);
    await deployer.link(MoCLib, MoCState);
    await deployer.link(MoCLib, MoCExchange);
    await deployer.link(MoCLib, MoCInrate);
    await deployer.link(MoCLib, MoCVendors);
  } catch (error) {
    // eslint-disable-next-line no-console
    console.log(error);
  }

  callback();
};
