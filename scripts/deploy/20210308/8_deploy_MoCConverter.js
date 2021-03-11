/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCConverter = artifacts.require('./MoCConverter.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('./helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const config = getConfig(network);

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
    config.changerAddresses['8_MoCConverter'] = upgradeMocConverter.address;
    saveConfig(network, config);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - MoCConverter');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeMocConverter.address);
    }

    console.log('MoCConverter implementation address: ', mocConverter.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
