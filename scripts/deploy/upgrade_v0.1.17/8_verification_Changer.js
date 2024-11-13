/* eslint-disable no-console */
const contract = require('truffle-contract');
const FlowChangeProposal = artifacts.require('./changers/FlowChangeProposal.sol');
const { getConfig, getNetwork } = require('../helper');


module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    const changerAddress = config.FlowChangeProposal.changer;

    console.log('Reading Changer with address: ', changerAddress);

    const changer = await FlowChangeProposal.at(changerAddress);

    const changerInfo = {};
    changerInfo.mocInrate = await changer.mocInrate();
    changerInfo.mocState = await changer.mocState();
    changerInfo.mocSettlement = await changer.mocSettlement();
    changerInfo.commissionSplitterV2 = await changer.commissionSplitterV2();
    changerInfo.commissionSplitterV3 = await changer.commissionSplitterV3();
    changerInfo.mocProviderAddress = await changer.mocProviderAddress();
    changerInfo.blockSpan = await changer.blockSpan();
    changerInfo.blockSpanBitProInterest = await changer.blockSpanBitProInterest();
    changerInfo.blockSpanSettlement = await changer.blockSpanSettlement();
    changerInfo.blockSpanEMA = await changer.blockSpanEMA();

    console.log('Changer contract parameters');

    if (changerInfo.mocInrate === config.FlowChangeProposal.mocInrate) {
      console.log('OK. mocInrate contract: ', changerInfo.mocInrate);
    } else {
      console.log('ERROR! mocInrate is not the same ', changerInfo.mocInrate);
    }

    if (changerInfo.mocState === config.FlowChangeProposal.mocState) {
      console.log('OK. mocState contract: ', changerInfo.mocState);
    } else {
      console.log('ERROR! mocState is not the same ', changerInfo.mocState);
    }

    if (changerInfo.mocSettlement === config.FlowChangeProposal.mocSettlement) {
      console.log('OK. mocSettlement contract: ', changerInfo.mocSettlement);
    } else {
      console.log('ERROR! mocSettlement is not the same ', changerInfo.mocSettlement);
    }

    if (changerInfo.commissionSplitterV2 === config.CommissionSplitterV2.proxy) {
      console.log('OK. commissionSplitterV2 contract: ', changerInfo.commissionSplitterV2);
    } else {
      console.log('ERROR! commissionSplitterV2 is not the same ', changerInfo.commissionSplitterV2);
    }

    if (changerInfo.commissionSplitterV3 === config.CommissionSplitterV3.proxy) {
      console.log('OK. commissionSplitterV3 contract: ', changerInfo.commissionSplitterV3);
    } else {
      console.log('ERROR! commissionSplitterV3 is not the same ', changerInfo.commissionSplitterV3);
    }

    if (changerInfo.mocProviderAddress === config.FlowChangeProposal.mocProviderAddress) {
      console.log('OK. mocProviderAddress contract: ', changerInfo.mocProviderAddress);
    } else {
      console.log('ERROR! mocProviderAddress is not the same ', changerInfo.mocProviderAddress);
    }

    if (changerInfo.blockSpan.toString() === config.FlowChangeProposal.blockSpan.toString()) {
      console.log('OK. blockSpan contract: ', changerInfo.blockSpan.toString());
    } else {
      console.log('ERROR! blockSpan is not the same ', changerInfo.blockSpan.toString());
    }

    if (changerInfo.blockSpanBitProInterest.toString() === config.FlowChangeProposal.blockSpanBitProInterest.toString()) {
      console.log('OK. blockSpanBitProInterest contract: ', changerInfo.blockSpanBitProInterest.toString());
    } else {
      console.log('ERROR! blockSpanBitProInterest is not the same ', changerInfo.blockSpanBitProInterest.toString());
    }

    if (changerInfo.blockSpanSettlement.toString() === config.FlowChangeProposal.blockSpanSettlement.toString()) {
      console.log('OK. blockSpanSettlement contract: ', changerInfo.blockSpanSettlement.toString());
    } else {
      console.log('ERROR! blockSpanSettlement is not the same ', changerInfo.blockSpanSettlement.toString());
    }

    if (changerInfo.blockSpanEMA.toString() === config.FlowChangeProposal.blockSpanEMA.toString()) {
      console.log('OK. blockSpanEMA contract: ', changerInfo.blockSpanEMA.toString());
    } else {
      console.log('ERROR! blockSpanEMA is not the same ', changerInfo.blockSpanEMA.toString());
    }

    console.log('Changer contract parameters');

  } catch (error) {
    callback(error);
  }

  callback();
};
