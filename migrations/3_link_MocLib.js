const utils = require('./utils');

const MoCStateMock = artifacts.require('./mocks/MoCStateMock.sol');
const MoCState = artifacts.require('./MoCState.sol');
const allConfigs = require('./configs/config');

module.exports = async (deployer, currentNetwork, [owner]) => {
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
