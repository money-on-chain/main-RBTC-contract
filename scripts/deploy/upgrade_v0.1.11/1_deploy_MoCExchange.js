/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCExchange = artifacts.require('./MoCExchange.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Link MoCHelperLib
    console.log('Link MoCHelperLib');
    MoCExchange.link('MoCHelperLib', config.implementationAddresses.MoCHelperLib);

    // Deploy contract implementation
    console.log('Deploy MoCExchange');
    const mocExchange = await MoCExchange.new();

    // Upgrade contracts with proxy (using the contract address of contract just deployed)
    console.log('Upgrade MoCExchange');
    const upgradeMocExchange = await UpgraderChanger.new(
      config.proxyAddresses.MoCExchange,
      config.implementationAddresses.UpgradeDelegator,
      mocExchange.address
    );

    // Save implementation address and changer address to config file
    config.implementationAddresses.MoCExchange = mocExchange.address;
    config.changerAddresses['1_MoCExchange'] = upgradeMocExchange.address;
    saveConfig(config, configPath);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - MoCExchange');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeMocExchange.address);
    }

    console.log('MoCExchange implementation address: ', mocExchange.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
