/* eslint-disable no-console */
const BigNumber = require('bignumber.js');

const FeeIncreaseProposal = artifacts.require(
  './changers/proposal_fee_increase/FeeIncreaseProposal.sol'
);
const { getConfig, getNetwork } = require('../helper');

const PRECISION = 10 ** 18;

const MINT_BPRO_FEES_RBTC = '0';
const REDEEM_BPRO_FEES_RBTC = '1';
const MINT_DOC_FEES_RBTC = '2';
const REDEEM_DOC_FEES_RBTC = '3';
const MINT_BTCX_FEES_RBTC = '4';
const REDEEM_BTCX_FEES_RBTC = '5';
const MINT_BPRO_FEES_MOC = '6';
const REDEEM_BPRO_FEES_MOC = '7';
const MINT_DOC_FEES_MOC = '8';
const REDEEM_DOC_FEES_MOC = '9';
const MINT_BTCX_FEES_MOC = '10';
const REDEEM_BTCX_FEES_MOC = '11';

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const feeIncreaseProposalAddress = config.changerAddresses.FeeIncreaseProposal;
    const feeIncreaseProposal = await FeeIncreaseProposal.at(feeIncreaseProposalAddress);

    const contractInfo = {};
    contractInfo.commissionAddress = await feeIncreaseProposal.commissionAddress();
    contractInfo.bitProInterestAddress = await feeIncreaseProposal.bitProInterestAddress();
    contractInfo.bitProRate = await feeIncreaseProposal.bitProRate();
    contractInfo.bitProRateFormatted = BigNumber(contractInfo.bitProRate).div(PRECISION);
    contractInfo.commissionRates = {};
    contractInfo.commissionRates.MINT_BPRO_FEES_RBTC = await feeIncreaseProposal.commissionRates(
      MINT_BPRO_FEES_RBTC
    );
    contractInfo.commissionRates.REDEEM_BPRO_FEES_RBTC = await feeIncreaseProposal.commissionRates(
      REDEEM_BPRO_FEES_RBTC
    );
    contractInfo.commissionRates.MINT_DOC_FEES_RBTC = await feeIncreaseProposal.commissionRates(
      MINT_DOC_FEES_RBTC
    );
    contractInfo.commissionRates.REDEEM_DOC_FEES_RBTC = await feeIncreaseProposal.commissionRates(
      REDEEM_DOC_FEES_RBTC
    );
    contractInfo.commissionRates.MINT_BTCX_FEES_RBTC = await feeIncreaseProposal.commissionRates(
      MINT_BTCX_FEES_RBTC
    );
    contractInfo.commissionRates.REDEEM_BTCX_FEES_RBTC = await feeIncreaseProposal.commissionRates(
      REDEEM_BTCX_FEES_RBTC
    );
    contractInfo.commissionRates.MINT_BPRO_FEES_MOC = await feeIncreaseProposal.commissionRates(
      MINT_BPRO_FEES_MOC
    );
    contractInfo.commissionRates.REDEEM_BPRO_FEES_MOC = await feeIncreaseProposal.commissionRates(
      REDEEM_BPRO_FEES_MOC
    );
    contractInfo.commissionRates.MINT_DOC_FEES_MOC = await feeIncreaseProposal.commissionRates(
      MINT_DOC_FEES_MOC
    );
    contractInfo.commissionRates.REDEEM_DOC_FEES_MOC = await feeIncreaseProposal.commissionRates(
      REDEEM_DOC_FEES_MOC
    );
    contractInfo.commissionRates.MINT_BTCX_FEES_MOC = await feeIncreaseProposal.commissionRates(
      MINT_BTCX_FEES_MOC
    );
    contractInfo.commissionRates.REDEEM_BTCX_FEES_MOC = await feeIncreaseProposal.commissionRates(
      REDEEM_BTCX_FEES_MOC
    );

    console.log('Changer Storage Validation');
    console.log();

    if (
      contractInfo.bitProInterestAddress === config.FeeIncreaseProposal.MOC.bitProInterestAddress
    ) {
      console.log('OK. 1. bitProInterestAddress: ', contractInfo.bitProInterestAddress);
    } else {
      console.log('ERROR. 1. bitProInterestAddress: ', contractInfo.bitProInterestAddress);
    }

    if (contractInfo.commissionAddress === config.FeeIncreaseProposal.MOC.commissionAddress) {
      console.log('OK. 2. commissionAddress: ', contractInfo.commissionAddress);
    } else {
      console.log('ERROR. 2. commissionAddress: ', contractInfo.commissionAddress);
    }

    if (contractInfo.bitProRate.toString() === config.FeeIncreaseProposal.MOC.bitProRate) {
      console.log(
        `OK. 3. bitProRate: ${contractInfo.bitProRate.toString()} (${contractInfo.bitProRateFormatted.toString()}) `
      );
    } else {
      console.log(
        `ERROR. 3. bitProRate: ${contractInfo.bitProRate.toString()} (${contractInfo.bitProRateFormatted.toString()}) `
      );
    }

    console.log();
    console.log('Commission Operation parameters');
    console.log();

    // MINT_BPRO_FEES_RBTC
    if (
      contractInfo.commissionRates.MINT_BPRO_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BPRO_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 10. MINT_BPRO_FEES_RBTC: ${contractInfo.commissionRates.MINT_BPRO_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_BPRO_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 10. MINT_BPRO_FEES_RBTC: ${contractInfo.commissionRates.MINT_BPRO_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_BPRO_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_BPRO_FEES_RBTC

    if (
      contractInfo.commissionRates.REDEEM_BPRO_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BPRO_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 11. REDEEM_BPRO_FEES_RBTC: ${contractInfo.commissionRates.REDEEM_BPRO_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_BPRO_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 11. REDEEM_BPRO_FEES_RBTC: ${contractInfo.commissionRates.REDEEM_BPRO_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_BPRO_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_DOC_FEES_RBTC

    if (
      contractInfo.commissionRates.MINT_DOC_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_DOC_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 12. MINT_DOC_FEES_RBTC: ${contractInfo.commissionRates.MINT_DOC_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_DOC_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 12. MINT_DOC_FEES_RBTC: ${contractInfo.commissionRates.MINT_DOC_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_DOC_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_DOC_FEES_RBTC

    if (
      contractInfo.commissionRates.REDEEM_DOC_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_DOC_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 13. REDEEM_DOC_FEES_RBTC: ${contractInfo.commissionRates.REDEEM_DOC_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_DOC_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 13. REDEEM_DOC_FEES_RBTC: ${contractInfo.commissionRates.REDEEM_DOC_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_DOC_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_BTCX_FEES_RBTC

    if (
      contractInfo.commissionRates.MINT_BTCX_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BTCX_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 14. MINT_BTCX_FEES_RBTC: ${contractInfo.commissionRates.MINT_BTCX_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_BTCX_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 14. MINT_BTCX_FEES_RBTC: ${contractInfo.commissionRates.MINT_BTCX_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_BTCX_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_BTCX_FEES_RBTC

    if (
      contractInfo.commissionRates.REDEEM_BTCX_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BTCX_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 15. REDEEM_BTCX_FEES_RBTC: ${contractInfo.commissionRates.REDEEM_BTCX_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_BTCX_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 15. REDEEM_BTCX_FEES_RBTC: ${contractInfo.commissionRates.REDEEM_BTCX_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_BTCX_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_BPRO_FEES_MOC

    if (
      contractInfo.commissionRates.MINT_BPRO_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BPRO_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 16. MINT_BPRO_FEES_MOC: ${contractInfo.commissionRates.MINT_BPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_BPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 16. MINT_BPRO_FEES_MOC: ${contractInfo.commissionRates.MINT_BPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_BPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_BPRO_FEES_MOC

    if (
      contractInfo.commissionRates.REDEEM_BPRO_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BPRO_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 17. REDEEM_BPRO_FEES_MOC: ${contractInfo.commissionRates.REDEEM_BPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_BPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 17. REDEEM_BPRO_FEES_MOC: ${contractInfo.commissionRates.REDEEM_BPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_BPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_DOC_FEES_MOC

    if (
      contractInfo.commissionRates.MINT_DOC_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_DOC_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 18. MINT_DOC_FEES_MOC: ${contractInfo.commissionRates.MINT_DOC_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_DOC_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 18. MINT_DOC_FEES_MOC: ${contractInfo.commissionRates.MINT_DOC_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_DOC_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_DOC_FEES_MOC

    if (
      contractInfo.commissionRates.REDEEM_DOC_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_DOC_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 19. REDEEM_DOC_FEES_MOC: ${contractInfo.commissionRates.REDEEM_DOC_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_DOC_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 19. REDEEM_DOC_FEES_MOC: ${contractInfo.commissionRates.REDEEM_DOC_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_DOC_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_BTCX_FEES_MOC

    if (
      contractInfo.commissionRates.MINT_BTCX_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BTCX_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 20. MINT_BTCX_FEES_MOC: ${contractInfo.commissionRates.MINT_BTCX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_BTCX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 20. MINT_BTCX_FEES_MOC: ${contractInfo.commissionRates.MINT_BTCX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.MINT_BTCX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_BTCX_FEES_MOC

    if (
      contractInfo.commissionRates.REDEEM_BTCX_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BTCX_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 21. REDEEM_BTCX_FEES_MOC: ${contractInfo.commissionRates.REDEEM_BTCX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_BTCX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 21. REDEEM_BTCX_FEES_MOC: ${contractInfo.commissionRates.REDEEM_BTCX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.commissionRates.REDEEM_BTCX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
