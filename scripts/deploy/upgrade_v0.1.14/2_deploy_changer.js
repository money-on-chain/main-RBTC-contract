/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    console.log('Up-grader Changer Deploy');
    const upgradeChanger = await UpgraderChanger.new(
      config.proxyAddresses.MoC,
      config.implementationAddresses.UpgradeDelegator,
      config.implementationAddresses.MoC
    );

    console.log('Changer address: ', upgradeChanger.address);

    // Save changer address to config file
    config.changerAddresses.Changer = upgradeChanger.address;
    saveConfig(config, configPath);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - Changer');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeChanger.address);
    } else {
      console.log('Executing test governor execute change');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.contract.methods
        .executeChange(config.changerAddresses.Changer)
        .call({ from: config.governorOwnerAddress });
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
