/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const { getConfig, getNetwork } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    const changerAddress = config.changerAddresses.Changer;
    const changer = await UpgraderChanger.at(changerAddress);

    const changerInfo = {};
    changerInfo.proxy = await changer.proxy();
    changerInfo.upgradeDelegator = await changer.upgradeDelegator();
    changerInfo.newImplementation = await changer.newImplementation();

    console.log('Changer contract parameters');

    if (changerInfo.proxy === config.proxyAddresses.MoC) {
      console.log('OK. Proxy MoC.sol contract: ', changerInfo.proxy);
    } else {
      console.log('ERROR! Proxy MoC.sol is not the same ', changerInfo.proxy);
    }

    if (changerInfo.upgradeDelegator === config.implementationAddresses.UpgradeDelegator) {
      console.log('OK. Upgrade Delegator: ', changerInfo.upgradeDelegator);
    } else {
      console.log('ERROR! Upgrade Delegator is not the same ', changerInfo.upgradeDelegator);
    }

    if (changerInfo.newImplementation === config.implementationAddresses.MoC) {
      console.log('OK. New Implementation: ', changerInfo.newImplementation);
    } else {
      console.log('ERROR! New Implementation is not the same ', changerInfo.newImplementation);
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
