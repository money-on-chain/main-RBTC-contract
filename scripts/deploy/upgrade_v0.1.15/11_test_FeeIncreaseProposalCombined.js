/* eslint-disable no-console */
const BigNumber = require('bignumber.js');

const FeeIncreaseProposalCombined = artifacts.require(
  './changers/proposal_fee_increase/FeeIncreaseProposalCombined.sol'
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

const MINT_RISKPRO_FEES_RESERVE = '0';
const REDEEM_RISKPRO_FEES_RESERVE = '1';
const MINT_STABLETOKEN_FEES_RESERVE = '2';
const REDEEM_STABLETOKEN_FEES_RESERVE = '3';
const MINT_RISKPROX_FEES_RESERVE = '4';
const REDEEM_RISKPROX_FEES_RESERVE = '5';
const MINT_RISKPRO_FEES_MOC = '6';
const REDEEM_RISKPRO_FEES_MOC = '7';
const MINT_STABLETOKEN_FEES_MOC = '8';
const REDEEM_STABLETOKEN_FEES_MOC = '9';
const MINT_RISKPROX_FEES_MOC = '10';
const REDEEM_RISKPROX_FEES_MOC = '11';

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const feeIncreaseProposalCombinedAddress = config.changerAddresses.FeeIncreaseProposalCombined;
    const feeIncreaseProposalCombined = await FeeIncreaseProposalCombined.at(
      feeIncreaseProposalCombinedAddress
    );

    const contractInfo = {};

    // MOC Platform

    contractInfo.MOC_commissionAddress = await feeIncreaseProposalCombined.MOC_commissionAddress();
    contractInfo.MOC_bitProInterestAddress = await feeIncreaseProposalCombined.MOC_bitProInterestAddress();
    contractInfo.MOC_bitProRate = await feeIncreaseProposalCombined.MOC_bitProRate();
    contractInfo.MOC_bitProRateFormatted = BigNumber(contractInfo.MOC_bitProRate).div(PRECISION);
    contractInfo.MOC_commissionRates = {};
    contractInfo.MOC_commissionRates.MINT_BPRO_FEES_RBTC = await feeIncreaseProposalCombined.MOC_commissionRates(
      MINT_BPRO_FEES_RBTC
    );
    contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_RBTC = await feeIncreaseProposalCombined.MOC_commissionRates(
      REDEEM_BPRO_FEES_RBTC
    );
    contractInfo.MOC_commissionRates.MINT_DOC_FEES_RBTC = await feeIncreaseProposalCombined.MOC_commissionRates(
      MINT_DOC_FEES_RBTC
    );
    contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_RBTC = await feeIncreaseProposalCombined.MOC_commissionRates(
      REDEEM_DOC_FEES_RBTC
    );
    contractInfo.MOC_commissionRates.MINT_BTCX_FEES_RBTC = await feeIncreaseProposalCombined.MOC_commissionRates(
      MINT_BTCX_FEES_RBTC
    );
    contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_RBTC = await feeIncreaseProposalCombined.MOC_commissionRates(
      REDEEM_BTCX_FEES_RBTC
    );
    contractInfo.MOC_commissionRates.MINT_BPRO_FEES_MOC = await feeIncreaseProposalCombined.MOC_commissionRates(
      MINT_BPRO_FEES_MOC
    );
    contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_MOC = await feeIncreaseProposalCombined.MOC_commissionRates(
      REDEEM_BPRO_FEES_MOC
    );
    contractInfo.MOC_commissionRates.MINT_DOC_FEES_MOC = await feeIncreaseProposalCombined.MOC_commissionRates(
      MINT_DOC_FEES_MOC
    );
    contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_MOC = await feeIncreaseProposalCombined.MOC_commissionRates(
      REDEEM_DOC_FEES_MOC
    );
    contractInfo.MOC_commissionRates.MINT_BTCX_FEES_MOC = await feeIncreaseProposalCombined.MOC_commissionRates(
      MINT_BTCX_FEES_MOC
    );
    contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_MOC = await feeIncreaseProposalCombined.MOC_commissionRates(
      REDEEM_BTCX_FEES_MOC
    );

    console.log('Changer Storage Validation MOC Platform');
    console.log();

    if (
      contractInfo.MOC_bitProInterestAddress.toLowerCase() ===
      config.FeeIncreaseProposal.MOC.bitProInterestAddress.toLowerCase()
    ) {
      console.log('OK. 1. bitProInterestAddress: ', contractInfo.MOC_bitProInterestAddress);
    } else {
      console.log('ERROR. 1. bitProInterestAddress: ', contractInfo.MOC_bitProInterestAddress);
    }

    if (
      contractInfo.MOC_commissionAddress.toLowerCase() ===
      config.FeeIncreaseProposal.MOC.commissionAddress.toLowerCase()
    ) {
      console.log('OK. 2. commissionAddress: ', contractInfo.MOC_commissionAddress);
    } else {
      console.log('ERROR. 2. commissionAddress: ', contractInfo.MOC_commissionAddress);
    }

    if (contractInfo.MOC_bitProRate.toString() === config.FeeIncreaseProposal.MOC.bitProRate) {
      console.log(
        `OK. 3. bitProRate: ${contractInfo.MOC_bitProRate.toString()} (${contractInfo.MOC_bitProRateFormatted.toString()}) `
      );
    } else {
      console.log(
        `ERROR. 3. bitProRate: ${contractInfo.MOC_bitProRate.toString()} (${contractInfo.MOC_bitProRateFormatted.toString()}) `
      );
    }

    console.log();
    console.log('Commission Operation parameters - MOC Platform');
    console.log();

    // MINT_BPRO_FEES_RBTC
    if (
      contractInfo.MOC_commissionRates.MINT_BPRO_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BPRO_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 10. MINT_BPRO_FEES_RBTC: ${contractInfo.MOC_commissionRates.MINT_BPRO_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_BPRO_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 10. MINT_BPRO_FEES_RBTC: ${contractInfo.MOC_commissionRates.MINT_BPRO_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_BPRO_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_BPRO_FEES_RBTC

    if (
      contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BPRO_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 11. REDEEM_BPRO_FEES_RBTC: ${contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 11. REDEEM_BPRO_FEES_RBTC: ${contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_DOC_FEES_RBTC

    if (
      contractInfo.MOC_commissionRates.MINT_DOC_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_DOC_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 12. MINT_DOC_FEES_RBTC: ${contractInfo.MOC_commissionRates.MINT_DOC_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_DOC_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 12. MINT_DOC_FEES_RBTC: ${contractInfo.MOC_commissionRates.MINT_DOC_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_DOC_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_DOC_FEES_RBTC

    if (
      contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_DOC_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 13. REDEEM_DOC_FEES_RBTC: ${contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 13. REDEEM_DOC_FEES_RBTC: ${contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_BTCX_FEES_RBTC

    if (
      contractInfo.MOC_commissionRates.MINT_BTCX_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BTCX_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 14. MINT_BTCX_FEES_RBTC: ${contractInfo.MOC_commissionRates.MINT_BTCX_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_BTCX_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 14. MINT_BTCX_FEES_RBTC: ${contractInfo.MOC_commissionRates.MINT_BTCX_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_BTCX_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_BTCX_FEES_RBTC

    if (
      contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_RBTC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BTCX_FEES_RBTC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 15. REDEEM_BTCX_FEES_RBTC: ${contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 15. REDEEM_BTCX_FEES_RBTC: ${contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_RBTC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_RBTC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_BPRO_FEES_MOC

    if (
      contractInfo.MOC_commissionRates.MINT_BPRO_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BPRO_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 16. MINT_BPRO_FEES_MOC: ${contractInfo.MOC_commissionRates.MINT_BPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_BPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 16. MINT_BPRO_FEES_MOC: ${contractInfo.MOC_commissionRates.MINT_BPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_BPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_BPRO_FEES_MOC

    if (
      contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BPRO_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 17. REDEEM_BPRO_FEES_MOC: ${contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 17. REDEEM_BPRO_FEES_MOC: ${contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_BPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_DOC_FEES_MOC

    if (
      contractInfo.MOC_commissionRates.MINT_DOC_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_DOC_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 18. MINT_DOC_FEES_MOC: ${contractInfo.MOC_commissionRates.MINT_DOC_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_DOC_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 18. MINT_DOC_FEES_MOC: ${contractInfo.MOC_commissionRates.MINT_DOC_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_DOC_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_DOC_FEES_MOC

    if (
      contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_DOC_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 19. REDEEM_DOC_FEES_MOC: ${contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 19. REDEEM_DOC_FEES_MOC: ${contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_DOC_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_BTCX_FEES_MOC

    if (
      contractInfo.MOC_commissionRates.MINT_BTCX_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.MINT_BTCX_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 20. MINT_BTCX_FEES_MOC: ${contractInfo.MOC_commissionRates.MINT_BTCX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_BTCX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 20. MINT_BTCX_FEES_MOC: ${contractInfo.MOC_commissionRates.MINT_BTCX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.MINT_BTCX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_BTCX_FEES_MOC

    if (
      contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.MOC.commissionRates.REDEEM_BTCX_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 21. REDEEM_BTCX_FEES_MOC: ${contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 21. REDEEM_BTCX_FEES_MOC: ${contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.MOC_commissionRates.REDEEM_BTCX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // RoC Platform

    contractInfo.ROC_commissionAddress = await feeIncreaseProposalCombined.ROC_commissionAddress();
    contractInfo.ROC_riskProInterestAddress = await feeIncreaseProposalCombined.ROC_riskProInterestAddress();
    contractInfo.ROC_riskProRate = await feeIncreaseProposalCombined.ROC_riskProRate();
    contractInfo.ROC_riskProRateFormatted = BigNumber(contractInfo.ROC_riskProRate).div(PRECISION);
    contractInfo.ROC_commissionRates = {};
    contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_RESERVE = await feeIncreaseProposalCombined.ROC_commissionRates(
      MINT_RISKPRO_FEES_RESERVE
    );
    contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_RESERVE = await feeIncreaseProposalCombined.ROC_commissionRates(
      REDEEM_RISKPRO_FEES_RESERVE
    );
    contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_RESERVE = await feeIncreaseProposalCombined.ROC_commissionRates(
      MINT_STABLETOKEN_FEES_RESERVE
    );
    contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_RESERVE = await feeIncreaseProposalCombined.ROC_commissionRates(
      REDEEM_STABLETOKEN_FEES_RESERVE
    );
    contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_RESERVE = await feeIncreaseProposalCombined.ROC_commissionRates(
      MINT_RISKPROX_FEES_RESERVE
    );
    contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_RESERVE = await feeIncreaseProposalCombined.ROC_commissionRates(
      REDEEM_RISKPROX_FEES_RESERVE
    );
    contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_MOC = await feeIncreaseProposalCombined.ROC_commissionRates(
      MINT_RISKPRO_FEES_MOC
    );
    contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_MOC = await feeIncreaseProposalCombined.ROC_commissionRates(
      REDEEM_RISKPRO_FEES_MOC
    );
    contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_MOC = await feeIncreaseProposalCombined.ROC_commissionRates(
      MINT_STABLETOKEN_FEES_MOC
    );
    contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_MOC = await feeIncreaseProposalCombined.ROC_commissionRates(
      REDEEM_STABLETOKEN_FEES_MOC
    );
    contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_MOC = await feeIncreaseProposalCombined.ROC_commissionRates(
      MINT_RISKPROX_FEES_MOC
    );
    contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_MOC = await feeIncreaseProposalCombined.ROC_commissionRates(
      REDEEM_RISKPROX_FEES_MOC
    );

    console.log();
    console.log('Changer Storage Validation - ROC Platform');
    console.log();

    if (
      contractInfo.ROC_riskProInterestAddress.toLowerCase() ===
      config.FeeIncreaseProposal.ROC.riskProInterestAddress.toLowerCase()
    ) {
      console.log('OK. 1. riskProInterestAddress: ', contractInfo.ROC_riskProInterestAddress);
    } else {
      console.log('ERROR. 1. riskProInterestAddress: ', contractInfo.ROC_riskProInterestAddress);
    }

    if (
      contractInfo.ROC_commissionAddress.toLowerCase() ===
      config.FeeIncreaseProposal.ROC.commissionAddress.toLowerCase()
    ) {
      console.log('OK. 2. commissionAddress: ', contractInfo.ROC_commissionAddress);
    } else {
      console.log('ERROR. 2. commissionAddress: ', contractInfo.ROC_commissionAddress);
    }

    if (contractInfo.ROC_riskProRate.toString() === config.FeeIncreaseProposal.ROC.riskProRate) {
      console.log(
        `OK. 3. riskProRate: ${contractInfo.ROC_riskProRate.toString()} (${contractInfo.ROC_riskProRateFormatted.toString()}) `
      );
    } else {
      console.log(
        `ERROR. 3. riskProRate: ${contractInfo.ROC_riskProRate.toString()} (${contractInfo.ROC_riskProRateFormatted.toString()}) `
      );
    }

    console.log();
    console.log('Commission Operation parameters - ROC Platform');
    console.log();

    // MINT_RISKPRO_FEES_RESERVE
    if (
      contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_RESERVE.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_RISKPRO_FEES_RESERVE)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 10. MINT_RISKPRO_FEES_RESERVE: ${contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 10. MINT_RISKPRO_FEES_RESERVE: ${contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_RISKPRO_FEES_RESERVE

    if (
      contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_RESERVE.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_RISKPRO_FEES_RESERVE)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 11. REDEEM_RISKPRO_FEES_RESERVE: ${contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 11. REDEEM_RISKPRO_FEES_RESERVE: ${contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_STABLETOKEN_FEES_RESERVE

    if (
      contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_RESERVE.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_STABLETOKEN_FEES_RESERVE)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 12. MINT_STABLETOKEN_FEES_RESERVE: ${contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 12. MINT_STABLETOKEN_FEES_RESERVE: ${contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_STABLETOKEN_FEES_RESERVE

    if (
      contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_RESERVE.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_STABLETOKEN_FEES_RESERVE)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 13. REDEEM_STABLETOKEN_FEES_RESERVE: ${contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 13. REDEEM_STABLETOKEN_FEES_RESERVE: ${contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_RISKPROX_FEES_RESERVE

    if (
      contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_RESERVE.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_RISKPROX_FEES_RESERVE)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 14. MINT_RISKPROX_FEES_RESERVE: ${contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 14. MINT_RISKPROX_FEES_RESERVE: ${contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_RISKPROX_FEES_RESERVE

    if (
      contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_RESERVE.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_RISKPROX_FEES_RESERVE)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 15. REDEEM_RISKPROX_FEES_RESERVE: ${contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 15. REDEEM_RISKPROX_FEES_RESERVE: ${contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_RESERVE.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_RESERVE.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_RISKPRO_FEES_MOC

    if (
      contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_RISKPRO_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 16. MINT_RISKPRO_FEES_MOC: ${contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 16. MINT_RISKPRO_FEES_MOC: ${contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_RISKPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_RISKPRO_FEES_MOC

    if (
      contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_RISKPRO_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 17. REDEEM_RISKPRO_FEES_MOC: ${contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 17. REDEEM_RISKPRO_FEES_MOC: ${contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_RISKPRO_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_STABLETOKEN_FEES_MOC

    if (
      contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_STABLETOKEN_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 18. MINT_STABLETOKEN_FEES_MOC: ${contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 18. MINT_STABLETOKEN_FEES_MOC: ${contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_STABLETOKEN_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_STABLETOKEN_FEES_MOC

    if (
      contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_STABLETOKEN_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 19. REDEEM_STABLETOKEN_FEES_MOC: ${contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 19. REDEEM_STABLETOKEN_FEES_MOC: ${contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_STABLETOKEN_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // MINT_RISKPROX_FEES_MOC

    if (
      contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.MINT_RISKPROX_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 20. MINT_RISKPROX_FEES_MOC: ${contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 20. MINT_RISKPROX_FEES_MOC: ${contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.MINT_RISKPROX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    }

    // REDEEM_RISKPROX_FEES_MOC

    if (
      contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_MOC.fee.toString() ===
      BigNumber(config.FeeIncreaseProposal.ROC.commissionRates.REDEEM_RISKPROX_FEES_MOC)
        .times(PRECISION)
        .toString()
    ) {
      console.log(
        `OK. 21. REDEEM_RISKPROX_FEES_MOC: ${contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_MOC.fee
        )
          .div(PRECISION)
          .toString()}) `
      );
    } else {
      console.log(
        `ERROR. 21. REDEEM_RISKPROX_FEES_MOC: ${contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_MOC.fee.toString()} (${BigNumber(
          contractInfo.ROC_commissionRates.REDEEM_RISKPROX_FEES_MOC.fee
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
