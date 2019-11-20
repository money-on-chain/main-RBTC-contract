/* eslint-disable no-console */
const makeUtils = require('./utils');
const allConfigs = require('./configs/config');

const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');

module.exports = async (deployer, currentNetwork, [owner]) => {
  // Workaround to get the link working on tests
  const { createInstances, initializeContracts } = await makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );
  return deployer.then(async () => {
    await createInstances(MoCSettlement, MoCState);
    console.log(`Initialize contracts - network: ${currentNetwork}`);
    return initializeContracts();
  });
};
