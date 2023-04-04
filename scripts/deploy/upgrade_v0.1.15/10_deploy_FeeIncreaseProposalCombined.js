/* eslint-disable no-console */
/* eslint-disable camelcase */
const BigNumber = require('bignumber.js');

const FeeIncreaseProposalCombined = artifacts.require(
  './changers/proposal_fee_increase/FeeIncreaseProposalCombined.sol'
);
const { getConfig, getNetwork, saveConfig } = require('../helper');

const getMoCCommissionsArray = async config => {
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
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BPRO_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_BPRO_FEES_RBTC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BPRO_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_DOC_FEES_RBTC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_DOC_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_DOC_FEES_RBTC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_DOC_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_BTCX_FEES_RBTC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BTCX_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_BTCX_FEES_RBTC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BTCX_FEES_RBTC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_BPRO_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BPRO_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_BPRO_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BPRO_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_DOC_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_DOC_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_DOC_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_DOC_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_BTCX_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BTCX_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_BTCX_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BTCX_FEES_MOC)
        .times(mocPrecision)
        .toString()
    }
  ];
  return ret;
};

const getRoCCommissionsArray = async config => {
  const mocPrecision = 10 ** 18;
  const MINT_RISKPRO_FEES_RESERVE = '1';
  const REDEEM_RISKPRO_FEES_RESERVE = '2';
  const MINT_STABLETOKEN_FEES_RESERVE = '3';
  const REDEEM_STABLETOKEN_FEES_RESERVE = '4';
  const MINT_RISKPROX_FEES_RESERVE = '5';
  const REDEEM_RISKPROX_FEES_RESERVE = '6';
  const MINT_RISKPRO_FEES_MOC = '7';
  const REDEEM_RISKPRO_FEES_MOC = '8';
  const MINT_STABLETOKEN_FEES_MOC = '9';
  const REDEEM_STABLETOKEN_FEES_MOC = '10';
  const MINT_RISKPROX_FEES_MOC = '11';
  const REDEEM_RISKPROX_FEES_MOC = '12';

  const ret = [
    {
      txType: MINT_RISKPRO_FEES_RESERVE,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_RISKPRO_FEES_RESERVE)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_RISKPRO_FEES_RESERVE,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_RISKPRO_FEES_RESERVE)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_STABLETOKEN_FEES_RESERVE,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_STABLETOKEN_FEES_RESERVE)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_STABLETOKEN_FEES_RESERVE,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_STABLETOKEN_FEES_RESERVE)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_RISKPROX_FEES_RESERVE,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_RISKPROX_FEES_RESERVE)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_RISKPROX_FEES_RESERVE,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_RISKPROX_FEES_RESERVE)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_RISKPRO_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_RISKPRO_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_RISKPRO_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_RISKPRO_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_STABLETOKEN_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_STABLETOKEN_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_STABLETOKEN_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_STABLETOKEN_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: MINT_RISKPROX_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_RISKPROX_FEES_MOC)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: REDEEM_RISKPROX_FEES_MOC,
      fee: BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_RISKPROX_FEES_MOC)
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

    const parameters = {};
    parameters.MOC = {};
    parameters.ROC = {};

    parameters.MOC.MoCInrate = config.FeeIncreaseProposal.MOC.MoCInrate;
    parameters.MOC.bitProInterestAddress = config.FeeIncreaseProposal.MOC.bitProInterestAddress;
    parameters.MOC.commissionAddress = config.FeeIncreaseProposal.MOC.commissionAddress;
    parameters.MOC.bitProRate = config.FeeIncreaseProposal.MOC.bitProRate;

    parameters.ROC.MoCInrate = config.FeeIncreaseProposal.ROC.MoCInrate;
    parameters.ROC.riskProInterestAddress = config.FeeIncreaseProposal.ROC.riskProInterestAddress;
    parameters.ROC.commissionAddress = config.FeeIncreaseProposal.ROC.commissionAddress;
    parameters.ROC.riskProRate = config.FeeIncreaseProposal.ROC.riskProRate;

    const commissionsMoCrates = await getMoCCommissionsArray(config);
    const commissionsRoCrates = await getRoCCommissionsArray(config);

    console.log('Deploying FeeIncreaseProposalCombined Contract Changer ...');
    // eslint-disable-next-line no-shadow
    const feeIncreaseProposal = await FeeIncreaseProposalCombined.new(
      parameters.MOC.MoCInrate,
      parameters.MOC.commissionAddress,
      parameters.MOC.bitProInterestAddress,
      parameters.MOC.bitProRate,
      commissionsMoCrates,
      parameters.ROC.MoCInrate,
      parameters.ROC.commissionAddress,
      parameters.ROC.riskProInterestAddress,
      parameters.ROC.riskProRate,
      commissionsRoCrates
    );

    console.log('Deploying FeeIncreaseProposalCombined Contract Changer DONE!');

    // Save changer address to config file
    config.changerAddresses.FeeIncreaseProposalCombined = feeIncreaseProposal.address;
    saveConfig(config, configPath);
  } catch (error) {
    callback(error);
  }

  callback();
};
