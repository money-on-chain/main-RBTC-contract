/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCConnector = artifacts.require('./MoCConnector.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('./helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const config = getConfig(network);

    // Deploy contract implementation
    console.log('Deploy MoCConnector');
    const mocConnector = await MoCConnector.new();

    // Upgrade contracts with proxy (using the contract address of contract just deployed)
    console.log('Upgrade MoCConnector');
    const upgradeMocConnector = await UpgraderChanger.new(
      config.proxyAddresses.MoCConnector,
      config.implementationAddresses.UpgradeDelegator,
      mocConnector.address
    );

    // Save implementation address and changer address to config file
    config.implementationAddresses.MoCConnector = mocConnector.address;
    config.changerAddresses['3_MoCConnector'] = upgradeMocConnector.address;
    saveConfig(network, config);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - MoCConnector');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeMocConnector.address);
    }

    console.log('MoCConnector implementation address: ', mocConnector.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
