/* eslint-disable no-console */
const contract = require('truffle-contract');

const CommissionSplitterFixOutputRevAuc = artifacts.require('./changers/proposal_commission_splitter_revauc_fix/CommissionSplitterFixOutputRevAuc.sol');
const { getConfig, getNetwork } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    const changerAddress = config.CommissionSplitterFixOutputRevAuc.changer;

    console.log('Reading Changer with address: ', changerAddress);

    const changer = await CommissionSplitterFixOutputRevAuc.at(changerAddress);

    const changerInfo = {};
    changerInfo.commissionSplitterV2 = await changer.commissionSplitterV2();
    changerInfo.commissionSplitterV3 = await changer.commissionSplitterV3();
    changerInfo.revAucBTC2MOC = await changer.revAucBTC2MOC();
    changerInfo.revAucMOC2BTC = await changer.revAucMOC2BTC();

    console.log('Changer contract parameters');

    if (changerInfo.commissionSplitterV2 === config.CommissionSplitterFixOutputRevAuc.commissionSplitterV2) {
      console.log('OK. commissionSplitterV2 contract: ', changerInfo.commissionSplitterV2);
    } else {
      console.log('ERROR! commissionSplitterV2 is not the same ', changerInfo.commissionSplitterV2);
    }

    if (changerInfo.commissionSplitterV3 === config.CommissionSplitterFixOutputRevAuc.commissionSplitterV3) {
      console.log('OK. commissionSplitterV3 contract: ', changerInfo.commissionSplitterV3);
    } else {
      console.log('ERROR! commissionSplitterV3 is not the same ', changerInfo.commissionSplitterV3);
    }

    if (changerInfo.revAucBTC2MOC === config.CommissionSplitterFixOutputRevAuc.revAucBTC2MOC) {
      console.log('OK. revAucBTC2MOC contract: ', changerInfo.revAucBTC2MOC);
    } else {
      console.log('ERROR! revAucBTC2MOC is not the same ', changerInfo.revAucBTC2MOC);
    }

    if (changerInfo.revAucMOC2BTC === config.CommissionSplitterFixOutputRevAuc.revAucMOC2BTC) {
      console.log('OK. revAucMOC2BTC contract: ', changerInfo.revAucMOC2BTC);
    } else {
      console.log('ERROR! revAucMOC2BTC is not the same ', changerInfo.revAucMOC2BTC);
    }

    console.log('Changer contract parameters');
  } catch (error) {
    callback(error);
  }

  callback();
};
