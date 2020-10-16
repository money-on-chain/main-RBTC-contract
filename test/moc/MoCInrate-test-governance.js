const testHelperBuilder = require('../mocHelper.js');

let mocHelper;

const NOT_AUTHORIZED_CHANGER = 'not_authorized_changer';
// eslint-disable-next-line quotes
const INVALID_TXTYPE_ERROR = "Invalid transaction type 'txType'";

// Commission rates are set in contractsBuilder.js

const scenario = {
  btcxTmin: 4,
  btcxTmax: 7777777,
  btcxPower: 7,
  bitProInterestBlockSpan: 50 * 80 * 12,
  bitProRate: 78,
  rbtcAmount: 20,
  commissionAmount: 4,
  invalidTxType: 0,
  validTxType: 2,
  nonexistentTxType: 15,
  commissionAmountZero: 0
};

contract('MoCInrate Governed', function([owner, account2]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    this.mocInrate = mocHelper.mocInrate;
    this.governor = mocHelper.governor;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;

    // Execute change to initialize commission rates array
    await this.governor.executeChange(this.mockMocInrateChanger.address);
  });

  beforeEach(function() {
    return mocHelper.revertState();
  });

  describe('MoCInrate settings params', function() {
    describe('GIVEN the default tMin (BTCX)', function() {
      it(`THEN an unauthorized account ${account2} tries to change btxcTmin to ${scenario.btcxTmin}`, async function() {
        try {
          await this.mocInrate.setBtcxTmin(scenario.btcxTmin, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTHORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set btxcTmin`
          );
        }
      });
      it(`THEN an authorized contract tries to change btxcTmin to ${scenario.btcxTmin}`, async function() {
        await this.mockMocInrateChanger.setBtcxTmin(scenario.btcxTmin);
        await this.governor.executeChange(this.mockMocInrateChanger.address);
        const newPeg = await this.mocInrate.getBtcxTmin();
        mocHelper.assertBig(
          newPeg,
          scenario.btcxTmin,
          `tMin (BTCX) should be ${scenario.btcxTmin}`
        );
      });
    });

    describe('GIVEN the default tMax (BTCX)', function() {
      it(`THEN an unauthorized account ${account2} tries to change btxcTmax to ${scenario.btcxTmax}`, async function() {
        try {
          await this.mocInrate.setBtcxTmax(scenario.btcxTmax, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTHORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set btcxTmax`
          );
        }
      });
      it(`THEN an authorized contract tries to change btcxTmax to ${scenario.btcxTmax}`, async function() {
        await this.mockMocInrateChanger.setBtcxTmax(scenario.btcxTmax);
        await this.governor.executeChange(this.mockMocInrateChanger.address);
        const newBtcxTmax = await this.mocInrate.getBtcxTmax();
        mocHelper.assertBig(
          newBtcxTmax,
          scenario.btcxTmax,
          `tMax (BTCX) should be ${scenario.btcxTmax}`
        );
      });
    });

    describe('GIVEN the default power (BTCX)', function() {
      it(`THEN an unauthorized account ${account2} tries to change btcxPower to ${scenario.btcxPower}`, async function() {
        try {
          await this.mocInrate.setBtcxPower(scenario.btcxPower, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTHORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set btcxPower`
          );
        }
      });
      it(`THEN an authorized contract tries to change btcxPower to ${scenario.btcxPower}`, async function() {
        await this.mockMocInrateChanger.setBtcxPower(scenario.btcxPower);
        await this.governor.executeChange(this.mockMocInrateChanger.address);
        const newBtcxPower = await this.mocInrate.getBtcxPower();
        mocHelper.assertBig(
          newBtcxPower,
          scenario.btcxPower,
          `power (BTCX) should be ${scenario.btcxPower}`
        );
      });
    });

    // TODO: FIX calcCommissionValue TESTS!
    describe('GIVEN different transaction types and their fees to calculate commission rate (calcCommissionValue)', function() {
      it(`THEN transaction type ${scenario.invalidTxType} is invalid`, async function() {
        try {
          const newCommisionRateInvalidTxType = await this.mocInrate.calcCommissionValue(
            (scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(),
            scenario.invalidTxType
          );
          assert(newCommisionRateInvalidTxType === null, 'This should not happen');
        } catch (err) {
          assert(
            err.message.search(INVALID_TXTYPE_ERROR) >= 0,
            `Transaction type ${scenario.invalidTxType} is invalid`
          );
        }
      });
      it(`THEN transaction type ${scenario.validTxType} is valid`, async function() {
        const newCommisionRateValidTxType = await this.mocInrate.calcCommissionValue(
          (scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(),
          scenario.validTxType.toString()
        );
        console.log('scenario.validTxType: ', scenario.validTxType);
        console.log('newCommisionRateValidTxType: ', newCommisionRateValidTxType);
        mocHelper.assertBig(
          web3.utils.fromWei(newCommisionRateValidTxType.toString()),
          scenario.commissionAmount,
          `final commission amount should be ${scenario.commissionAmount} ether`
        );
      });
      it(`THEN transaction type ${scenario.nonexistentTxType} is non-existent`, async function() {
        const newCommisionRateNonExistentTxType = await this.mocInrate.calcCommissionValue(
          (scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(),
          scenario.nonexistentTxType
        );
        mocHelper.assertBig(
          newCommisionRateNonExistentTxType,
          scenario.commissionAmountZero,
          `final commission amount should be ${scenario.commissionAmountZero} ether`
        );
      });
    });

    describe('GIVEN different *valid* transaction types and their fees to calculate commission rate (calcCommissionValue)', function() {
      it('THEN the transaction types defined in the "commissionRates" array are valid', async function() {
        const commissionRatesArrayLength = await this.mockMocInrateChanger.commissionRatesLength();
        console.log('length: ', commissionRatesArrayLength);

        // Iterate through array
        for (let i = 0; i < commissionRatesArrayLength; i++) {
          const commissionRate = await this.mockMocInrateChanger.commissionRates(i);
          console.log('commissionRate ' + i + ': ' + commissionRate);
          const newCommisionRateValidTxType = await this.mocInrate.calcCommissionValue(
            (scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(),
            commissionRate.txType
          );
          // The fee from the commissionRatesArray is already converted to wei
          const testCommissionValue = scenario.rbtcAmount * commissionRate.fee;
          mocHelper.assertBig(
            newCommisionRateValidTxType.toString(),
            testCommissionValue.toString(),
            `final commission amount should be ${testCommissionValue.toString()}`
          );
        }
      });
    });

    describe('GIVEN the default bitProInterestBlockSpan', function() {
      it(`THEN an unauthorized account ${account2} tries to change bitProInterestBlockSpan to ${scenario.bitProInterestBlockSpan}`, async function() {
        try {
          await this.mocInrate.setBitProInterestBlockSpan(scenario.bitProInterestBlockSpan, {
            from: account2
          });
        } catch (err) {
          assert(
            NOT_AUTHORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set bitProInterestBlockSpan`
          );
        }
      });
      it(`THEN an authorized contract tries to change bitProInterestBlockSpan to ${scenario.bitProInterestBlockSpan}`, async function() {
        await this.mockMocInrateChanger.setBitProInterestBlockSpan(
          scenario.bitProInterestBlockSpan
        );
        await this.governor.executeChange(this.mockMocInrateChanger.address);
        const newBitProInterestBlockSpan = await this.mocInrate.getBitProInterestBlockSpan();
        mocHelper.assertBig(
          newBitProInterestBlockSpan,
          scenario.bitProInterestBlockSpan,
          `bitProInterestBlockSpan should be ${scenario.bitProInterestBlockSpan}`
        );
      });
    });

    describe('GIVEN the default bitProRate', function() {
      it(`THEN an unauthorized account ${account2} tries to change bitProRate to ${scenario.bitProRate}`, async function() {
        try {
          await this.mocInrate.setBitProRate(scenario.bitProRate, {
            from: account2
          });
        } catch (err) {
          assert(
            NOT_AUTHORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set bitProRate`
          );
        }
      });
      it(`THEN an authorized contract tries to change bitProRate to ${scenario.bitProRate}`, async function() {
        await this.mockMocInrateChanger.setBitProRate(scenario.bitProRate);
        await this.governor.executeChange(this.mockMocInrateChanger.address);
        const newBitProRate = await this.mocInrate.getBitProRate();
        mocHelper.assertBig(
          newBitProRate,
          scenario.bitProRate,
          `bitProRate should be ${scenario.bitProRate}`
        );
      });
    });
  });
});
