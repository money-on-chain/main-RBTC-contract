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
    changerInfo.upgradeDelegator = await changer.upgradeDelegator();
    changerInfo.mocProxy = await changer.MOC_proxy();
    changerInfo.mocNewImplementation = await changer.MOC_newImplementation();

    changerInfo.rocProxy = await changer.ROC_proxy();
    changerInfo.rocNewImplementation = await changer.ROC_newImplementation();

    changerInfo.stopperNewImplementation = await changer.stopper_newImplementation();

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

    if (
      changerInfo.upgradeDelegator === config.governanceImplementationAddresses.UpgradeDelegator
    ) {
      console.log('OK. UpgradeDelegator: ', changerInfo.upgradeDelegator);
    } else {
      console.log('ERROR! UpgradeDelegator is not the same ', changerInfo.upgradeDelegator);
    }

    if (changerInfo.mocProxy === config.mocProxyAddresses.MoC) {
      console.log('OK. MoC Proxy: ', changerInfo.mocProxy);
    } else {
      console.log('ERROR! MoC Proxy is not the same ', changerInfo.mocProxy);
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

    if (changerInfo.rocNewImplementation === config.rocImplementationAddresses.MoC) {
      console.log('OK. RoC NewImplementation: ', changerInfo.rocNewImplementation);
    } else {
      console.log(
        'ERROR! RoC NewImplementation is not the same ',
        changerInfo.rocNewImplementation
      );
    }

    if (changerInfo.stopperNewImplementation === config.governanceImplementationAddresses.Stopper) {
      console.log('OK. Stopper NewImplementation: ', changerInfo.stopperNewImplementation);
    } else {
      console.log(
        'ERROR! Stopper NewImplementation is not the same ',
        changerInfo.stopperNewImplementation
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
