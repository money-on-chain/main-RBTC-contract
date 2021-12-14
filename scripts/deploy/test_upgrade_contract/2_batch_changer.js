/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const BatchChanger = artifacts.require('./changers/BatchChanger.sol');

const UpgradeDelegator = artifacts.require('./UpgradeDelegator.sol');
const { getConfig, getNetwork, saveConfig } = require('../helper');


module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    console.log('BatchChanger Deploy');
    const batchChanger = await BatchChanger.new();
    // Save changer address to config file
    config.changerAddresses.BatchChanger = batchChanger.address;
    saveConfig(config, configPath);

    const targets = [];
    const datas = [];

    console.log('Prepare Upgrades');
    const upgradeDelegatorAddress = config.implementationAddresses.UpgradeDelegator;
    const upgradeDelegator = await UpgradeDelegator.at(upgradeDelegatorAddress);

    // MoCSettlement
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods
        .upgrade(config.proxyAddresses.MoCSettlement, config.implementationAddresses.MoCSettlement)
        .encodeABI()
    );

    console.log('targets', targets);
    console.log('datas', datas);
    console.log('Schedule change - BatchChanger');
    await batchChanger.scheduleBatch(targets, datas);

    console.log('BatchChanger address: ', batchChanger.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
