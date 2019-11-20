const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
const NOT_AUTHORIZED_CHANGER = 'not_authorized_changer';
const scenario = {
  btcxTmin: 4,
  btcxTmax: 7777777,
  btcxPower: 7,
  commissionRate: 50,
  bitProInterestBlockSpan: 50 * 80 * 12,
  bitProRate: 78
};

contract('MoCInrate Governed', function([owner, account2]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    this.mocInrate = mocHelper.mocInrate;
    this.governor = mocHelper.governor;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
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

    describe('GIVEN the default commissionRate', function() {
      it(`THEN an unauthorized account ${account2} tries to change commissionRate to ${scenario.commissionRate}`, async function() {
        try {
          await this.mocInrate.setCommissionRate(scenario.commissionRate, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTHORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set commissionRate`
          );
        }
      });
      it(`THEN an authorized contract tries to change commissionRate to ${scenario.commissionRate}`, async function() {
        await this.mockMocInrateChanger.setCommissionRate(scenario.commissionRate);
        await this.governor.executeChange(this.mockMocInrateChanger.address);
        const newCommissionRate = await this.mocInrate.getCommissionRate();
        mocHelper.assertBig(
          newCommissionRate,
          scenario.commissionRate,
          `commissionRate should be ${scenario.commissionRate}`
        );
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
