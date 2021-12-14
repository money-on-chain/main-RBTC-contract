/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const BatchChanger = artifacts.require('./changers/BatchChanger.sol');
const UpgradeDelegator = artifacts.require('./UpgradeDelegator.sol');

const BigNumber = require('bignumber.js');
const { getConfig, getNetwork, shouldExecuteChanges } = require('../helper');


module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const error = [];
    let msjError;

    console.log(`BatchChanger Deploy at: ${config.changerAddresses.BatchChanger}`);
    const batchChanger = await BatchChanger.at(config.changerAddresses.BatchChanger);

    const lengthData = await batchChanger.datasToExecuteLength();
    const lengthTarget = await batchChanger.targetsToExecuteLength();

    const upgradeDelegatorAddress = config.implementationAddresses.UpgradeDelegator;
    const upgradeDelegator = await UpgradeDelegator.at(upgradeDelegatorAddress);

    console.log('Length Data: ', lengthData.toString());
    console.log('Length Target: ', lengthTarget.toString());

    if (lengthData.toString() !== lengthTarget.toString()) {
      msjError = 'ERROR! Not valid array length';
      console.log(msjError);
      error.push(msjError);
    } else {
      console.log('OK! length of arrays');
    }

    // STEP 0 MoCSettlement.sol Implementation Upgrade

    step = 0;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = upgradeDelegatorAddress;
    encodeData = upgradeDelegator.contract.methods
      .upgrade(config.proxyAddresses.MoCSettlement, config.implementationAddresses.MoCSettlement)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. MoCSettlement.sol [${config.proxyAddresses.MoCSettlement}] Upgrade to implementation [${config.implementationAddresses.MoCSettlement}].`
      );
    } else {
      msjError = `ERROR! NOT VALID! STEP: ${step}.`;
      console.log(msjError);
      error.push(msjError);
    }

    if (error.length === 0) {
      const governor = await Governor.at(config.implementationAddresses.Governor);
      if (shouldExecuteChanges(network)) {
        // Execute changes in contracts
        console.log('Execute change - BatchChanger');
        await governor.executeChange(batchChanger.address);
      } else {
        console.log('Executing test governor execute change');
        await governor.contract.methods
          .executeChange(config.changerAddresses.BatchChanger)
          .call({ from: config.governorOwnerAddress });
      }
    } else {
      console.log(
        'The change was not executed by governor, becase they have this errors: \n *',
        error.join('\n * ')
      );
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
