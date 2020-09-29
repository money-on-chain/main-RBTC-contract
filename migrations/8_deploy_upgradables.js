const utils = require('./utils');

const MoCStateMock = artifacts.require('./mocks/MoCStateMock.sol');
const MoCSettlementMock = artifacts.require('./mocks/MoCSettlementMock.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');

const allConfigs = require('./configs/config');

module.exports = async (deployer, currentNetwork, [owner]) => {
  const { deployUpgradable } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );
  const index = 1;
  if (utils.isDevelopment(currentNetwork))
    await deployUpgradable(MoCSettlementMock, MoCStateMock, index);
  else await deployUpgradable(MoCSettlement, MoCState, index);
};
