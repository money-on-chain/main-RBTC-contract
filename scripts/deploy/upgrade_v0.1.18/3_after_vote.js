/* eslint-disable no-console */
const CommissionSplitterV2 = artifacts.require('./auxiliar/CommissionSplitterV2.sol');
const CommissionSplitterV3 = artifacts.require('./auxiliar/CommissionSplitterV3.sol');
const { getConfig, getNetwork } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    const changerAddress = config.CommissionSplitterFixOutputRevAuc.changer;

    console.log('Reading Changer with address: ', changerAddress);

    console.log('Reading contracts...');

    const contractInfo = {};

    const commissionSplitterV2 = await CommissionSplitterV2.at(
      config.CommissionSplitterFixOutputRevAuc.commissionSplitterV2
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
      config.CommissionSplitterFixOutputRevAuc.commissionSplitterV3
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

    // TODO: Verify contract

    console.log('Finish!');
  } catch (error) {
    callback(error);
  }

  callback();
};
