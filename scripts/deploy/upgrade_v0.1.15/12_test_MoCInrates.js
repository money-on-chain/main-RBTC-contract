/* eslint-disable no-console */
/* eslint-disable camelcase */
const BigNumber = require('bignumber.js');

const IMOCMoCInrate = artifacts.require(
  './changers/proposal_fee_increase/interfaces/IMOCMoCInrate.sol'
);
const IROCMoCInrate = artifacts.require(
  './changers/proposal_fee_increase/interfaces/IROCMoCInrate.sol'
);
const { getConfig, getNetwork } = require('../helper');

const PRECISION = 10 ** 18;

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const MOC_mocInrateAddress = config.FeeIncreaseProposal.MOC.MoCInrate;
    const MOC_mocInrate = await IMOCMoCInrate.at(MOC_mocInrateAddress);

    const ROC_mocInrateAddress = config.FeeIncreaseProposal.ROC.MoCInrate;
    const ROC_mocInrate = await IROCMoCInrate.at(ROC_mocInrateAddress);

    const contractInfo = {};
    contractInfo.MOC_commissionAddress = await MOC_mocInrate.commissionsAddress();
    contractInfo.MOC_getBitProInterestAddress = await MOC_mocInrate.getBitProInterestAddress();
    contractInfo.MOC_getBitProRate = await MOC_mocInrate.getBitProRate();
    contractInfo.MINT_BPRO_FEES_RBTC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.MINT_BPRO_FEES_RBTC()
    );
    contractInfo.REDEEM_BPRO_FEES_RBTC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.REDEEM_BPRO_FEES_RBTC()
    );
    contractInfo.MINT_DOC_FEES_RBTC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.MINT_DOC_FEES_RBTC()
    );
    contractInfo.REDEEM_DOC_FEES_RBTC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.REDEEM_DOC_FEES_RBTC()
    );
    contractInfo.MINT_BTCX_FEES_RBTC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.MINT_BTCX_FEES_RBTC()
    );
    contractInfo.REDEEM_BTCX_FEES_RBTC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.REDEEM_BTCX_FEES_RBTC()
    );
    contractInfo.MINT_BPRO_FEES_MOC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.MINT_BPRO_FEES_MOC()
    );
    contractInfo.REDEEM_BPRO_FEES_MOC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.REDEEM_BPRO_FEES_MOC()
    );
    contractInfo.MINT_DOC_FEES_MOC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.MINT_DOC_FEES_MOC()
    );
    contractInfo.REDEEM_DOC_FEES_MOC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.REDEEM_DOC_FEES_MOC()
    );
    contractInfo.MINT_BTCX_FEES_MOC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.MINT_BTCX_FEES_MOC()
    );
    contractInfo.REDEEM_BTCX_FEES_MOC = await MOC_mocInrate.commissionRatesByTxType(
      await MOC_mocInrate.REDEEM_BTCX_FEES_MOC()
    );

    console.log('MoCInrate Contract Current Storage - MOC Platform');
    console.log();
    console.log(`Commission Address: ${contractInfo.MOC_commissionAddress}`);
    console.log(`BitPro Interest Address: ${contractInfo.MOC_getBitProInterestAddress}`);
    console.log(
      `BitPro Rate: ${contractInfo.MOC_getBitProRate} (${BigNumber(contractInfo.MOC_getBitProRate)
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_BPRO_FEES_RBTC: ${contractInfo.MINT_BPRO_FEES_RBTC} (${BigNumber(
        contractInfo.MINT_BPRO_FEES_RBTC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_BPRO_FEES_RBTC: ${contractInfo.REDEEM_BPRO_FEES_RBTC} (${BigNumber(
        contractInfo.REDEEM_BPRO_FEES_RBTC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_DOC_FEES_RBTC: ${contractInfo.MINT_DOC_FEES_RBTC} (${BigNumber(
        contractInfo.MINT_DOC_FEES_RBTC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_DOC_FEES_RBTC: ${contractInfo.REDEEM_DOC_FEES_RBTC} (${BigNumber(
        contractInfo.REDEEM_DOC_FEES_RBTC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_BTCX_FEES_RBTC: ${contractInfo.MINT_BTCX_FEES_RBTC} (${BigNumber(
        contractInfo.MINT_BTCX_FEES_RBTC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_BTCX_FEES_RBTC: ${contractInfo.REDEEM_BTCX_FEES_RBTC} (${BigNumber(
        contractInfo.REDEEM_BTCX_FEES_RBTC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_BPRO_FEES_MOC: ${contractInfo.MINT_BPRO_FEES_MOC} (${BigNumber(
        contractInfo.MINT_BPRO_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_BPRO_FEES_MOC: ${contractInfo.REDEEM_BPRO_FEES_MOC} (${BigNumber(
        contractInfo.REDEEM_BPRO_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_DOC_FEES_MOC: ${contractInfo.MINT_DOC_FEES_MOC} (${BigNumber(
        contractInfo.MINT_DOC_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_DOC_FEES_MOC: ${contractInfo.REDEEM_DOC_FEES_MOC} (${BigNumber(
        contractInfo.REDEEM_DOC_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_BTCX_FEES_MOC: ${contractInfo.MINT_BTCX_FEES_MOC} (${BigNumber(
        contractInfo.MINT_BTCX_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_BTCX_FEES_MOC: ${contractInfo.REDEEM_BTCX_FEES_MOC} (${BigNumber(
        contractInfo.REDEEM_BTCX_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );

    // RoC Platform
    contractInfo.ROC_commissionAddress = await ROC_mocInrate.commissionsAddress();
    contractInfo.ROC_getRiskProInterestAddress = await ROC_mocInrate.getRiskProInterestAddress();
    contractInfo.ROC_getRiskProRate = await ROC_mocInrate.getRiskProRate();
    contractInfo.MINT_RISKPRO_FEES_RESERVE = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.MINT_RISKPRO_FEES_RESERVE()
    );
    contractInfo.REDEEM_RISKPRO_FEES_RESERVE = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.REDEEM_RISKPRO_FEES_RESERVE()
    );
    contractInfo.MINT_STABLETOKEN_FEES_RESERVE = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.MINT_STABLETOKEN_FEES_RESERVE()
    );
    contractInfo.REDEEM_STABLETOKEN_FEES_RESERVE = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.REDEEM_STABLETOKEN_FEES_RESERVE()
    );
    contractInfo.MINT_RISKPROX_FEES_RESERVE = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.MINT_RISKPROX_FEES_RESERVE()
    );
    contractInfo.REDEEM_RISKPROX_FEES_RESERVE = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.REDEEM_RISKPROX_FEES_RESERVE()
    );
    contractInfo.MINT_RISKPRO_FEES_MOC = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.MINT_RISKPRO_FEES_MOC()
    );
    contractInfo.REDEEM_RISKPRO_FEES_MOC = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.REDEEM_RISKPRO_FEES_MOC()
    );
    contractInfo.MINT_STABLETOKEN_FEES_MOC = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.MINT_STABLETOKEN_FEES_MOC()
    );
    contractInfo.REDEEM_STABLETOKEN_FEES_MOC = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.REDEEM_STABLETOKEN_FEES_MOC()
    );
    contractInfo.MINT_RISKPROX_FEES_MOC = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.MINT_RISKPROX_FEES_MOC()
    );
    contractInfo.REDEEM_RISKPROX_FEES_MOC = await ROC_mocInrate.commissionRatesByTxType(
      await ROC_mocInrate.REDEEM_RISKPROX_FEES_MOC()
    );

    console.log();
    console.log('MoCInrate Contract Current Storage - ROC Platform');
    console.log();
    console.log(`Commission Address: ${contractInfo.ROC_commissionAddress}`);
    console.log(`RIFP Interest Address: ${contractInfo.ROC_getRiskProInterestAddress}`);
    console.log(
      `RIFP Rate: ${contractInfo.ROC_getRiskProRate} (${BigNumber(contractInfo.ROC_getRiskProRate)
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_RISKPRO_FEES_RESERVE: ${contractInfo.MINT_RISKPRO_FEES_RESERVE} (${BigNumber(
        contractInfo.MINT_RISKPRO_FEES_RESERVE
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_RISKPRO_FEES_RESERVE: ${contractInfo.REDEEM_RISKPRO_FEES_RESERVE} (${BigNumber(
        contractInfo.REDEEM_RISKPRO_FEES_RESERVE
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_STABLETOKEN_FEES_RESERVE: ${contractInfo.MINT_STABLETOKEN_FEES_RESERVE} (${BigNumber(
        contractInfo.MINT_STABLETOKEN_FEES_RESERVE
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_STABLETOKEN_FEES_RESERVE: ${
        contractInfo.REDEEM_STABLETOKEN_FEES_RESERVE
      } (${BigNumber(contractInfo.REDEEM_STABLETOKEN_FEES_RESERVE)
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_RISKPROX_FEES_RESERVE: ${contractInfo.MINT_RISKPROX_FEES_RESERVE} (${BigNumber(
        contractInfo.MINT_RISKPROX_FEES_RESERVE
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_RISKPROX_FEES_RESERVE: ${contractInfo.REDEEM_RISKPROX_FEES_RESERVE} (${BigNumber(
        contractInfo.REDEEM_RISKPROX_FEES_RESERVE
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_RISKPRO_FEES_MOC: ${contractInfo.MINT_RISKPRO_FEES_MOC} (${BigNumber(
        contractInfo.MINT_RISKPRO_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_RISKPRO_FEES_MOC: ${contractInfo.REDEEM_RISKPRO_FEES_MOC} (${BigNumber(
        contractInfo.REDEEM_RISKPRO_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_STABLETOKEN_FEES_MOC: ${contractInfo.MINT_STABLETOKEN_FEES_MOC} (${BigNumber(
        contractInfo.MINT_STABLETOKEN_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_STABLETOKEN_FEES_MOC: ${contractInfo.REDEEM_STABLETOKEN_FEES_MOC} (${BigNumber(
        contractInfo.REDEEM_STABLETOKEN_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `MINT_RISKPROX_FEES_MOC: ${contractInfo.MINT_RISKPROX_FEES_MOC} (${BigNumber(
        contractInfo.MINT_RISKPROX_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
    console.log(
      `REDEEM_RISKPROX_FEES_MOC: ${contractInfo.REDEEM_RISKPROX_FEES_MOC} (${BigNumber(
        contractInfo.REDEEM_RISKPROX_FEES_MOC
      )
        .div(PRECISION)
        .toString()})`
    );
  } catch (error) {
    callback(error);
  }

  callback();
};
