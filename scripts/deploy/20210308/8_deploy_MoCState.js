/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCState = artifacts.require('./MoCState.sol');
const MoCStateMock = artifacts.require('./mocks/MoCStateMock.sol');
const MoCStateChangerDeploy = artifacts.require('./MoCStateChangerDeploy.sol');

const BigNumber = require('bignumber.js');
const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    // Link MoCHelperLib
    console.log('Link MoCHelperLib');
    MoCState.link('MoCHelperLib', config.implementationAddresses.MoCHelperLib);

    // Deploy contract implementation
    console.log('Deploy MoCState');
    let mocState;
    if (network === 'development') {
      mocState = await MoCStateMock.new();
    } else {
      mocState = await MoCState.new();
    }

    // Upgrade contracts with proxy (using the contract address of contract just deployed)
    console.log('Upgrade MoCState');
    const upgradeMocState = await UpgraderChanger.new(
      config.proxyAddresses.MoCState,
      config.implementationAddresses.UpgradeDelegator,
      mocState.address
    );

    // Save implementation address and changer address to config file
    config.implementationAddresses.MoCState = mocState.address;
    config.changerAddresses['8_MoCState'] = upgradeMocState.address;
    saveConfig(config, configPath);

    let governor;
    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - MoCState');
      governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeMocState.address);
    }

    const mocPrecision = 10 ** 18;
    const protectedValue = BigNumber(config.valuesToAssign.protected)
      .times(mocPrecision)
      .toString();

    // Use changer contract
    const mocStateChangerDeploy = await MoCStateChangerDeploy.new(
      config.proxyAddresses.MoCState,
      config.implementationAddresses.MoCPriceProvider,
      config.implementationAddresses.MoCToken,
      config.proxyAddresses.MoCVendors, // NEWLY DEPLOYED
      config.valuesToAssign.liquidationEnabled,
      protectedValue
    );

    // Save changer address to config file
    config.changerAddresses['9_MoCInrateChangerDeploy'] = mocStateChangerDeploy.address;
    saveConfig(config, configPath);

    if (shouldExecuteChanges(network)) {
      // Execute changes in MoCState
      console.log('Execute change - MoCStateChangerDeploy');
      await governor.executeChange(mocStateChangerDeploy.address);
    }

    console.log('MoCState implementation address: ', mocState.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
