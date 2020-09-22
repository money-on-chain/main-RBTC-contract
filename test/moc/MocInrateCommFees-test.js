const MoCHelperLibMock = artifacts.require('./contracts/mocks/MoCHelperLibMock.sol');
const MoCInrateCommFees = artifacts.require('./contracts/MoCInrateCommFees.sol');
const MocInrateChangerCommFees = artifacts.require('./contracts/MocInrateChangerCommFees.sol');

const { assertEvent } = require('zos-lib');
const testHelperBuilder = require('../mocHelper.js');
let mocHelper;

const INVALID_TXTYPE_ERROR = "Invalid transaction type 'txType'";

const scenario = {
    rbtcAmount: 20,
    //commissionRate: 0.2,
    commissionAmount: 4,
    invalidTxType: 0,
    validTxType: 2,
    nonexistentTxType: 15,
    commissionAmountZero: 0
};

contract('MoCInrateCommFees', function([owner]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    this.mocInrate = mocHelper.mocInrate;
    this.commissionRatesArray = [
      { txType: (await this.mocInrate.MINT_BPRO_FEES_RBTC()).toString(), fee: web3.utils.toWei('0.1') },
      { txType: (await this.mocInrate.REDEEM_BPRO_FEES_RBTC()).toString(), fee: web3.utils.toWei('0.2')},
      { txType: (await this.mocInrate.MINT_DOC_FEES_RBTC()).toString(), fee: web3.utils.toWei('0.3') },
      { txType: (await this.mocInrate.REDEEM_DOC_FEES_RBTC()).toString(), fee: web3.utils.toWei('0.4') },
      { txType: (await this.mocInrate.MINT_BTCX_FEES_RBTC()).toString(), fee: web3.utils.toWei('0.5') },
      { txType: (await this.mocInrate.REDEEM_BTCX_FEES_RBTC()).toString(), fee: web3.utils.toWei('0.6') },
      { txType: (await this.mocInrate.MINT_BPRO_FEES_MOC()).toString(), fee: web3.utils.toWei('0.7') },
      { txType: (await this.mocInrate.REDEEM_BPRO_FEES_MOC()).toString(), fee: web3.utils.toWei('0.8') },
      { txType: (await this.mocInrate.MINT_DOC_FEES_MOC()).toString(), fee: web3.utils.toWei('0.9') },
      { txType: (await this.mocInrate.REDEEM_DOC_FEES_MOC()).toString(), fee: web3.utils.toWei('0.10')},
      { txType: (await this.mocInrate.MINT_BTCX_FEES_MOC()).toString(), fee: web3.utils.toWei('0.11') },
      { txType: (await this.mocInrate.REDEEM_BTCX_FEES_MOC()).toString(), fee: web3.utils.toWei('0.12') },
    ];

    this.governor = mocHelper.governor;

    this.mocHelperLibMock = await MoCHelperLibMock.new();
    await MoCInrateCommFees.link('MoCHelperLib', this.mocHelperLibMock.address);

    this.mocInrateCommFees = await MoCInrateCommFees.new();
    await this.mocInrateCommFees.initialize(
      mocHelper.mocConnector.address,
      this.governor.address,
      0,
      0,
      0,
      0,
      0,
      owner,
      owner,
      0,
      0,
      0,
      0
    );

    this.mocInrateChangerCommFees = await MocInrateChangerCommFees.new(
      this.mocInrateCommFees.address,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      this.commissionRatesArray,
      { from: owner }
    );

    await this.mocInrateChangerCommFees.transferOwnership(this.governor.address);
    await this.governor.executeChange(this.mocInrateChangerCommFees.address);
  });

  describe.only('GIVEN different transaction types and their fees to calculate commission rate (calcCommissionValue)', function() {
    it(`THEN transaction type ${scenario.invalidTxType} is invalid`, async function() {
      try {
        const newCommisionRateInvalidTxType = await this.mocInrateCommFees.calcCommissionValue(web3.utils.toWei(scenario.rbtcAmount.toString()), scenario.invalidTxType);
        assert(
          newCommisionRateInvalidTxType === null,
          `This should not happen`
        );
      } 
      catch (err) {
        assert(
          err.message.search(INVALID_TXTYPE_ERROR) >= 0,
          `Transaction type ${scenario.invalidTxType} is invalid`
        );
      }
    });
    it(`THEN transaction type ${scenario.validTxType} is valid`, async function() {
      const newCommisionRateValidTxType = await this.mocInrateCommFees.calcCommissionValue(web3.utils.toWei(scenario.rbtcAmount.toString()), scenario.validTxType);
      mocHelper.assertBig(
        web3.utils.fromWei(newCommisionRateValidTxType.toString()),
        scenario.commissionAmount,
        `final commission amount should be ${scenario.commissionAmount} ether`
      );
    });
    it(`THEN transaction type ${scenario.nonexistentTxType} is non-existent`, async function() {
      const newCommisionRateNonExistentTxType = await this.mocInrateCommFees.calcCommissionValue(web3.utils.toWei(scenario.rbtcAmount.toString()), scenario.nonexistentTxType);
      mocHelper.assertBig(
        newCommisionRateNonExistentTxType,
        scenario.commissionAmountZero,
        `final commission amount should be ${scenario.commissionAmountZero} ether`
      );
    });
  });

  describe.only('GIVEN different *valid* transaction types and their fees to calculate commission rate (calcCommissionValue)', function() {
    it('THEN the transaction types defined in the "commissionRatesArray" are valid', async function() {
      // Iterate through array
      for (const testCase of this.commissionRatesArray) {
        const newCommisionRateValidTxType = await this.mocInrateCommFees.calcCommissionValue(web3.utils.toWei(scenario.rbtcAmount.toString()), testCase.txType);
        const testCommissionValue = (scenario.rbtcAmount * testCase.fee) / 10 ** 18;
        console.log(newCommisionRateValidTxType.toString());
        console.log(testCommissionValue.toString());
        console.log(testCase.fee.toString());
        mocHelper.assertBig(
          web3.utils.fromWei(newCommisionRateValidTxType.toString()),
          testCommissionValue,
          `final commission amount should be ${testCommissionValue} ether`
        );
      } 
    });
  });
});