/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoC = artifacts.require('./MoC.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Deploy contract implementation
    console.log('Deploy MoC');
    const moc = await MoC.new(MoC);

    // Upgrade contracts with proxy (using the contract address of contract just deployed)
    console.log('Upgrade MoC');
    const upgradeMoc = await UpgraderChanger.new(
      config.proxyAddresses.MoC,
      config.implementationAddresses.UpgradeDelegator,
      moc.address
    );

    // Save implementation address and changer address to config file
    config.implementationAddresses.MoC = moc.address;
    config.changerAddresses['3_MoC'] = upgradeMoc.address;
    saveConfig(network, config);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - MoC');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeMoc.address);
    }

    console.log('MoC implementation address: ', moc.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
