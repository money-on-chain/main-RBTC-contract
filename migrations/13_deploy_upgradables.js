const makeUtils = require('./utils');

const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');

const allConfigs = require('./configs/config');

module.exports = async (deployer, currentNetwork, [owner]) => {
  const { deployUpgradable } = await makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );
  await deployUpgradable(MoCSettlement, MoCState, 5);
};
