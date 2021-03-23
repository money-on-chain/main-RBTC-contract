/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCSettlement = artifacts.require('./MoCSettlement.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Deploy contract implementation
    console.log('Deploy MoCSettlement');
    const mocSettlement = await MoCSettlement.new();

    // Upgrade contracts with proxy (using the contract address of contract just deployed)
    console.log('Upgrade MoCSettlement');
    const upgradeMocSettlement = await UpgraderChanger.new(
      config.proxyAddresses.MoCSettlement,
      config.implementationAddresses.UpgradeDelegator,
      mocSettlement.address
    );

    // Save implementation address and changer address to config file
    config.implementationAddresses.MoCSettlement = mocSettlement.address;
    config.changerAddresses['5_MoCSettlement'] = upgradeMocSettlement.address;
    saveConfig(config, configPath);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - MoCSettlement');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeMocSettlement.address);
    }

    console.log('MoCSettlement implementation address: ', mocSettlement.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
