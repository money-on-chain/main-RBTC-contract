/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoC = artifacts.require('./MoC.sol');

const deployConfig = require('./deployConfig.json');

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Get proxy contract
    const proxyMoc = await AdminUpgradeabilityProxy.at(deployConfig[currentNetwork].addresses.MoC);

    // Upgrade delegator and Governor addresses (used to make changes to contracts)
    const upgradeDelegatorAddress = deployConfig[currentNetwork].addresses.UpgradeDelegator;
    const governor = await Governor.at(deployConfig[currentNetwork].addresses.Governor);

    // Deploy contract implementation
    console.log('- Deploy MoC');
    const moc = await deployer.deploy(MoC);

    // Upgrade contracts with proxy (using the contract address of contracts just deployed)
    console.log('- Upgrade MoC');
    const upgradeMoc = await deployer.deploy(
      UpgraderChanger,
      proxyMoc.address,
      upgradeDelegatorAddress,
      moc.address
    );

    // Execute changes in contracts
    console.log('Execute change - MoC');
    await governor.executeChange(upgradeMoc.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
