const MoCLib = artifacts.require('./MoCHelperLib.sol');
const MoCState = artifacts.require('./MoCState.sol');

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

  const { linkMocLib } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );
  if (utils.isDevelopment(currentNetwork)) await linkMocLib(MoCStateMock);
  else await linkMocLib(MoCState);
};
