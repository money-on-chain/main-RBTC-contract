/* eslint-disable no-console */
const utils = require('./utils');
const allConfigs = require('./configs/config');

module.exports = async (deployer, currentNetwork, [owner]) => {
  // Workaround to get the link working on tests
  if (utils.isDevelopment(currentNetwork)) {
    const {
      deployOracleMock,
      deployGovernorContract,
      deployProxyAdminContract,
      deployStopperContract,
      deployUpgradeDelegatorContract,
      deployMoCOracleMock,
      deployMoCHelperLibHarness
    } = await utils.makeUtils(
      artifacts,
      currentNetwork,
      allConfigs[currentNetwork],
      owner,
      deployer
    );

    console.log('Deploying Dev only 1');
    await Promise.all([deployOracleMock(), deployGovernorContract(), deployMoCOracleMock()]);
    console.log('Deploying Dev only Proxy Admin');
    await deployProxyAdminContract();
    console.log('Deploying Dev only Stopper and delegator');
    await Promise.all([deployStopperContract(), deployUpgradeDelegatorContract()]);
    console.log('Deploying Dev only MoCHelperLibHarness');
    await deployMoCHelperLibHarness();
  }
};
