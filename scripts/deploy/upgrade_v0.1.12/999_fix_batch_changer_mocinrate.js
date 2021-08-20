/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const BatchChanger = artifacts.require('./changers/BatchChanger.sol');

const UpgradeDelegator = artifacts.require('./UpgradeDelegator.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');

const BigNumber = require('bignumber.js');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

const getCommissionsArray = mocInrate => async config => {
  const mocPrecision = 10 ** 18;

  const ret = [
    {
      txType: (await mocInrate.MINT_BPRO_FEES_RBTC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_BPRO_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_RBTC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_BPRO_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_RBTC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_DOC_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_RBTC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_DOC_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_RBTC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_BTCX_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_RBTC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_BTCX_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BPRO_FEES_MOC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_BPRO_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_MOC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_BPRO_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_MOC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_DOC_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_MOC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.REDEEM_DOC_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_MOC()).toString(),
      fee: BigNumber(config.valuesToAssign.commissionRates.MINT_BTCX_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_MOC()).toString(),
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


    // MoCInrate
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods
        .upgrade(config.proxyAddresses.MoCInrate, config.implementationAddresses.MoCInrate)
        .encodeABI()
    );

    console.log('Prepare MoCInrate');
    const moCInrateAddress = config.proxyAddresses.MoCInrate;
    const moCInrate = await MoCInrate.at(moCInrateAddress);
    // Setting commissions
    const commissions = await getCommissionsArray(moCInrate)(config);
    for (let i = 0; i < commissions.length; i++) {
      targets.push(moCInrateAddress);
      datas.push(
        moCInrate.contract.methods
          .setCommissionRateByTxType(commissions[i].txType, commissions[i].fee)
          .encodeABI()
      );
    }

    console.log('targets', targets);
    console.log('datas', datas);
    console.log('Schedule change - BatchChanger');
    await batchChanger.scheduleBatch(targets, datas);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - BatchChanger');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(batchChanger.address);
    }

    console.log('BatchChanger address: ', batchChanger.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
