/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCConnector = artifacts.require('./MoCConnector.sol');

const deployConfig = require('./deployConfig.json');

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Get proxy contract
    const proxyMocConnector = await AdminUpgradeabilityProxy.at(
      deployConfig[currentNetwork].addresses.MoCConnector
    );

    // Upgrade delegator and Governor addresses (used to make changes to contracts)
    const upgradeDelegatorAddress = deployConfig[currentNetwork].addresses.UpgradeDelegator;
    const governor = await Governor.at(deployConfig[currentNetwork].addresses.Governor);

    // Deploy contract implementation
    console.log('- Deploy MoCConnector');
    const mocConnector = await deployer.deploy(MoCConnector);

    // Upgrade contracts with proxy (using the contract address of contracts just deployed)
    console.log('- Upgrade MoCConnector');
    const upgradeMocConnector = await deployer.deploy(
      UpgraderChanger,
      proxyMocConnector.address,
      upgradeDelegatorAddress,
      mocConnector.address
    );

    // Execute changes in contracts
    console.log('Execute change - MoCConnector');
    await governor.executeChange(upgradeMocConnector.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
