/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const CommissionSplitter = artifacts.require('./CommissionSplitter.sol');
const CommissionSplitterChangerDeploy = artifacts.require('./CommissionSplitterChangerDeploy.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Deploy new CommissionSplitter implementationxs
    console.log('Deploy CommissionSplitter');
    const commissionSplitter = await CommissionSplitter.new();

    // Upgrade contracts with proxy (using the contract address of contract just deployed)
    console.log('Upgrade CommissionSplitter');
    const upgradeCommissionSplitter = await UpgraderChanger.new(
      config.proxyAddresses.CommissionSplitter,
      config.implementationAddresses.UpgradeDelegator,
      commissionSplitter.address
    );

    // Save implementation address and changer address to config file
    config.implementationAddresses.CommissionSplitter = commissionSplitter.address;
    config.changerAddresses['6_CommissionSplitter'] = upgradeCommissionSplitter.address;
    saveConfig(config, configPath);

    let governor;
    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - CommissionSplitter');
      governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeCommissionSplitter.address);
    }

    // Use changer contract
    const commissionSplitterChangerDeploy = await CommissionSplitterChangerDeploy.new(
      config.proxyAddresses.CommissionSplitter,
      config.implementationAddresses.MoCToken,
      config.valuesToAssign.mocTokenCommissionsAddress
    );

    // Save changer address to config file
    config.changerAddresses['6_commissionSplitterChangerDeploy'] =
      commissionSplitterChangerDeploy.address;
    saveConfig(config, configPath);

    if (shouldExecuteChanges(network)) {
      // Execute changes in MoCInrate
      console.log('Execute change - commissionSplitterChangerDeploy');
      await governor.executeChange(commissionSplitterChangerDeploy.address);
    }

    console.log('CommissionSplitter implementation address: ', commissionSplitter.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
