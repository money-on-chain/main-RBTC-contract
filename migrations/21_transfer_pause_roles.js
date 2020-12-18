/* eslint-disable no-console */
const utils = require('./utils');
const allConfigs = require('./configs/config');

const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');

module.exports = async (deployer, currentNetwork, [owner]) => {
  const { transferBproPausingRole, createInstances } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );
  // Workaround to get the link working on tests
  await createInstances(MoCSettlement, MoCState);
  return transferBproPausingRole();
};
