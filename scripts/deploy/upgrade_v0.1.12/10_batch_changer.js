/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const BatchChanger = artifacts.require('./changers/BatchChanger.sol');

const UpgradeDelegator = artifacts.require('./UpgradeDelegator.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const CommissionSplitter = artifacts.require('./CommissionSplitter.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCState = artifacts.require('./MoCState.sol');

const BigNumber = require('bignumber.js');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

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
    // MoC
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods
        .upgrade(config.proxyAddresses.MoC, config.implementationAddresses.MoC)
        .encodeABI()
    );
    // MoCExchange
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods
        .upgrade(config.proxyAddresses.MoCExchange, config.implementationAddresses.MoCExchange)
        .encodeABI()
    );
    // MoCExchange
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods
        .upgrade(config.proxyAddresses.MoCSettlement, config.implementationAddresses.MoCSettlement)
        .encodeABI()
    );
    // CommissionSplitter
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods
        .upgrade(
          config.proxyAddresses.CommissionSplitter,
          config.implementationAddresses.CommissionSplitter
        )
        .encodeABI()
    );
    // MoCInrate
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods
        .upgrade(config.proxyAddresses.MoCInrate, config.implementationAddresses.MoCInrate)
        .encodeABI()
    );
    // MoCInrate
    targets.push(upgradeDelegatorAddress);
    datas.push(
      upgradeDelegator.contract.methods
        .upgrade(config.proxyAddresses.MoCState, config.implementationAddresses.MoCState)
        .encodeABI()
    );

    console.log('Prepare MoCSettlement');
    const moCSettlementAddress = config.proxyAddresses.MoCSettlement;
    const moCSettlement = await MoCSettlement.at(moCSettlementAddress);
    // fixTasksPointer
    targets.push(moCSettlementAddress);
    datas.push(moCSettlement.contract.methods.fixTasksPointer().encodeABI());

    console.log('Prepare CommissionSplitter');
    const commissionSplitterAddress = config.proxyAddresses.CommissionSplitter;
    const commissionSplitter = await CommissionSplitter.at(commissionSplitterAddress);
    // setMocToken
    targets.push(commissionSplitterAddress);
    datas.push(
      commissionSplitter.contract.methods
        .setMocToken(config.implementationAddresses.MoCToken)
        .encodeABI()
    );
    // setMocTokenCommissionAddress
    targets.push(commissionSplitterAddress);
    datas.push(
      commissionSplitter.contract.methods
        .setMocTokenCommissionAddress(config.valuesToAssign.mocTokenCommissionsAddress)
        .encodeABI()
    );

    console.log('Prepare MoCInrate');
    const moCInrateAddress = config.proxyAddresses.MoCInrate;
    const moCInrate = await MoCInrate.at(moCInrateAddress);
    // Setting commissions
    const commissions = await getCommissionsArray(config);
    for (let i = 0; i < commissions.length; i++) {
      targets.push(moCInrateAddress);
      datas.push(
        moCInrate.contract.methods
          .setCommissionRateByTxType(commissions[i].txType, commissions[i].fee)
          .encodeABI()
      );
    }

    console.log('Prepare MoCState');
    const moCStateAddress = config.proxyAddresses.MoCState;
    const moCState = await MoCState.at(moCStateAddress);
    // setMoCPriceProvider
    targets.push(moCStateAddress);
    datas.push(
      moCState.contract.methods
        .setMoCPriceProvider(config.implementationAddresses.MoCPriceProvider)
        .encodeABI()
    );
    // setMoCToken
    targets.push(moCStateAddress);
    datas.push(
      moCState.contract.methods.setMoCToken(config.implementationAddresses.MoCToken).encodeABI()
    );
    // setMoCVendors
    targets.push(moCStateAddress);
    datas.push(
      moCState.contract.methods.setMoCVendors(config.proxyAddresses.MoCVendors).encodeABI()
    );
    // setLiquidationEnabled
    targets.push(moCStateAddress);
    datas.push(
      moCState.contract.methods
        .setLiquidationEnabled(config.valuesToAssign.liquidationEnabled)
        .encodeABI()
    );
    // setProtected
    const mocPrecision = 10 ** 18;
    const protectedValue = BigNumber(config.valuesToAssign.protected)
      .times(mocPrecision)
      .toString();
    targets.push(moCStateAddress);
    datas.push(moCState.contract.methods.setProtected(protectedValue).encodeABI());

    console.log('targets', targets);
    console.log('datas', datas);
    console.log('Schedule change - BatchChanger');
    await batchChanger.scheduleBatch(targets, datas);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - BatchChanger');
      const governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(batchChanger.address);
    } else {
      console.log('Executing test governor execute change');
      const governor = await Governor.at(config.implementationAddresses.Governor);
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
