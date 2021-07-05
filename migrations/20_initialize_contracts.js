/* eslint-disable no-console */
const utils = require('./utils');
const allConfigs = require('./configs/config');

const MoCStateMock = artifacts.require('./mocks/MoCStateMock.sol');
const MoCSettlementMock = artifacts.require('./mocks/MoCSettlementMock.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');

module.exports = async (deployer, currentNetwork, [owner]) => {
  // Workaround to get the link working on tests
  const { createInstances, initializeContracts } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );

  if (utils.isDevelopment(currentNetwork)) await createInstances(MoCSettlementMock, MoCStateMock);
  else await createInstances(MoCSettlement, MoCState);
  console.log(`Initialize contracts - network: ${currentNetwork}`);
  await initializeContracts();
};
