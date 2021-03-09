/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCExchange = artifacts.require('./MoCExchange.sol');

const deployConfig = require('./deployConfig.json');

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Get proxy contract
    const proxyMocExchange = await AdminUpgradeabilityProxy.at(
      deployConfig[currentNetwork].addresses.MoCExchange
    );

    // Upgrade delegator and Governor addresses (used to make changes to contracts)
    const upgradeDelegatorAddress = deployConfig[currentNetwork].addresses.UpgradeDelegator;
    const governor = await Governor.at(deployConfig[currentNetwork].addresses.Governor);

    // Deploy contract implementation
    console.log('- Deploy MoCExchange');
    const mocExchange = await deployer.deploy(MoCExchange);

    // Upgrade contracts with proxy (using the contract address of contracts just deployed)
    console.log('- Upgrade MoCExchange');
    const upgradeMocExchange = await deployer.deploy(
      UpgraderChanger,
      proxyMocExchange.address,
      upgradeDelegatorAddress,
      mocExchange.address
    );

    // Execute changes in contracts
    console.log('Execute change - MoCExchange');
    await governor.executeChange(upgradeMocExchange.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
