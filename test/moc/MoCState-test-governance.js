const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
const NOT_AUTORIZED_CHANGER = 'not_authorized_changer';
const scenario = {
  peg: 2,
  liq: 2,
  utpdu: 10,
  blockSpan: 20 * 3,
  bproMaxDiscountRate: 250
};

const BtcPriceProviderMock = artifacts.require('./contracts/mocks/BtcPriceProviderMock.sol');
const MoCPriceProviderMock = artifacts.require('./contracts/mocks/MoCPriceProviderMock.sol');

contract('MoCState Governed', function([owner, account2]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    this.mocState = mocHelper.mocState;
    this.governor = mocHelper.governor;
    this.mockMocStateChanger = mocHelper.mockMocStateChanger;
  });

  beforeEach(function() {
    return mocHelper.revertState();
  });

  describe('MoCState settings params', function() {
    describe('GIVEN the default peg value of 1', function() {
      it(`THEN an unathorized account ${account2} tries to change peg to ${scenario.peg}`, async function() {
        const oldPeg = await this.mocState.getPeg();
        mocHelper.assertBig(oldPeg, 1, 'PEG should be 1 by default');
        try {
          await this.mocState.setPeg(scenario.peg, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set peg`
          );
        }
      });
      it(`THEN an authorized contract tries to change peg to ${scenario.peg}`, async function() {
        const oldPeg = await this.mocState.getPeg();
        mocHelper.assertBig(oldPeg, 1, 'PEG should be 1 by default');
        await this.mockMocStateChanger.updatePegValue(scenario.peg);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newPeg = await this.mocState.getPeg();
        mocHelper.assertBig(newPeg, scenario.peg, `PEG should be ${scenario.peg}`);
      });
    });

    describe('GIVEN the liq value (currently 1.04)', function() {
      it(`THEN an unathorized account ${account2} tries to change liq to ${scenario.liq}`, async function() {
        try {
          await this.mocState.setLiq(scenario.liq, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set liq`
          );
        }
      });
      it(`THEN an authorized contract tries to change liq to ${scenario.liq}`, async function() {
        const oldLiq = await this.mocState.getLiq();
        assert(oldLiq > 0, 'LIQ should be greater than 0');
        await this.mockMocStateChanger.updateLiqValue(scenario.liq);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newLiq = await this.mocState.getLiq();
        mocHelper.assertBig(newLiq, scenario.liq, `LIQ should be ${scenario.liq}`);
      });
    });

    describe('GIVEN the utpdu value', function() {
      it(`THEN an unathorized account ${account2} tries to change utpdu to ${scenario.utpdu}`, async function() {
        const oldTpdu = await this.mocState.getUtpdu();
        assert(oldTpdu > 0, 'utpdu should be greater than 0');
        try {
          await this.mocState.setUtpdu(scenario.utpdu, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set utpdu`
          );
        }
      });
      it(`THEN an authorized contract tries to change utpdu to ${scenario.utpdu}`, async function() {
        const oldUtpdu = await this.mocState.getUtpdu();
        assert(oldUtpdu > 0, 'utpdu should be greater than 0');
        await this.mockMocStateChanger.updateUtpduValue(scenario.utpdu);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newUtpdu = await this.mocState.getUtpdu();
        mocHelper.assertBig(newUtpdu, scenario.utpdu, `UTPDU should be ${scenario.utpdu}`);
      });
    });

    describe('GIVEN the blockSpan value', function() {
      it(`THEN an unathorized account ${account2} tries to change blockSpan to ${scenario.blockSpan}`, async function() {
        const oldDaySpan = await this.mocState.getDayBlockSpan();
        assert(oldDaySpan > 0, 'blockSpan should be greater than 0');
        try {
          await this.mocState.setDayBlockSpan(scenario.utpdu, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set blockSpan`
          );
        }
      });
      it(`THEN an authorized contract tries to change blockSpan to ${scenario.blockSpan}`, async function() {
        const oldDaySpan = await this.mocState.getDayBlockSpan();
        assert(oldDaySpan > 0, 'blockSpan should be greater than 0');
        await this.mockMocStateChanger.updateDayBlockSpanValue(scenario.blockSpan);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newBlockSpan = await this.mocState.getDayBlockSpan();
        mocHelper.assertBig(
          newBlockSpan,
          scenario.blockSpan,
          `blockSpan should be ${scenario.blockSpan}`
        );
      });
    });

    describe('GIVEN the bproMaxDiscountRate value', function() {
      it(`THEN an authorized contract tries to change bproMaxDiscountRate to ${scenario.bproMaxDiscountRate}`, async function() {
        const oldMax = await this.mocState.getMaxDiscountRate();
        assert(oldMax > 0, 'bproMaxDiscountRate should be greater than 0');
        await this.mockMocStateChanger.updatemaxDiscRateValue(scenario.bproMaxDiscountRate);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newDisc = await this.mocState.getMaxDiscountRate();
        mocHelper.assertBig(
          newDisc,
          scenario.bproMaxDiscountRate,
          `blockSpan should be ${scenario.bproMaxDiscountRate}`
        );
      });
    });

    describe('GIVEN on old btcPriceProvider', function() {
      describe('AND an authorized contract tries to set a new BTCPriceProvider', function() {
        let tx;
        let newBtcPriceProvider;
        let oldBtcPriceProvider;
        beforeEach(async function() {
          oldBtcPriceProvider = await mocHelper.mocState.getBtcPriceProvider();
          newBtcPriceProvider = await BtcPriceProviderMock.new(1000003333);
          await mocHelper.mockMocStateChanger.setBtcPriceProvider(newBtcPriceProvider.address);
          tx = await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
        });
        it('THEN the BTCPriceProvider address must be updated', async function() {
          const btcPriceProviderAddress = await mocHelper.mocState.getBtcPriceProvider();
          assert(
            btcPriceProviderAddress === newBtcPriceProvider.address,
            'BTC Price provider not updates.'
          );
        });
        it('THEN BtcPriceProviderUpdated event is emitted', async function() {
          const [btcPriceProviderUpdatedEvent] = await mocHelper.findEvents(
            tx,
            'BtcPriceProviderUpdated'
          );
          assert(
            btcPriceProviderUpdatedEvent.oldAddress === oldBtcPriceProvider,
            'Old address is different'
          );
          assert(
            btcPriceProviderUpdatedEvent.newAddress === newBtcPriceProvider.address,
            'New address is different'
          );
        });
      });

      it(`THEN an unathorized account ${account2} tries to change BTCPriceProvider`, async function() {
        try {
          const newBtcPriceProvider = await BtcPriceProviderMock.new(1000003333);
          await mocHelper.mocState.setBtcPriceProvider(newBtcPriceProvider.address, {
            from: account2
          });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set BTCPriceProvider`
          );
        }
      });
    });

    describe.only('GIVEN on old mocPriceProvider', function() {
      describe('AND an authorized contract tries to set a new MoCPriceProvider', function() {
        let tx;
        let newMoCPriceProvider;
        let oldMoCPriceProvider;
        beforeEach(async function() {
          oldMoCPriceProvider = await mocHelper.mocState.getMoCPriceProvider();
          newMoCPriceProvider = await MoCPriceProviderMock.new(1000003333);
          await mocHelper.mockMocStateChanger.setMoCPriceProvider(newMoCPriceProvider.address);
          tx = await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
        });
        it('THEN the MoCPriceProvider address must be updated', async function() {
          const mocPriceProviderAddress = await mocHelper.mocState.getMoCPriceProvider();
          assert(
            mocPriceProviderAddress === newMoCPriceProvider.address,
            'MoC Price provider not updates.'
          );
        });
        it('THEN MoCPriceProviderUpdated event is emitted', async function() {
          const [mocPriceProviderUpdatedEvent] = await mocHelper.findEvents(
            tx,
            'MoCPriceProviderUpdated'
          );
          assert(
            mocPriceProviderUpdatedEvent.oldAddress === oldMoCPriceProvider,
            'Old address is different'
          );
          assert(
            mocPriceProviderUpdatedEvent.newAddress === newMoCPriceProvider.address,
            'New address is different'
          );
        });
      });

      it(`THEN an unathorized account ${account2} tries to change MoCPriceProvider`, async function() {
        try {
          const newMoCPriceProvider = await MoCPriceProviderMock.new(1000003333);
          await mocHelper.mocState.setMoCPriceProvider(newMoCPriceProvider.address, {
            from: account2
          });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set MoCPriceProvider`
          );
        }
      });
    });

    describe.only('GIVEN on old mocToken', function() {
      describe('AND an authorized contract tries to set a new MoCToken', function() {
        let tx;
        let oldMoCToken;
        let zeroAddress = '0x0000000000000000000000000000000000000000';
        beforeEach(async function() {
          oldMoCToken = await mocHelper.mocState.getMoCToken();
          await mocHelper.mockMocStateChanger.setMoCToken(zeroAddress);
          tx = await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
        });
        it('THEN the MoCToken address must be updated', async function() {
          const mocTokenAddress = await mocHelper.mocState.getMoCToken();
          assert(
            mocTokenAddress === zeroAddress,
            'MoC Token not updates.'
          );
        });
        it('THEN MoCTokenChanged event is emitted', async function() {
          const [mocTokenChangedEvent] = await mocHelper.findEvents(
            tx,
            'MoCTokenChanged'
          );
          assert(
            mocTokenChangedEvent.mocTokenAddress === zeroAddress,
            'New address is different'
          );
        });
      });

      it(`THEN an unathorized account ${account2} tries to change MoCToken`, async function() {
        try {
          const zeroAddress = '0x0000000000000000000000000000000000000000';
          await mocHelper.mocState.setMoCToken(zeroAddress, {
            from: account2
          });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set MoCToken`
          );
        }
      });
    });
  });
});
