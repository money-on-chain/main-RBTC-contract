/* eslint-disable no-console */

const BatchChanger = artifacts.require('./changers/BatchChanger.sol');
const UpgradeDelegator = artifacts.require('./UpgradeDelegator.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const CommissionSplitter = artifacts.require('./CommissionSplitter.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCState = artifacts.require('./MoCState.sol');

const BigNumber = require('bignumber.js');
const { getConfig, getNetwork } = require('../helper');

const getCommissionsArray = async config => {
  const mocPrecision = 10 ** 18;
  const MINT_BPRO_FEES_RBTC = '1';
  const REDEEM_BPRO_FEES_RBTC = '2';
  const MINT_DOC_FEES_RBTC = '3';
  const REDEEM_DOC_FEES_RBTC = '4';
  const MINT_BTCX_FEES_RBTC = '5';
  const REDEEM_BTCX_FEES_RBTC = '6';
  const MINT_BPRO_FEES_MOC = '7';
  const REDEEM_BPRO_FEES_MOC = '8';
  const MINT_DOC_FEES_MOC = '9';
  const REDEEM_DOC_FEES_MOC = '10';
  const MINT_BTCX_FEES_MOC = '11';
  const REDEEM_BTCX_FEES_MOC = '12';

  const ret = [
    {
      txType: MINT_BPRO_FEES_RBTC,
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_BPRO_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_BPRO_FEES_RBTC,
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_BPRO_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_DOC_FEES_RBTC,
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_DOC_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_DOC_FEES_RBTC,
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_DOC_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_BTCX_FEES_RBTC,
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_BTCX_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_BTCX_FEES_RBTC,
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_BTCX_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_BPRO_FEES_MOC,
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_BPRO_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_BPRO_FEES_MOC,
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_BPRO_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_DOC_FEES_MOC,
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_DOC_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_DOC_FEES_MOC,
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_DOC_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_BTCX_FEES_MOC,
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_BTCX_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_BTCX_FEES_MOC,
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_BTCX_FEES_MOC)
        .times(mocPrecision)
        .toString()
    }
  ];
  return ret;
};

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    console.log(`BatchChanger Deploy at: ${config.changerAddresses.BatchChanger}`);
    const batchChanger = await BatchChanger.at(config.changerAddresses.BatchChanger);

    const lengthData = await batchChanger.datasToExecuteLength();
    const lengthTarget = await batchChanger.targetsToExecuteLength();

    const upgradeDelegatorAddress = config.implementationAddresses.UpgradeDelegator;
    const upgradeDelegator = await UpgradeDelegator.at(upgradeDelegatorAddress);

    console.log('Length Data: ', lengthData.toString());
    console.log('Length Target: ', lengthTarget.toString());

    if (lengthData.toString() !== lengthTarget.toString()) {
      console.log('ERROR! Not valid array length');
    } else {
      console.log('OK! length of arrays');
    }

    // STEP 0 MoC.sol Implementation Upgrade

    let step = 0;
    let targetBatch = await batchChanger.targetsToExecute(step);
    let dataBatch = await batchChanger.datasToExecute(step);

    let target = upgradeDelegatorAddress;
    let encodeData = upgradeDelegator.contract.methods
      .upgrade(config.proxyAddresses.MoC, config.implementationAddresses.MoC)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP 0. MoC.sol [${config.proxyAddresses.MoC}] Upgrade to implementation [${config.implementationAddresses.MoC}].`
      );
    } else {
      console.log('ERROR! NOT VALID! STEP 0.');
    }

    // STEP 1 MoCExchange.sol Implementation Upgrade

    step = 1;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = upgradeDelegatorAddress;
    encodeData = upgradeDelegator.contract.methods
      .upgrade(config.proxyAddresses.MoCExchange, config.implementationAddresses.MoCExchange)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. MoCExchange.sol [${config.proxyAddresses.MoCExchange}] Upgrade to implementation [${config.implementationAddresses.MoCExchange}].`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 2 MoCSettlement.sol Implementation Upgrade

    step = 2;
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
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 3 CommissionSplitter.sol Implementation Upgrade

    step = 3;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = upgradeDelegatorAddress;
    encodeData = upgradeDelegator.contract.methods
      .upgrade(
        config.proxyAddresses.CommissionSplitter,
        config.implementationAddresses.CommissionSplitter
      )
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. CommissionSplitter.sol [${config.proxyAddresses.CommissionSplitter}] Upgrade to implementation [${config.implementationAddresses.CommissionSplitter}].`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 4 MoCInrate.sol Implementation Upgrade

    step = 4;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = upgradeDelegatorAddress;
    encodeData = upgradeDelegator.contract.methods
      .upgrade(config.proxyAddresses.MoCInrate, config.implementationAddresses.MoCInrate)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. MoCInrate.sol [${config.proxyAddresses.MoCInrate}] Upgrade to implementation [${config.implementationAddresses.MoCInrate}].`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 5 MoCState.sol Implementation Upgrade

    step = 5;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = upgradeDelegatorAddress;
    encodeData = upgradeDelegator.contract.methods
      .upgrade(config.proxyAddresses.MoCState, config.implementationAddresses.MoCState)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. MoCState.sol [${config.proxyAddresses.MoCState}] Upgrade to implementation [${config.implementationAddresses.MoCState}].`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 6 Prepare MoCSettlement

    step = 6;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.proxyAddresses.MoCSettlement;
    const moCSettlement = await MoCSettlement.at(target);

    encodeData = moCSettlement.contract.methods.fixTasksPointer().encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(`OK! STEP ${step}. Prepare moCSettlement.sol execute: [fixTasksPointer()]`);
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 7 Prepare commissionSplitter - SetMoCToken

    step = 7;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.proxyAddresses.CommissionSplitter;
    const commissionSplitter = await CommissionSplitter.at(target);

    encodeData = commissionSplitter.contract.methods
      .setMocToken(config.implementationAddresses.MoCToken)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. Prepare commissionSplitter.sol execute: [setMocToken(${config.implementationAddresses.MoCToken})]`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 8 Prepare commissionSplitter - mocTokenCommissionsAddress

    step = 8;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.proxyAddresses.CommissionSplitter;

    encodeData = commissionSplitter.contract.methods
      .setMocTokenCommissionAddress(config.valuesToAssign.mocTokenCommissionsAddress)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. Prepare commissionSplitter.sol execute: [setMocTokenCommissionAddress(${config.valuesToAssign.mocTokenCommissionsAddress})]`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 9 Prepare MoCInrate - setCommissionRateByTxType

    step = 9;
    let varStep = 9;

    target = config.proxyAddresses.MoCInrate;
    const moCInrate = await MoCInrate.at(target);

    const commissions = await getCommissionsArray(config);
    /* eslint-disable no-await-in-loop */
    for (let i = 0; i < commissions.length; i++) {
      targetBatch = await batchChanger.targetsToExecute(varStep);
      dataBatch = await batchChanger.datasToExecute(varStep);

      encodeData = moCInrate.contract.methods
        .setCommissionRateByTxType(commissions[i].txType, commissions[i].fee)
        .encodeABI();

      if (dataBatch === encodeData && target === targetBatch) {
        console.log(
          `OK! STEP ${varStep}. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(${commissions[i].txType}, ${commissions[i].fee})]`
        );
      } else {
        console.log(`ERROR! NOT VALID! STEP: ${varStep}.`);
      }

      varStep += 1;
    }
    /* eslint-enable no-await-in-loop */

    // STEP 21 Prepare MoCState - setMoCPriceProvider

    step = 21;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.proxyAddresses.MoCState;
    const moCState = await MoCState.at(target);
    encodeData = moCState.contract.methods
      .setMoCPriceProvider(config.implementationAddresses.MoCPriceProvider)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. Prepare moCState.sol execute: [setMoCPriceProvider(${config.implementationAddresses.MoCPriceProvider})]`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 22 Prepare MoCState - setMoCToken

    step = 22;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.proxyAddresses.MoCState;
    encodeData = moCState.contract.methods
      .setMoCToken(config.implementationAddresses.MoCToken)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. Prepare moCState.sol execute: [setMoCToken(${config.implementationAddresses.MoCToken})]`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 23 Prepare MoCState - setMoCVendors

    step = 23;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.proxyAddresses.MoCState;
    encodeData = moCState.contract.methods
      .setMoCVendors(config.proxyAddresses.MoCVendors)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. Prepare moCState.sol execute: [setMoCVendors(${config.proxyAddresses.MoCVendors})]`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 24 Prepare MoCState - setLiquidationEnabled

    step = 24;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.proxyAddresses.MoCState;
    encodeData = moCState.contract.methods
      .setLiquidationEnabled(config.valuesToAssign.liquidationEnabled)
      .encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. Prepare moCState.sol execute: [setLiquidationEnabled(${config.valuesToAssign.liquidationEnabled})]`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }

    // STEP 25 Prepare MoCState - setProtected

    step = 25;
    targetBatch = await batchChanger.targetsToExecute(step);
    dataBatch = await batchChanger.datasToExecute(step);

    target = config.proxyAddresses.MoCState;

    const mocPrecision = 10 ** 18;
    const protectedValue = BigNumber(config.valuesToAssign.protected)
      .times(mocPrecision)
      .toString();
    encodeData = moCState.contract.methods.setProtected(protectedValue).encodeABI();

    if (dataBatch === encodeData && target === targetBatch) {
      console.log(
        `OK! STEP ${step}. Prepare moCState.sol execute: [setProtected(${config.valuesToAssign.protected})]`
      );
    } else {
      console.log(`ERROR! NOT VALID! STEP: ${step}.`);
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
