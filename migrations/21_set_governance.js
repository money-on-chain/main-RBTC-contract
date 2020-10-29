/* eslint-disable no-console */
const utils = require('./utils');
const allConfigs = require('./configs/config');

const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');

module.exports = async (deployer, currentNetwork, [owner]) => {
  // Workaround to get the link working on tests
  const { createInstances, setGovernance, getContractAddresses } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );
  await createInstances(MoCSettlement, MoCState);
  console.log(`Setting Governance - network: ${currentNetwork}`);
  await setGovernance();
  console.log('------------CONTRACTS DEPLOYED-----------------');
  return console.log(`${JSON.stringify(await getContractAddresses())}`);
};
