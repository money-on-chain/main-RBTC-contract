/* eslint-disable no-console */
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');
const { getConfig, getNetwork } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    const changerAddress = config.FlowChangeProposal.changer;

    console.log('Reading Changer with address: ', changerAddress);

    console.log('Reading contracts...');

    const moCInrate = await MoCInrate.at(config.FlowChangeProposal.mocInrate);
    const moCState = await MoCState.at(config.FlowChangeProposal.mocState);
    const moCSettlement = await MoCSettlement.at(config.FlowChangeProposal.mocSettlement);

    const contractInfo = {};

    contractInfo.MoCInrate = {}
    contractInfo.MoCInrate.getBitProInterestBlockSpan = await moCInrate.getBitProInterestBlockSpan();
    contractInfo.MoCInrate.commissionsAddress = await moCInrate.commissionsAddress();
    contractInfo.MoCInrate.getBitProInterestAddress = await moCInrate.getBitProInterestAddress();

    contractInfo.MoCState = {}
    contractInfo.MoCState.getDayBlockSpan = await moCState.getDayBlockSpan();
    contractInfo.MoCState.getEmaCalculationBlockSpan = await moCState.getEmaCalculationBlockSpan();
    contractInfo.MoCState.getMoCPriceProvider = await moCState.getMoCPriceProvider();

    contractInfo.MoCSettlement = {}
    contractInfo.MoCSettlement.getBlockSpan = await moCSettlement.getBlockSpan();

    console.log('Contract storage...');


    console.log('1. MoCInrate getBitProInterestAddress() ->> CommissionSplitterV3: ', contractInfo.MoCInrate.getBitProInterestAddress);
    if (
      contractInfo.MoCInrate.getBitProInterestAddress.toLowerCase() !=
      config.CommissionSplitterV3.proxy.toLowerCase()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log('2. MoCInrate commissionsAddress() ->> CommissionSplitterV2: ', contractInfo.MoCInrate.commissionsAddress);
    if (
      contractInfo.MoCInrate.commissionsAddress.toLowerCase() !=
      config.CommissionSplitterV2.proxy.toLowerCase()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log('3. MoCInrate getBitProInterestBlockSpan(): ', contractInfo.MoCInrate.getBitProInterestBlockSpan.toString());
    if (
      contractInfo.MoCInrate.getBitProInterestBlockSpan.toString() !=
      config.FlowChangeProposal.blockSpanBitProInterest.toString()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log('4. MoCState getDayBlockSpan(): ', contractInfo.MoCState.getDayBlockSpan.toString());
    if (
      contractInfo.MoCState.getDayBlockSpan.toString() !=
      config.FlowChangeProposal.blockSpan.toString()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log('5. MoCState getEmaCalculationBlockSpan(): ', contractInfo.MoCState.getEmaCalculationBlockSpan.toString());
    if (
      contractInfo.MoCState.getEmaCalculationBlockSpan.toString() !=
      config.FlowChangeProposal.blockSpanEMA.toString()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log('6. MoCState getMoCPriceProvider(): ', contractInfo.MoCState.getMoCPriceProvider);
    if (
      contractInfo.MoCState.getMoCPriceProvider !=
      config.FlowChangeProposal.mocProviderAddress
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log('7. MoCSettlement getBlockSpan(): ', contractInfo.MoCSettlement.getBlockSpan.toString());
    if (
      contractInfo.MoCSettlement.getBlockSpan.toString() !=
      config.FlowChangeProposal.blockSpanSettlement.toString()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log('Finish!');


  } catch (error) {
    callback(error);
  }

  callback();
};
