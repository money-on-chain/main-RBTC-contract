const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
const NOT_AUTORIZED_CHANGER = 'not_authorized_changer';
const scenario = {
  peg: 2,
  liq: 2,
  utpdu: 10,
  blockSpan: 20 * 3,
  bproMaxDiscountRate: 250,
  emaCalculationBlockSpan: 20,
  smoothingFactor: 2,
  maxMintBPro: 2,
  liquidationEnabled: true,
  protected: 2
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

    describe('GIVEN on old mocPriceProvider', function() {
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

    describe('GIVEN an old mocToken', function() {
      describe('AND an authorized contract tries to set a new MoCToken', function() {
        let tx;
        const zeroAddress = '0x0000000000000000000000000000000000000000';
        beforeEach(async function() {
          await mocHelper.mockMocStateChanger.setMoCToken(zeroAddress);
          tx = await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
        });
        it('THEN the MoCToken address must be updated', async function() {
          const mocTokenAddress = await mocHelper.mocState.getMoCToken();
          assert(mocTokenAddress === zeroAddress, 'MoC Token not updates.');
        });
        it('THEN MoCTokenChanged event is emitted', async function() {
          const [mocTokenChangedEvent] = await mocHelper.findEvents(tx, 'MoCTokenChanged');
          assert(mocTokenChangedEvent.mocTokenAddress === zeroAddress, 'New address is different');
        });
      });
      it(`THEN an unauthorized account ${account2} tries to change MoCToken`, async function() {
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

    describe('GIVEN an old mocVendors', function() {
      describe('AND an authorized contract tries to set a new MoCVendors', function() {
        let tx;
        const zeroAddress = '0x0000000000000000000000000000000000000000';
        beforeEach(async function() {
          await mocHelper.mockMocStateChanger.setMoCVendors(zeroAddress);
          tx = await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
        });
        it('THEN the MoCVendors address must be updated', async function() {
          const mocVendorAddress = await mocHelper.mocState.getMoCVendors();
          assert(mocVendorAddress === zeroAddress, 'MoC Vendors not updates.');
        });
        it('THEN MoCVendorsChanged event is emitted', async function() {
          const [mocVendorsChangedEvent] = await mocHelper.findEvents(tx, 'MoCVendorsChanged');
          assert(
            mocVendorsChangedEvent.mocVendorsAddress === zeroAddress,
            'New address is different'
          );
        });
      });
      it(`THEN an unauthorized account ${account2} tries to change MoCVendor`, async function() {
        try {
          const zeroAddress = '0x0000000000000000000000000000000000000000';
          await mocHelper.mocState.setMoCVendors(zeroAddress, {
            from: account2
          });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set MoCVendors`
          );
        }
      });
    });

    describe('GIVEN the emaCalculationBlockSpan value', function() {
      it(`THEN an unauthorized account ${account2} tries to change emaCalculationBlockSpan to ${scenario.emaCalculationBlockSpan}`, async function() {
        try {
          await this.mocState.setEmaCalculationBlockSpan(scenario.emaCalculationBlockSpan, {
            from: account2
          });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set emaCalculationBlockSpan`
          );
        }
      });
      it(`THEN an authorized contract tries to change emaCalculationBlockSpan to ${scenario.emaCalculationBlockSpan}`, async function() {
        const oldEmaCalculationBlockSpan = await this.mocState.getEmaCalculationBlockSpan();
        assert(oldEmaCalculationBlockSpan > 0, 'emaCalculationBlockSpan should be greater than 0');
        await this.mockMocStateChanger.setEmaCalculationBlockSpan(scenario.emaCalculationBlockSpan);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newEmaCalculationBlockSpan = await this.mocState.getEmaCalculationBlockSpan();
        mocHelper.assertBig(
          newEmaCalculationBlockSpan,
          scenario.emaCalculationBlockSpan,
          `emaCalculationBlockSpan should be ${scenario.emaCalculationBlockSpan}`
        );
      });
    });

    describe('GIVEN the smoothingFactor value', function() {
      it(`THEN an unauthorized account ${account2} tries to change smoothingFactor to ${scenario.smoothingFactor}`, async function() {
        try {
          await this.mocState.setSmoothingFactor(scenario.smoothingFactor, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set smoothingFactor`
          );
        }
      });
      it(`THEN an authorized contract tries to change smoothingFactor to ${scenario.smoothingFactor}`, async function() {
        const oldSmoothingFactor = await this.mocState.getSmoothingFactor();
        assert(oldSmoothingFactor > 0, 'smoothingFactor should be greater than 0');
        await this.mockMocStateChanger.setSmoothingFactor(scenario.smoothingFactor);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newSmoothingFactor = await this.mocState.getSmoothingFactor();
        mocHelper.assertBig(
          newSmoothingFactor,
          scenario.smoothingFactor,
          `smoothingFactor should be ${scenario.smoothingFactor}`
        );
      });
    });

    describe('GIVEN the maxMintBPro value', function() {
      it(`THEN an unauthorized account ${account2} tries to change maxMintBPro to ${scenario.maxMintBPro}`, async function() {
        try {
          await this.mocState.setMaxMintBPro(scenario.maxMintBPro, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set maxMintBPro`
          );
        }
      });
      it(`THEN an authorized contract tries to change maxMintBPro to ${scenario.maxMintBPro}`, async function() {
        const oldMaxMintBPro = await this.mocState.getMaxMintBPro();
        assert(oldMaxMintBPro > 0, 'maxMintBPro should be greater than 0');
        await this.mockMocStateChanger.setMaxMintBPro(scenario.maxMintBPro);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newMaxMintBPro = await this.mocState.getMaxMintBPro();
        mocHelper.assertBig(
          newMaxMintBPro,
          scenario.maxMintBPro,
          `maxMintBPro should be ${scenario.maxMintBPro}`
        );
      });
    });

    describe('GIVEN the liquidationEnabled value', function() {
      it(`THEN an unauthorized account ${account2} tries to change liquidationEnabled to ${scenario.liquidationEnabled}`, async function() {
        try {
          await this.mocState.setLiquidationEnabled(scenario.liquidationEnabled, {
            from: account2
          });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set liquidationEnabled`
          );
        }
      });
      it(`THEN an authorized contract tries to change liquidationEnabled to ${scenario.liquidationEnabled}`, async function() {
        await this.mockMocStateChanger.setLiquidationEnabled(scenario.liquidationEnabled);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newLiquidationEnabled = await this.mocState.getLiquidationEnabled();
        assert(
          newLiquidationEnabled === scenario.liquidationEnabled,
          `liquidationEnabled should be ${scenario.liquidationEnabled}`
        );
      });
    });

    describe('GIVEN the protected value', function() {
      it(`THEN an unauthorized account ${account2} tries to change protected to ${scenario.protected}`, async function() {
        try {
          await this.mocState.setProtected(scenario.protected, { from: account2 });
        } catch (err) {
          assert(
            NOT_AUTORIZED_CHANGER === err.reason,
            `${account2} Should not be authorized to set protected`
          );
        }
      });
      it(`THEN an authorized contract tries to change protected to ${scenario.protected}`, async function() {
        const oldProtected = await this.mocState.getProtected();
        assert(oldProtected > 0, 'protected should be greater than 0');
        await this.mockMocStateChanger.setProtected(scenario.protected);
        await this.governor.executeChange(this.mockMocStateChanger.address);
        const newProtected = await this.mocState.getProtected();
        mocHelper.assertBig(
          newProtected,
          scenario.protected,
          `protected should be ${scenario.protected}`
        );
      });
    });
  });
});
