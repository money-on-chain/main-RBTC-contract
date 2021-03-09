/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCConverter = artifacts.require('./MoCConverter.sol');

const deployConfig = require('./deployConfig.json');

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Get proxy contract
    const proxyMocConverter = await AdminUpgradeabilityProxy.at(
      deployConfig[currentNetwork].addresses.MoCConverter
    );

    // Upgrade delegator and Governor addresses (used to make changes to contracts)
    const upgradeDelegatorAddress = deployConfig[currentNetwork].addresses.UpgradeDelegator;
    const governor = await Governor.at(deployConfig[currentNetwork].addresses.Governor);

    // Deploy contract implementation
    console.log('- Deploy MoCConverter');
    const mocConverter = await deployer.deploy(MoCConverter);

    // Upgrade contracts with proxy (using the contract address of contracts just deployed)
    console.log('- Upgrade MoCConverter');
    const upgradeMocConverter = await deployer.deploy(
      UpgraderChanger,
      proxyMocConverter.address,
      upgradeDelegatorAddress,
      mocConverter.address
    );

    // Execute changes in contracts
    console.log('Execute change - MoCConverter');
    await governor.executeChange(upgradeMocConverter.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
