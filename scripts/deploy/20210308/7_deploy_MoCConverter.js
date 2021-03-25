/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCConverter = artifacts.require('./MoCConverter.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Link MoCHelperLib
    console.log('Link MoCHelperLib');
    MoCConverter.link('MoCHelperLib', config.implementationAddresses.MoCHelperLib);

    // Deploy contract implementation
    console.log('Deploy MoCConverter');
    const mocConverter = await MoCConverter.new();

    // Upgrade contracts with proxy (using the contract address of contract just deployed)
    console.log('Upgrade MoCConverter');
    const upgradeMocConverter = await UpgraderChanger.new(
      config.proxyAddresses.MoCConverter,
      config.implementationAddresses.UpgradeDelegator,
      mocConverter.address
    );

    // Save implementation address and changer address to config file
    config.implementationAddresses.MoCConverter = mocConverter.address;
    config.changerAddresses['7_MoCConverter'] = upgradeMocConverter.address;
    saveConfig(config, configPath);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - MoCConverter');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeMocConverter.address);
    }

    console.log('MoCConverter implementation address: ', mocConverter.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
