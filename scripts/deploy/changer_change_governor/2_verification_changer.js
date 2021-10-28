/* eslint-disable no-console */

const BatchChanger = artifacts.require('./changers/BatchChanger.sol');
const UpgradeDelegator = artifacts.require('./UpgradeDelegator.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const CommissionSplitter = artifacts.require('./CommissionSplitter.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCState = artifacts.require('./MoCState.sol');
const MoC = artifacts.require('./MoC.sol');
const MoCBProxManager = artifacts.require('./MoCBProxManager.sol');
const MoCVendors = artifacts.require('./MoCVendors.sol');

const BigNumber = require('bignumber.js');
const { getConfig, getNetwork } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    console.log(`BatchChanger Deploy at: ${config.changerAddresses.BatchChanger}`);
    const batchChanger = await BatchChanger.at(config.changerAddresses.BatchChanger);

    const lengthData = await batchChanger.datasToExecuteLength();
    const lengthTarget = await batchChanger.targetsToExecuteLength();

    const upgradeDelegatorAddress = config.contracts.UpgradeDelegator;
    const upgradeDelegator = await UpgradeDelegator.at(upgradeDelegatorAddress);

    console.log('Length Data: ', lengthData.toString());
    console.log('Length Target: ', lengthTarget.toString());

    if (lengthData.toString() !== lengthTarget.toString()) {
      console.log('ERROR! Not valid array length');
    } else {
      console.log('OK! length of arrays');
    }

    // STEP 0 MoC.sol ChangeIGovernor
    step = 0;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.contracts.MoC;
    const moC = await MoC.at(target);

    encodeData = moC.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`OK! STEP ${step}. MoC.sol : [ChangeIGovernor(${config.newGovernorAddress})]`);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 1 mocBProxManager.sol ChangeIGovernor
    step = 1;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.contracts.MoCBProxManager;
    const moCBProxManager = await MoCBProxManager.at(target);

    encodeData = moCBProxManager.contract.methods
      .changeIGovernor(config.newGovernorAddress)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`
                  OK! STEP ${step}. MoCBProxManager.sol : [ChangeIGovernor(${config.newGovernorAddress})]
                  `);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 2 MoCSettlement.sol ChangeIGovernor
    step = 2;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.contracts.MoCSettlement;
    const moCSettlement = await MoCSettlement.at(target);

    encodeData = moCSettlement.contract.methods
      .changeIGovernor(config.newGovernorAddress)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`
                  OK! STEP ${step}. MoCSettlement.sol : [ChangeIGovernor(${config.newGovernorAddress})]
                  `);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 3  MoCInrate.sol ChangeIGovernor
    step = 3;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.contracts.MoCInrate;
    const moCInrate = await MoCInrate.at(target);

    encodeData = moCInrate.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`
                  OK! STEP ${step}. MoCInrate.sol : [ChangeIGovernor(${config.newGovernorAddress})]
                  `);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 4  MoCState.sol ChangeIGovernor
    step = 4;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.contracts.MoCState;
    const moCState = await MoCState.at(target);

    encodeData = moCState.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`
                  OK! STEP ${step}. MoCState.sol : [ChangeIGovernor(${config.newGovernorAddress})]
                  `);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 5  MoCVendors.sol ChangeIGovernor
    step = 5;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.contracts.MoCVendors;
    const moCVendors = await MoCVendors.at(target);

    encodeData = moCVendors.contract.methods.changeIGovernor(config.newGovernorAddress).encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`
                  OK! STEP ${step}. MoCVendors.sol : [ChangeIGovernor(${config.newGovernorAddress})]
                  `);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 6  CommissionSplitter.sol ChangeIGovernor
    step = 6;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.contracts.CommissionSplitter;
    const commissionSplitter = await CommissionSplitter.at(target);

    encodeData = commissionSplitter.contract.methods
      .changeIGovernor(config.newGovernorAddress)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`
                  OK! STEP ${step}. CommissionSplitter.sol : [ChangeIGovernor(${config.newGovernorAddress})]
                  `);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 7  UpgradeDelegator.sol ChangeIGovernor
    step = 7;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.contracts.UpgradeDelegator;

    encodeData = upgradeDelegator.contract.methods
      .changeIGovernor(config.newGovernorAddress)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`
                  OK! STEP ${step}. UpgradeDelegator.sol : [ChangeIGovernor(${config.newGovernorAddress})]
                  `);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
