/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const BatchChanger = artifacts.require('./changers/BatchChanger.sol');

const MoC = artifacts.require('./MoC.sol');
const MoCBProxManager = artifacts.require('./MoCBProxManager.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');
const CommissionSplitter = artifacts.require('./CommissionSplitter.sol');
const MoCVendors = artifacts.require('./MoCVendors.sol');
const UpgradeDelegator = artifacts.require('./UpgradeDelegator.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

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

    console.log('Prepare changers');

    console.log('Prepare change governor MoC.sol');
    const mocAddress = config.contracts.MoC;
    const moc = await MoC.at(mocAddress);
    targets.push(mocAddress);
    datas.push(moc.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI());

    console.log('Prepare change governor MoCBProxManager.sol');
    const mocBProxManagerAddress = config.contracts.MoCBProxManager;
    const mocBProxManager = await MoCBProxManager.at(mocBProxManagerAddress);
    targets.push(mocBProxManagerAddress);
    datas.push(
      mocBProxManager.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI()
    );

    console.log('Prepare change governor MoCSettlement.sol');
    const mocSettlementAddress = config.contracts.MoCSettlement;
    const mocSettlement = await MoCSettlement.at(mocSettlementAddress);
    targets.push(mocSettlementAddress);
    datas.push(
      mocSettlement.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI()
    );

    console.log('Prepare change governor MoCInrate.sol');
    const mocInrateAddress = config.contracts.MoCInrate;
    const mocInrate = await MoCInrate.at(mocInrateAddress);
    targets.push(mocInrateAddress);
    datas.push(mocInrate.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI());

    console.log('Prepare change governor MoCState.sol');
    const mocStateAddress = config.contracts.MoCState;
    const mocState = await MoCState.at(mocStateAddress);
    targets.push(mocStateAddress);
    datas.push(mocState.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI());

    console.log('Prepare change governor MoCVendors.sol');
    const mocVendorsAddress = config.contracts.MoCVendors;
    const mocVendors = await MoCVendors.at(mocVendorsAddress);
    targets.push(mocVendorsAddress);
    datas.push(mocVendors.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI());

    console.log('Prepare change governor CommissionSplitter.sol');
    const commissionSplitterAddress = config.contracts.CommissionSplitter;
    const commissionSplitter = await CommissionSplitter.at(commissionSplitterAddress);
    targets.push(commissionSplitterAddress);
    datas.push(
      commissionSplitter.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI()
    );

    console.log('Prepare change governor UpgradeDelegator.sol');
    const upgradeDelegatorAddress = config.contracts.UpgradeDelegator;
    const upgradeDelegator = await UpgradeDelegator.at(upgradeDelegatorAddress);
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI()
    );

    console.log('targets', targets);
    console.log('datas', datas);
    console.log('Schedule change - BatchChanger');
    await batchChanger.scheduleBatch(targets, datas);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - BatchChanger');
      const governor = await Governor.at(config.contracts.Governor);
      await governor.executeChange(batchChanger.address);
    } else {
      console.log('Executing test governor execute change');
      const governor = await Governor.at(config.contracts.Governor);
      await governor.contract.methods
        .executeChange(config.changerAddresses.BatchChanger)
        .call({ from: config.governorOwnerAddress });
    }

    console.log('BatchChanger address: ', batchChanger.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
