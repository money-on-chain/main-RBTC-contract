/* eslint-disable no-console */
const MoCStateMock = artifacts.require("./mocks/MoCStateMock.sol");
const MoCSettlementMock = artifacts.require("./mocks/MoCSettlementMock.sol");
const DocToken = artifacts.require("./token/DocToken.sol");
const BProToken = artifacts.require("./token/BProToken.sol");
const MoCLib = artifacts.require("./MoCHelperLib.sol");
const makeUtils = require("./utils");
const allConfigs = require("./configs/config");

module.exports = async (deployer, currentNetwork, [owner]) => {
  // Workaround to get the link working on tests
  if (
    currentNetwork === 'development' ||
    currentNetwork === 'coverage' ||
    currentNetwork === 'regtest'
  ) {
    const {
      linkMocLib,
      deployUpgradable,
      deployMocLibMock,
      deployOracleMock,
      deployGovernorContract,
      deployProxyAdminContract,
      deployStopperContract,
      deployUpgradeDelegatorContract
    } = await makeUtils(
      artifacts,
      currentNetwork,
      allConfigs[currentNetwork],
      owner,
      deployer
    );

    console.log("Deploying Dev only 1");
    await Promise.all([
      deployMocLibMock(),
      deployOracleMock(),
      deployGovernorContract()
    ]);
    console.log("Deploying Dev only Proxy Admin");
    await deployProxyAdminContract();
    console.log("Deploying Dev only Stopper and delegator");
    await Promise.all([
      deployStopperContract(),
      deployUpgradeDelegatorContract()
    ]);
    console.log("Deploying Dev only MoCStateMock");
    await linkMocLib(MoCStateMock);
    console.log("Deploying Dev only Tokens");
    await Promise.all([
      deployer.deploy(DocToken),
      deployer.deploy(BProToken)
    ]);
    console.log("Deploying Dev only MoCLib");
    deployer.deploy(MoCLib);
    console.log("Deploying Dev only deployUpgradable");
    // eslint-disable-next-line promise/always-return
    for (let index = 1; index <= 10; index++) {
      // eslint-disable-next-line no-await-in-loop
      await deployUpgradable(MoCSettlementMock, MoCStateMock, index);
    }
  }
};
