/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCSettlement = artifacts.require('./MoCSettlement.sol');

const deployConfig = require('./deployConfig.json');

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Get proxy contract
    const proxyMocSettlement = await AdminUpgradeabilityProxy.at(
      deployConfig[currentNetwork].addresses.MoCSettlement
    );

    // Upgrade delegator and Governor addresses (used to make changes to contracts)
    const upgradeDelegatorAddress = deployConfig[currentNetwork].addresses.UpgradeDelegator;
    const governor = await Governor.at(deployConfig[currentNetwork].addresses.Governor);

    // Deploy contract implementation
    console.log('- Deploy MoCSettlement');
    const mocSettlement = await deployer.deploy(MoCSettlement);

    // Upgrade contracts with proxy (using the contract address of contracts just deployed)
    console.log('- Upgrade MoCSettlement');
    const upgradeMocSettlement = await deployer.deploy(
      UpgraderChanger,
      proxyMocSettlement.address,
      upgradeDelegatorAddress,
      mocSettlement.address
    );

    // Execute changes in contracts
    console.log('Execute change - MoCSettlement');
    await governor.executeChange(upgradeMocSettlement.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
