/* eslint-disable no-console */
const makeUtils = require('./utils');
const allConfigs = require('./configs/config');

const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');

module.exports = async (deployer, currentNetwork, [owner]) => {
  const { transferBproRoles, createInstances } = await makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );
  // Workaround to get the link working on tests
  return deployer.then(async () => {
    await createInstances(MoCSettlement, MoCState);
    return transferBproRoles();
  });
};
