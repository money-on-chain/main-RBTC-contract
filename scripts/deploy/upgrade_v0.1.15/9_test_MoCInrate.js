/* eslint-disable no-console */
const BigNumber = require('bignumber.js');

const IMOCMoCInrate = artifacts.require(
  './changers/proposal_fee_increase/interfaces/IMOCMoCInrate.sol'
);
const { getConfig, getNetwork } = require('../helper');

const PRECISION = 10 ** 18;

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const mocInrateAddress = config.FeeIncreaseProposal.MOC.MoCInrate;
    const mocInrate = await IMOCMoCInrate.at(mocInrateAddress);

    const contractInfo = {};
    contractInfo.commissionAddress = await mocInrate.commissionsAddress();
    contractInfo.getBitProInterestAddress = await mocInrate.getBitProInterestAddress();
    contractInfo.getBitProRate = await mocInrate.getBitProRate();
    contractInfo.MINT_BPRO_FEES_RBTC = await mocInrate.commissionRatesByTxType(
      await mocInrate.MINT_BPRO_FEES_RBTC()
    );
    contractInfo.REDEEM_BPRO_FEES_RBTC = await mocInrate.commissionRatesByTxType(
      await mocInrate.REDEEM_BPRO_FEES_RBTC()
    );
    contractInfo.MINT_DOC_FEES_RBTC = await mocInrate.commissionRatesByTxType(
      await mocInrate.MINT_DOC_FEES_RBTC()
    );
    contractInfo.REDEEM_DOC_FEES_RBTC = await mocInrate.commissionRatesByTxType(
      await mocInrate.REDEEM_DOC_FEES_RBTC()
    );
    contractInfo.MINT_BTCX_FEES_RBTC = await mocInrate.commissionRatesByTxType(
      await mocInrate.MINT_BTCX_FEES_RBTC()
    );
    contractInfo.REDEEM_BTCX_FEES_RBTC = await mocInrate.commissionRatesByTxType(
      await mocInrate.REDEEM_BTCX_FEES_RBTC()
    );
    contractInfo.MINT_BPRO_FEES_MOC = await mocInrate.commissionRatesByTxType(
      await mocInrate.MINT_BPRO_FEES_MOC()
    );
    contractInfo.REDEEM_BPRO_FEES_MOC = await mocInrate.commissionRatesByTxType(
      await mocInrate.REDEEM_BPRO_FEES_MOC()
    );
    contractInfo.MINT_DOC_FEES_MOC = await mocInrate.commissionRatesByTxType(
      await mocInrate.MINT_DOC_FEES_MOC()
    );
    contractInfo.REDEEM_DOC_FEES_MOC = await mocInrate.commissionRatesByTxType(
      await mocInrate.REDEEM_DOC_FEES_MOC()
    );
    contractInfo.MINT_BTCX_FEES_MOC = await mocInrate.commissionRatesByTxType(
      await mocInrate.MINT_BTCX_FEES_MOC()
    );
    contractInfo.REDEEM_BTCX_FEES_MOC = await mocInrate.commissionRatesByTxType(
      await mocInrate.REDEEM_BTCX_FEES_MOC()
    );

    console.log('MoCInrate Contract Current Storage');
    console.log();
    console.log(`Commission Address: ${contractInfo.commissionAddress}`);
    console.log(`BitPro Interest Address: ${contractInfo.getBitProInterestAddress}`);
    console.log(
      `BitPro Rate: ${contractInfo.getBitProRate} (${BigNumber(contractInfo.getBitProRate)
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
  } catch (error) {
    callback(error);
  }

  callback();
};
