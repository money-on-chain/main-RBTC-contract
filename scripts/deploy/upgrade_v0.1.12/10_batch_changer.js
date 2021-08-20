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
    const governorAddress = config.implementationAddresses.Governor;
    const { governorOwner } = config;
    console.log('Governor Address', governorAddress);
    const governor = await Governor.at(governorAddress);

    console.log('BatchChanger Deploy');
    //const batchChanger = await BatchChanger.new();
    const batchChanger = await BatchChanger.at(config.changerAddresses.BatchChanger);

    /*// Save changer address to config file
    config.changerAddresses.BatchChanger = batchChanger.address;
    saveConfig(config, configPath);*/

    const tryAndAddToBatch = async (target, data) => {
      console.log('Schedule change - BatchChanger');
      await batchChanger.schedule(target, data);
      await governor.contract.methods
        .executeChange(batchChanger.address)
        .call({ from: governorOwner });
    };

    /*
    console.log('Prepare Upgrades');
    const upgradeDelegatorAddress = config.implementationAddresses.UpgradeDelegator;
    const upgradeDelegator = await UpgradeDelegator.at(upgradeDelegatorAddress);

    const tryAndAddUpgrade = async contract => {
      console.log(`tryAndAddUpgrade ${contract}`);
      const data = upgradeDelegator.contract.methods
        .upgrade(config.proxyAddresses[contract], config.implementationAddresses[contract])
        .encodeABI();
      await tryAndAddToBatch(upgradeDelegator.address, data);
    };

    tryAndAddUpgrade('MoC');
    tryAndAddUpgrade('MoCExchange');
    tryAndAddUpgrade('MoCSettlement');
    tryAndAddUpgrade('CommissionSplitter');
    tryAndAddUpgrade('MoCInrate');
    tryAndAddUpgrade('MoCState');*/

    console.log('Prepare MoCSettlement');
    const moCSettlementAddress = config.proxyAddresses.MoCSettlement;
    const moCSettlement = await MoCSettlement.at(moCSettlementAddress);
    // fixTaskPointer
    const fixTaskPointer = moCSettlement.contract.methods.fixTasksPointer().encodeABI();
    await tryAndAddToBatch(moCSettlementAddress, fixTaskPointer);

    console.log('Prepare CommissionSplitter');
    const commissionSplitterAddress = config.proxyAddresses.CommissionSplitter;
    const commissionSplitter = await CommissionSplitter.at(commissionSplitterAddress);
    // setMocToken
    const setMocToken = commissionSplitter.contract.methods
      .setMocToken(config.implementationAddresses.MoCToken)
      .encodeABI();
    await tryAndAddToBatch(commissionSplitterAddress, setMocToken);
    // setMocTokenCommissionAddress
    const setMocTokenCommissionAddress = commissionSplitter.contract.methods
      .setMocTokenCommissionAddress(config.valuesToAssign.mocTokenCommissionsAddress)
      .encodeABI();
    await tryAndAddToBatch(commissionSplitterAddress, setMocTokenCommissionAddress);

    console.log('Prepare MoCInrate');
    const moCInrateAddress = config.proxyAddresses.MoCInrate;
    const moCInrate = await MoCInrate.at(moCInrateAddress);
    // Setting commissions
    const commissions = await getCommissionsArray(moCInrate)(config);
    for (let i = 0; i < commissions.length; i++) {
      const setCommissionRateByTxType = moCInrate.contract.methods
        .setCommissionRateByTxType(commissions[i].txType, commissions[i].fee)
        .encodeABI();
      // eslint-disable-next-line no-await-in-loop
      await tryAndAddToBatch(moCInrateAddress, setCommissionRateByTxType);
    }

    console.log('Prepare MoCState');
    const moCStateAddress = config.proxyAddresses.MoCState;
    const moCState = await MoCState.at(moCStateAddress);
    // setMoCPriceProvider
    const setMoCPriceProvider = moCState.contract.methods
      .setMoCPriceProvider(config.implementationAddresses.MoCPriceProvider)
      .encodeABI();
    await tryAndAddToBatch(moCStateAddress, setMoCPriceProvider);
    // setMoCToken
    const setMoCToken = moCState.contract.methods
      .setMoCToken(config.implementationAddresses.MoCToken)
      .encodeABI();
    await tryAndAddToBatch(moCStateAddress, setMoCToken);
    // setMoCVendors
    const setMoCVendors = moCState.contract.methods
      .setMoCVendors(config.proxyAddresses.MoCVendors)
      .encodeABI();
    await tryAndAddToBatch(moCStateAddress, setMoCVendors);
    // setLiquidationEnabled
    const setLiquidationEnabled = moCState.contract.methods
      .setLiquidationEnabled(config.valuesToAssign.liquidationEnabled)
      .encodeABI();
    await tryAndAddToBatch(moCStateAddress, setLiquidationEnabled);
    // setProtected
    const mocPrecision = 10 ** 18;
    const protectedValue = BigNumber(config.valuesToAssign.protected)
      .times(mocPrecision)
      .toString();
    const setProtected = moCState.contract.methods.setProtected(protectedValue).encodeABI();
    await tryAndAddToBatch(moCStateAddress, setProtected);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - BatchChanger');
      await governor.executeChange(batchChanger.address);
    }

    console.log('BatchChanger address: ', batchChanger.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
