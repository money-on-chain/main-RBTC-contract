/* eslint-disable no-console */
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');
const CommissionSplitterV2 = artifacts.require('./auxiliar/CommissionSplitterV2.sol');
const CommissionSplitterV3 = artifacts.require('./auxiliar/CommissionSplitterV3.sol');
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

    contractInfo.MoCInrate = {};
    contractInfo.MoCInrate.getBitProInterestBlockSpan = await moCInrate.getBitProInterestBlockSpan();
    contractInfo.MoCInrate.commissionsAddress = await moCInrate.commissionsAddress();
    contractInfo.MoCInrate.getBitProInterestAddress = await moCInrate.getBitProInterestAddress();

    contractInfo.MoCState = {};
    contractInfo.MoCState.getDayBlockSpan = await moCState.getDayBlockSpan();
    contractInfo.MoCState.getEmaCalculationBlockSpan = await moCState.getEmaCalculationBlockSpan();
    contractInfo.MoCState.getMoCPriceProvider = await moCState.getMoCPriceProvider();

    contractInfo.MoCSettlement = {};
    contractInfo.MoCSettlement.getBlockSpan = await moCSettlement.getBlockSpan();

    const commissionSplitterV2 = await CommissionSplitterV2.at(
      contractInfo.MoCInrate.commissionsAddress
    );
    contractInfo.CommissionSplitterV2 = {};
    contractInfo.CommissionSplitterV2.outputAddress_1 = await commissionSplitterV2.outputAddress_1();
    contractInfo.CommissionSplitterV2.outputAddress_2 = await commissionSplitterV2.outputAddress_2();
    contractInfo.CommissionSplitterV2.outputAddress_3 = await commissionSplitterV2.outputAddress_3();
    contractInfo.CommissionSplitterV2.outputProportion_1 = await commissionSplitterV2.outputProportion_1();
    contractInfo.CommissionSplitterV2.outputProportion_2 = await commissionSplitterV2.outputProportion_2();
    contractInfo.CommissionSplitterV2.outputTokenGovernAddress_1 = await commissionSplitterV2.outputTokenGovernAddress_1();
    contractInfo.CommissionSplitterV2.outputTokenGovernAddress_2 = await commissionSplitterV2.outputTokenGovernAddress_2();
    contractInfo.CommissionSplitterV2.outputProportionTokenGovern_1 = await commissionSplitterV2.outputProportionTokenGovern_1();
    contractInfo.CommissionSplitterV2.tokenGovern = await commissionSplitterV2.tokenGovern();

    const commissionSplitterV3 = await CommissionSplitterV3.at(
      contractInfo.MoCInrate.getBitProInterestAddress
    );
    contractInfo.CommissionSplitterV3 = {};
    contractInfo.CommissionSplitterV3.outputAddress_1 = await commissionSplitterV3.outputAddress_1();
    contractInfo.CommissionSplitterV3.outputAddress_2 = await commissionSplitterV3.outputAddress_2();
    contractInfo.CommissionSplitterV3.outputProportion_1 = await commissionSplitterV3.outputProportion_1();

    console.log('Contract storage...');
    console.log('');
    console.log('CommissionSplitterV2');
    console.log('====================');
    console.log('');
    console.log('a. outputAddress_1: ', contractInfo.CommissionSplitterV2.outputAddress_1);
    console.log('b. outputAddress_2: ', contractInfo.CommissionSplitterV2.outputAddress_2);
    console.log('c. outputAddress_3: ', contractInfo.CommissionSplitterV2.outputAddress_3);
    console.log(
      'd. outputProportion_1: ',
      contractInfo.CommissionSplitterV2.outputProportion_1.toString()
    );
    console.log(
      'e. outputProportion_2: ',
      contractInfo.CommissionSplitterV2.outputProportion_2.toString()
    );
    console.log(
      'g. outputTokenGovernAddress_1: ',
      contractInfo.CommissionSplitterV2.outputTokenGovernAddress_1
    );
    console.log(
      'h. outputTokenGovernAddress_2: ',
      contractInfo.CommissionSplitterV2.outputTokenGovernAddress_2
    );
    console.log(
      'i. outputProportionTokenGovern_1: ',
      contractInfo.CommissionSplitterV2.outputProportionTokenGovern_1.toString()
    );
    console.log('j. tokenGovern: ', contractInfo.CommissionSplitterV2.tokenGovern);
    console.log('');
    console.log('CommissionSplitterV3');
    console.log('====================');
    console.log('');
    console.log('a. outputAddress_1: ', contractInfo.CommissionSplitterV3.outputAddress_1);
    console.log('b. outputAddress_2: ', contractInfo.CommissionSplitterV3.outputAddress_2);
    console.log(
      'c. outputProportion_1: ',
      contractInfo.CommissionSplitterV3.outputProportion_1.toString()
    );
    console.log('');

    console.log('Contracts Storage');
    console.log('=================');
    console.log('');

    console.log(
      '1. MoCInrate getBitProInterestAddress() ->> CommissionSplitterV3: ',
      contractInfo.MoCInrate.getBitProInterestAddress
    );
    if (
      contractInfo.MoCInrate.getBitProInterestAddress.toLowerCase() !==
      config.CommissionSplitterV3.proxy.toLowerCase()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log(
      '2. MoCInrate commissionsAddress() ->> CommissionSplitterV2: ',
      contractInfo.MoCInrate.commissionsAddress
    );
    if (
      contractInfo.MoCInrate.commissionsAddress.toLowerCase() !==
      config.CommissionSplitterV2.proxy.toLowerCase()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log(
      '3. MoCInrate getBitProInterestBlockSpan(): ',
      contractInfo.MoCInrate.getBitProInterestBlockSpan.toString()
    );
    if (
      contractInfo.MoCInrate.getBitProInterestBlockSpan.toString() !==
      config.FlowChangeProposal.blockSpanBitProInterest.toString()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log(
      '4. MoCState getDayBlockSpan(): ',
      contractInfo.MoCState.getDayBlockSpan.toString()
    );
    if (
      contractInfo.MoCState.getDayBlockSpan.toString() !==
      config.FlowChangeProposal.blockSpan.toString()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log(
      '5. MoCState getEmaCalculationBlockSpan(): ',
      contractInfo.MoCState.getEmaCalculationBlockSpan.toString()
    );
    if (
      contractInfo.MoCState.getEmaCalculationBlockSpan.toString() !==
      config.FlowChangeProposal.blockSpanEMA.toString()
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log('6. MoCState getMoCPriceProvider(): ', contractInfo.MoCState.getMoCPriceProvider);
    if (
      contractInfo.MoCState.getMoCPriceProvider !== config.FlowChangeProposal.mocProviderAddress
    ) {
      console.log('--> ERROR!: Is not the same');
    } else {
      console.log('--> OK');
    }

    console.log(
      '7. MoCSettlement getBlockSpan(): ',
      contractInfo.MoCSettlement.getBlockSpan.toString()
    );
    if (
      contractInfo.MoCSettlement.getBlockSpan.toString() !==
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
