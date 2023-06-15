/* eslint-disable no-console */
const contract = require('truffle-contract');

const MaxGasPriceChanger = artifacts.require('./changers/MaxGasPriceChanger.sol');
const MoC = artifacts.require('./MoC.sol');
const { getConfig, getNetwork } = require('../helper');

const ROC_ABI = [
  {
    constant: true,
    inputs: [],
    name: 'getRiskProRate',
    outputs: [
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256'
      }
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function'
  }
];

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    const changerAddress = config.changerAddresses.MaxGasPriceChanger;
    const changer = await MaxGasPriceChanger.at(changerAddress);

    const RoC = contract({
      abi: ROC_ABI,
      address: config.rocProxyAddresses.MoC
    });

    await RoC.setProvider(MaxGasPriceChanger.currentProvider);

    const changerInfo = {};
    changerInfo.mocProxy = await changer.MOC_proxy();
    changerInfo.mocUpgradeDelegator = await changer.MOC_upgradeDelegator();
    changerInfo.mocNewImplementation = await changer.MOC_newImplementation();

    changerInfo.rocProxy = await changer.ROC_proxy();
    changerInfo.rocUpgradeDelegator = await changer.ROC_upgradeDelegator();
    changerInfo.rocNewImplementation = await changer.ROC_newImplementation();

    changerInfo.maxGasPrice = (await changer.maxGasPrice()).toString();

    console.log('Changer contract parameters');
    const moc = await MoC.at(config.mocProxyAddresses.MoC);
    const roc = await RoC.at(config.rocProxyAddresses.MoC);
    try {
      await moc.getBitProRate();
      console.log('OK. MoC Proxy: ', config.mocProxyAddresses.MoC);
    } catch (error) {
      console.log('ERROR MoC Proxy: ', config.mocProxyAddresses.MoC);
    }
    try {
      await roc.getRiskProRate();
      console.log('OK. RoC Proxy: ', config.rocProxyAddresses.MoC);
    } catch (error) {
      console.log('ERROR RoC Proxy: ', config.rocProxyAddresses.MoC);
    }

    if (changerInfo.mocProxy === config.mocProxyAddresses.MoC) {
      console.log('OK. MoC Proxy: ', changerInfo.mocProxy);
    } else {
      console.log('ERROR! MoC Proxy is not the same ', changerInfo.mocProxy);
    }

    if (changerInfo.mocUpgradeDelegator === config.mocImplementationAddresses.UpgradeDelegator) {
      console.log('OK. MoC UpgradeDelegator: ', changerInfo.mocUpgradeDelegator);
    } else {
      console.log('ERROR! MoC UpgradeDelegator is not the same ', changerInfo.mocUpgradeDelegator);
    }

    if (changerInfo.mocNewImplementation === config.mocImplementationAddresses.MoC) {
      console.log('OK. MoC NewImplementation: ', changerInfo.mocNewImplementation);
    } else {
      console.log(
        'ERROR! MoC NewImplementation is not the same ',
        changerInfo.mocNewImplementation
      );
    }

    if (changerInfo.rocProxy === config.rocProxyAddresses.MoC) {
      console.log('OK. RoC Proxy: ', changerInfo.rocProxy);
    } else {
      console.log('ERROR! RoC Proxy is not the same ', changerInfo.rocProxy);
    }

    if (changerInfo.rocUpgradeDelegator === config.rocImplementationAddresses.UpgradeDelegator) {
      console.log('OK. RoC UpgradeDelegator: ', changerInfo.rocUpgradeDelegator);
    } else {
      console.log('ERROR! RoC UpgradeDelegator is not the same ', changerInfo.rocUpgradeDelegator);
    }

    if (changerInfo.rocNewImplementation === config.rocImplementationAddresses.MoC) {
      console.log('OK. RoC NewImplementation: ', changerInfo.rocNewImplementation);
    } else {
      console.log(
        'ERROR! RoC NewImplementation is not the same ',
        changerInfo.rocNewImplementation
      );
    }

    if (changerInfo.maxGasPrice === config.valuesToAssign.maxGasPrice.toString()) {
      console.log('OK. maxGasPrice: ', changerInfo.maxGasPrice);
    } else {
      console.log('ERROR! maxGasPrice is not the same ', changerInfo.maxGasPrice);
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
