const MoCHelperLibMock = artifacts.require('./contracts/mocks/MoCHelperLibMock.sol');
const MoCInrateCommFees = artifacts.require('./contracts/MoCInrateCommFees.sol');
const MocInrateChangerCommFees = artifacts.require('./contracts/MocInrateChangerCommFees.sol');

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
      { txType: (await this.mocInrate.MINT_BPRO_FEES_RBTC()).toString(), fee: (0.1 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.REDEEM_BPRO_FEES_RBTC()).toString(), fee: (0.2 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.MINT_DOC_FEES_RBTC()).toString(), fee: (0.3 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.REDEEM_DOC_FEES_RBTC()).toString(), fee: (0.4 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.MINT_BTCX_FEES_RBTC()).toString(), fee: (0.5 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.REDEEM_BTCX_FEES_RBTC()).toString(), fee: (0.6 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.MINT_BPRO_FEES_MOC()).toString(), fee: (0.7 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.REDEEM_BPRO_FEES_MOC()).toString(), fee: (0.8 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.MINT_DOC_FEES_MOC()).toString(), fee: (0.9 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.REDEEM_DOC_FEES_MOC()).toString(), fee: (0.010 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.MINT_BTCX_FEES_MOC()).toString(), fee: (0.011 * mocHelper.MOC_PRECISION).toString() },
      { txType: (await this.mocInrate.REDEEM_BTCX_FEES_MOC()).toString(), fee: (0.012 * mocHelper.MOC_PRECISION).toString() },
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
      for (var i = 0; i < this.commissionRatesArray.length; i++) {
        const newCommisionRateValidTxType = await this.mocInrateCommFees.calcCommissionValue((scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(), this.commissionRatesArray[i].txType);
        // The fee from the commissionRatesArray is already converted to wei
        const testCommissionValue = (scenario.rbtcAmount * this.commissionRatesArray[i].fee);
        mocHelper.assertBig(
          newCommisionRateValidTxType.toString(),
          testCommissionValue.toString(),
          `final commission amount should be ${testCommissionValue.toString()}`
        );
      } 
    });
  });
});