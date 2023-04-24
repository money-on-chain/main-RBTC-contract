/* eslint-disable no-console */
/* eslint-disable camelcase */
const BigNumber = require('bignumber.js');

const FeeIncreaseProposal = artifacts.require(
  './changers/proposal_fee_increase/FeeIncreaseProposal.sol'
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

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    const {
      MoCInrate,
      bitProInterestAddress,
      commissionAddress,
      bitProRate
    } = config.FeeIncreaseProposal.MOC;

    const commissionsMoCrates = await getMoCCommissionsArray(config);

    console.log('Deploying FeeIncreaseProposal Contract Changer ...');
    // eslint-disable-next-line no-shadow
    const feeIncreaseProposal = await FeeIncreaseProposal.new(
      MoCInrate,
      commissionAddress,
      bitProInterestAddress,
      bitProRate,
      commissionsMoCrates
    );

    console.log('Deploying FeeIncreaseProposal Contract Changer DONE!');

    // Save changer address to config file
    config.changerAddresses.FeeIncreaseProposal = feeIncreaseProposal.address;
    saveConfig(config, configPath);
  } catch (error) {
    callback(error);
  }

  callback();
};
