const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;

const NOT_AUTHORIZED_CHANGER = 'not_authorized_changer';
// eslint-disable-next-line quotes
const INVALID_TXTYPE_ERROR = 'Invalid txType';

const scenario = {
  btcxTmin: 4,
  btcxTmax: 7777777,
  btcxPower: 7,
  bitProInterestBlockSpan: 50 * 80 * 12,
  bitProRate: 78,
  rbtcAmount: 20,
  commissionAmount: 0.04,
  invalidTxType: 0,
  validTxType: 2,
  nonexistentTxType: 15,
  commissionAmountZero: 0
};

contract('MoCInrate Governed', function([owner, account2, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.mocInrate = mocHelper.mocInrate;
    this.governor = mocHelper.governor;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0.01, owner);

    // Commission rates for test are set in functionHelper.js
    await mocHelper.mockMocInrateChanger.setCommissionRates(
      await mocHelper.getCommissionsArrayNonZero()
    );
    await this.governor.executeChange(this.mockMocInrateChanger.address);
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

    describe('GIVEN different transaction types and their fees to calculate commission rate (calcCommissionValue)', function() {
      it(`THEN transaction type ${scenario.invalidTxType} is invalid`, async function() {
        try {
          const newCommisionRateInvalidTxType = await this.mocInrate.methods[
            'calcCommissionValue(uint256,uint8)'
          ]((scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(), scenario.invalidTxType);
          assert(newCommisionRateInvalidTxType === null, 'This should not happen');
        } catch (err) {
          assert(
            err.message.search(INVALID_TXTYPE_ERROR) >= 0,
            `Transaction type ${scenario.invalidTxType} is invalid`
          );
        }
      });
      it(`THEN transaction type ${scenario.validTxType} is valid`, async function() {
        const newCommisionRateValidTxType = await this.mocInrate.methods[
          'calcCommissionValue(uint256,uint8)'
        ](
          (scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(),
          scenario.validTxType.toString()
        );
        mocHelper.assertBig(
          newCommisionRateValidTxType.toString(),
          (scenario.commissionAmount * mocHelper.MOC_PRECISION).toString(),
          `final commission amount should be ${scenario.commissionAmount} ether`
        );
      });
      it('THEN DEPRECATED Retro compatible calcCommissionValue is valid', async function() {
        // retro compatible calcCommissionValue always uses rates for mint bpro with rbtc comissions
        const commissionRate = await this.mocInrate.commissionRatesByTxType(1);
        const newCommisionRateValidTxType = await this.mocInrate.calcCommissionValue(
          (scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString()
        );
        console.log('newCommisionRateValidTxType', newCommisionRateValidTxType.toString());
        const finalCommission = commissionRate * scenario.rbtcAmount;
        mocHelper.assertBig(
          newCommisionRateValidTxType.toString(),
          finalCommission.toString(),
          `final commission amount should be ${finalCommission / mocHelper.MOC_PRECISION} ether`
        );
      });
      it(`THEN transaction type ${scenario.nonexistentTxType} is non-existent`, async function() {
        const newCommisionRateNonExistentTxType = await this.mocInrate.methods[
          'calcCommissionValue(uint256,uint8)'
        ]((scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(), scenario.nonexistentTxType);
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

        // Iterate through array
        for (let i = 0; i < commissionRatesArrayLength; i++) {
          /* eslint-disable no-await-in-loop */
          const commissionRate = await this.mockMocInrateChanger.commissionRates(i);

          const newCommisionRateValidTxType = await this.mocInrate.methods[
            'calcCommissionValue(uint256,uint8)'
          ]((scenario.rbtcAmount * mocHelper.MOC_PRECISION).toString(), commissionRate.txType);

          /* eslint-enable no-await-in-loop */
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

    describe('GIVEN the default commissionRates', function() {
      it(`THEN an unauthorized account ${account2} tries to change commissionRates with another array`, async function() {
        const setCommissionRates = this.mockMocInrateChanger.setCommissionRates(
          await mocHelper.getCommissionsArrayChangingTest(),
          { from: account2 }
        );
        await expectRevert(setCommissionRates, 'Ownable: caller is not the owner');
      });
      it('THEN an authorized contract tries to change commissionRate with another array', async function() {
        await this.mockMocInrateChanger.setCommissionRates(
          await mocHelper.getCommissionsArrayChangingTest()
        );
        await this.governor.executeChange(this.mockMocInrateChanger.address);
        const newCommissionRate = await this.mocInrate.commissionRatesByTxType(
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );
        const expectedValue = '2000000000000000000';
        mocHelper.assertBig(
          newCommissionRate,
          expectedValue,
          `commissionRate should be ${expectedValue}`
        );
      });
    });

    describe('GIVEN a commissionRates array with invalid length', function() {
      it('THEN setting this new array will fail and revert', async function() {
        const setCommissionRates = this.mockMocInrateChanger.setCommissionRates(
          await mocHelper.getCommissionsArrayInvalidLength()
        );
        await expectRevert(setCommissionRates, 'commissionRates length must be between 1 and 50');
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
  describe('MoCInrate calculate markup', function() {
    it('WHEN address of vendorAccount is 0x0, THEN markup is 0', async function() {
      const zeroAddress = '0x0000000000000000000000000000000000000000';
      const markup = await this.mocInrate.calculateVendorMarkup(
        zeroAddress,
        toContractBN(1000 * mocHelper.MOC_PRECISION)
      );
      mocHelper.assertBig(markup.toString(), 0, 'vendor markup should be 0');
    });
    it('WHEN address of vendorAccount is valid, THEN markup is calculated correctly', async function() {
      const vendorMarkup = 10;
      const markup = await this.mocInrate.calculateVendorMarkup(
        vendorAccount,
        toContractBN(1000 * mocHelper.MOC_PRECISION)
      );
      mocHelper.assertBig(
        markup.toString(),
        (vendorMarkup * mocHelper.MOC_PRECISION).toString(),
        `vendor markup should be ${vendorMarkup}`
      );
    });
  });
});
