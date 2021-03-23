/* eslint-disable no-console */
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCInrateChangerDeploy = artifacts.require('./MocInrateChangerDeploy.sol');

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

    // Deploy contract implementation
    console.log('Deploy MoCInrate');
    const mocInrate = await MoCInrate.new();

    // Upgrade contracts with proxy (using the contract address of contract just deployed)
    console.log('Upgrade MoCInrate');
    const upgradeMocInrate = await UpgraderChanger.new(
      config.proxyAddresses.MoCInrate,
      config.implementationAddresses.UpgradeDelegator,
      mocInrate.address
    );

    // Save implementation address and changer address to config file
    config.implementationAddresses.MoCInrate = mocInrate.address;
    config.changerAddresses['6_MoCInrate'] = upgradeMocInrate.address;
    saveConfig(network, config);

    let governor;
    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - MoCInrate');
      governor = await Governor.at(config.implementationAddresses.Governor);
      await governor.executeChange(upgradeMocInrate.address);
    }

    // Setting commissions
    const commissions = await getCommissionsArray(mocInrate)(config);

    // Use changer contract
    const mocInrateChangerDeploy = await MoCInrateChangerDeploy.new(
      config.proxyAddresses.MoCInrate,
      commissions
    );

    // Save changer address to config file
    config.changerAddresses['6_MoCInrateChangerDeploy'] = mocInrateChangerDeploy.address;
    saveConfig(network, config);

    if (shouldExecuteChanges(network)) {
      // Execute changes in MoCInrate
      console.log('Execute change - MoCInrateChangerDeploy');
      await governor.executeChange(mocInrateChangerDeploy.address);
    }

    console.log('MoCInrate implementation address: ', mocInrate.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
