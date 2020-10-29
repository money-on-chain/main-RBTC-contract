const MoCLib = artifacts.require('./MoCHelperLib.sol');

const utils = require('./utils');
const allConfigs = require('./configs/config');

module.exports = async (deployer, currentNetwork, [owner]) => {
  await deployer.deploy(MoCLib);
  if (utils.isDevelopment(currentNetwork)) {
    const { deployMocLibMock } = await utils.makeUtils(
      artifacts,
      currentNetwork,
      allConfigs[currentNetwork],
      owner,
      deployer
    );
    deployMocLibMock();
  }
};
