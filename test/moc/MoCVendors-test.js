const { BigNumber } = require('bignumber.js');
const { assert } = require('chai');
const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');
const { toContract } = require('../../utils/numberHelper');

let mocHelper;
let toContractBN;

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

contract('MoC: MoCVendors', function([
  owner,
  userAccount,
  commissionsAccount,
  unauthorizedAccount,
  inexistentVendorAccount,
  vendorAccount1,
  vendorAccount2,
  vendorAccount3,
  vendorAccount4,
  vendorAccount5
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.governor = mocHelper.governor;
    this.mocVendors = mocHelper.mocVendors;
    this.mockMoCVendorsChanger = mocHelper.mockMoCVendorsChanger;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.mocSettlement = mocHelper.mocSettlement;
    this.mocVendorsChangerHarness = mocHelper.mocVendorsChangerHarness;

    await mocHelper.revertState();
  });
  describe('GIVEN vendors can integrate their platforms with MoC protocol', function() {
    const scenarios = [
      // Vendor 1
      {
        params: {
          account: vendorAccount1,
          markup: 0.01,
          staking: 1, // (btcPrice * (mintAmount * markup) / mocPrice)
          mocAmount: 10000,
          mintAmount: 10,
          addStakeMessage:
            'WHEN a vendor adds staking of $STAKING$ THEN VendorStakeAdded event is emitted',
          removeStakeMessage:
            'WHEN a vendor removes staking of $STAKING$ THEN VendorStakeRemoved event is emitted'
        },
        expect: {
          totalPaidInMoC: 0.1,
          paidMoC: 0,
          paidRBTC: 0.1,
          staking: 1
        }
      },
      // Vendor 2
      {
        params: {
          account: vendorAccount2,
          markup: 0.005,
          staking: 0.5,
          mocAmount: 10000,
          mintAmount: 0,
          addStakeMessage:
            'WHEN a vendor adds staking of $STAKING$ THEN VendorStakeAdded event is emitted',
          removeStakeMessage: 'WHEN a vendor cannot remove staking THEN revert is expected'
        },
        expect: {
          totalPaidInMoC: 0,
          paidMoC: 0,
          paidRBTC: 0,
          staking: 0.5
        }
      },
      // Vendor 3
      {
        params: {
          account: vendorAccount3,
          markup: 0,
          staking: 0,
          mocAmount: 10000,
          mintAmount: 0,
          addStakeMessage: 'WHEN a vendor adds staking of $STAKING$ THEN revert is expected',
          removeStakeMessage: 'WHEN a vendor removes staking of $STAKING$ THEN revert is expected'
        },
        expect: {
          totalPaidInMoC: 0,
          paidMoC: 0,
          paidRBTC: 0,
          staking: 0
        }
      }
    ];

    scenarios.forEach(async scenario => {
      let registerVendorTx;
      let addStakeTx;
      let removeStakeTx;
      let unregisterVendorTx;
      let vendorInMapping;

      before(async function() {
        await mocHelper.mintMoCToken(scenario.params.account, scenario.params.mocAmount, owner);
        await mocHelper.approveMoCToken(
          this.mocVendors.address,
          scenario.params.mocAmount,
          scenario.params.account
        );

        const vendorToRegister = {
          account: scenario.params.account,
          markup: toContract(scenario.params.markup * mocHelper.MOC_PRECISION).toString()
        };

        await this.mockMoCVendorsChanger.setVendorsToRegister([vendorToRegister]);

        registerVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);

        // Commission rates for test are set in functionHelper.js
        await mocHelper.mockMocInrateChanger.setCommissionRates(
          await mocHelper.getCommissionsArrayNonZero()
        );

        // set commissions address
        await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
        // update params
        await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
      });
      it('WHEN a vendor is registered THEN VendorRegistered event is emitted', async function() {
        const [vendorRegisteredEvent] = await mocHelper.findEvents(
          registerVendorTx,
          'VendorRegistered'
        );

        assert(vendorRegisteredEvent, 'Event was not emitted');
        assert(
          vendorRegisteredEvent.account === scenario.params.account,
          'Vendor account is incorrect'
        );
      });
      it(
        scenario.params.addStakeMessage.replace('$STAKING$', scenario.params.staking),
        async function() {
          try {
            addStakeTx = await this.mocVendors.addStake(
              toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
              { from: scenario.params.account }
            );

            const [vendorStakeAddedEvent] = await mocHelper.findEvents(
              addStakeTx,
              'VendorStakeAdded'
            );

            assert(vendorStakeAddedEvent, 'Event was not emitted');
            assert(
              vendorStakeAddedEvent.account === scenario.params.account,
              'Vendor account is incorrect'
            );
            mocHelper.assertBigRBTC(
              vendorStakeAddedEvent.staking,
              scenario.expect.staking,
              'Should increase by staking'
            );
          } catch (err) {
            if (new BigNumber(scenario.expect.staking).gt(new BigNumber(0))) {
              assert(
                err.reason === 'Vendor total paid is not enough',
                `Vendor ${scenario.params.account} should not be able to add staking`
              );
            } else {
              assert(
                err.reason === 'Staking should be greater than 0',
                `Vendor ${scenario.params.account} should not be able to add staking of 0`
              );
            }
          }
        }
      );
      it(`WHEN a user mints ${scenario.params.mintAmount} BPRO THEN the vendor receives his corresponding fee`, async function() {
        // Make a transaction so that the vendor has something to remove from staking
        await mocHelper.mintBProAmount(
          userAccount,
          scenario.params.mintAmount,
          scenario.params.account
        );

        const totalPaidInMoC = await this.mocVendors.getTotalPaidInMoC(scenario.params.account);
        const paidMoC = await this.mocVendors.getPaidMoC(scenario.params.account);
        const paidRBTC = await this.mocVendors.getPaidRBTC(scenario.params.account);

        mocHelper.assertBigRBTC(
          totalPaidInMoC,
          scenario.expect.totalPaidInMoC,
          'totalPaidInMoC is incorrect'
        );
        mocHelper.assertBigRBTC(paidMoC, scenario.expect.paidMoC, 'paidMoC is incorrect');
        mocHelper.assertBigRBTC(paidRBTC, scenario.expect.paidRBTC, 'paidRBTC is incorrect');
      });
      it('WHEN retrieving vendor from getters, THEN it matches the information from mapping', async function() {
        vendorInMapping = await this.mocVendors.vendors(scenario.params.account);

        const isActive = await this.mocVendors.getIsActive(scenario.params.account);
        const markup = await this.mocVendors.getMarkup(scenario.params.account);
        const totalPaidInMoC = await this.mocVendors.getTotalPaidInMoC(scenario.params.account);
        const staking = await this.mocVendors.getStaking(scenario.params.account);
        const paidMoC = await this.mocVendors.getPaidMoC(scenario.params.account);
        const paidRBTC = await this.mocVendors.getPaidRBTC(scenario.params.account);

        assert(vendorInMapping.isActive === isActive, 'isActive is incorrect');
        mocHelper.assertBig(vendorInMapping.markup, markup, 'markup is incorrect');
        mocHelper.assertBig(
          vendorInMapping.totalPaidInMoC,
          totalPaidInMoC,
          'totalPaidInMoC is incorrect'
        );
        mocHelper.assertBig(vendorInMapping.staking, staking, 'staking is incorrect');
        mocHelper.assertBig(vendorInMapping.paidMoC, paidMoC, 'paidMoC is incorrect');
        mocHelper.assertBig(vendorInMapping.paidRBTC, paidRBTC, 'paidRBTC is incorrect');
      });
      it(
        scenario.params.removeStakeMessage.replace('$STAKING$', scenario.params.staking),
        async function() {
          try {
            removeStakeTx = await this.mocVendors.removeStake(
              toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
              { from: scenario.params.account }
            );

            const [vendorStakeRemovedEvent] = await mocHelper.findEvents(
              removeStakeTx,
              'VendorStakeRemoved'
            );

            assert(vendorStakeRemovedEvent, 'Event was not emitted');
            assert(
              vendorStakeRemovedEvent.account === scenario.params.account,
              'Vendor account is incorrect'
            );
            mocHelper.assertBigRBTC(
              vendorStakeRemovedEvent.staking,
              scenario.expect.staking,
              'Should decrease by staking'
            );
          } catch (err) {
            if (new BigNumber(scenario.expect.staking).gt(new BigNumber(0))) {
              assert(
                err.reason === 'Vendor total paid is not enough',
                `Vendor ${scenario.params.account} should not be able to remove staking`
              );
            } else {
              assert(
                err.reason === 'Staking should be greater than 0',
                `Vendor ${scenario.params.account} should not be able to remove staking of 0`
              );
            }
          }
        }
      );
      it('WHEN a vendor is unregistered THEN VendorUnregistered event is emitted', async function() {
        await this.mockMoCVendorsChanger.setVendorsToUnregister([scenario.params.account]);
        unregisterVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);

        const [vendorUnregisteredEvent] = await mocHelper.findEvents(
          unregisterVendorTx,
          'VendorUnregistered'
        );

        assert(vendorUnregisteredEvent, 'Event was not emitted');
        assert(
          vendorUnregisteredEvent.account === scenario.params.account,
          'Vendor account is incorrect'
        );
      });
      describe('GIVEN an inactive vendor tries to make changes', function() {
        it('WHEN an inactive vendor tries to add staking THEN an error should be raised', async function() {
          addStakeTx = this.mocVendors.addStake(
            toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
            { from: scenario.params.account }
          );

          await expectRevert(addStakeTx, 'Vendor is inexistent or inactive');
        });
        it('WHEN an inactive vendor tries to remove staking THEN an error should be raised', async function() {
          removeStakeTx = this.mocVendors.removeStake(
            toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
            { from: scenario.params.account }
          );

          await expectRevert(removeStakeTx, 'Vendor is inexistent or inactive');
        });
      });
    });
  });
  describe('Non-scenario tests', function() {
    beforeEach(async function() {
      await mocHelper.revertState();

      // Set vendors to register and to unregister with an empty array
      await this.mockMoCVendorsChanger.setVendorsToRegister([]);
      await this.mockMoCVendorsChanger.setVendorsToUnregister([]);
      await this.governor.executeChange(this.mockMoCVendorsChanger.address);
    });
    describe('GIVEN an unauthorized account tries to make changes', function() {
      it('WHEN an unauthorized account tries to register a vendor THEN an error should be raised', async function() {
        try {
          await this.mocVendors.registerVendor(
            vendorAccount4,
            toContract(100 * mocHelper.MOC_PRECISION).toString(),
            { from: unauthorizedAccount }
          );
        } catch (err) {
          assert(
            err.message.search('not_authorized_changer') >= 0,
            `${unauthorizedAccount} should not be authorized to register a vendor`
          );
        }
      });
      it('WHEN an unauthorized account tries to unregister a vendor THEN an error should be raised', async function() {
        try {
          await this.mocVendors.unregisterVendor(vendorAccount4, {
            from: unauthorizedAccount
          });
        } catch (err) {
          assert(
            err.reason === 'not_authorized_changer',
            `${unauthorizedAccount} should not be authorized to unregister a vendor`
          );
        }
      });
    });
    describe('GIVEN an inexistent vendor tries to makes changes', function() {
      it('WHEN an inexistent vendor tries to add staking THEN an error should be raised', async function() {
        const addStakeTx = this.mocVendors.addStake(toContractBN(10 * mocHelper.MOC_PRECISION), {
          from: inexistentVendorAccount
        });

        await expectRevert(addStakeTx, 'Vendor is inexistent or inactive');
      });
      it('WHEN an inexistent vendor tries to remove staking THEN an error should be raised', async function() {
        const removeStakeTx = this.mocVendors.removeStake(
          toContractBN(10 * mocHelper.MOC_PRECISION),
          { from: inexistentVendorAccount }
        );

        await expectRevert(removeStakeTx, 'Vendor is inexistent or inactive');
      });
    });
    describe('GIVEN a vendor with zero address is invalid', function() {
      it('WHEN trying to register a vendor with zero address THEN an error should be raised', async function() {
        const vendorToRegister = {
          account: ZERO_ADDRESS,
          markup: toContract(0.01 * mocHelper.MOC_PRECISION).toString()
        };

        await this.mockMoCVendorsChanger.setVendorsToRegister([vendorToRegister]);

        const registerVendorTx = this.governor.executeChange(this.mockMoCVendorsChanger.address);

        await expectRevert(registerVendorTx, 'Vendor account must not be 0x0');
      });
      it('WHEN trying to unregister a vendor with zero address THEN an error should be raised', async function() {
        await this.mockMoCVendorsChanger.setVendorsToUnregister([ZERO_ADDRESS]);

        const unregisterVendorTx = this.governor.executeChange(this.mockMoCVendorsChanger.address);

        await expectRevert(unregisterVendorTx, 'Vendor account must not be 0x0');
      });
    });
    describe('GIVEN there is a maximum markup that can be assigned to a vendor', function() {
      it('WHEN trying to register a vendor with an invalid value THEN an error should be raised', async function() {
        const vendorToRegister = {
          account: vendorAccount4,
          markup: toContract(10 * mocHelper.MOC_PRECISION).toString()
        };

        await this.mockMoCVendorsChanger.setVendorsToRegister([vendorToRegister]);

        const registerVendorTx = this.governor.executeChange(this.mockMoCVendorsChanger.address);

        await expectRevert(registerVendorTx, 'Vendor markup must not be greater than 1%');
      });
    });
    describe('GIVEN vendors can be registered and unregistered', function() {
      it('WHEN registering and unregistering vendors THEN the correct amount of registered vendors is retrieved', async function() {
        const vendor1 = await mocHelper.getVendorToRegisterAsArray(vendorAccount1, 0.001);
        const vendor2 = await mocHelper.getVendorToRegisterAsArray(vendorAccount2, 0.002);
        const vendor3 = await mocHelper.getVendorToRegisterAsArray(vendorAccount3, 0.003);
        const vendors = vendor1.concat(vendor2).concat(vendor3);

        let vendorCount;
        let activeVendorCount = vendors.length;
        let unregisterVendorTx;

        await this.mockMoCVendorsChanger.setVendorsToRegister(vendors);
        await this.governor.executeChange(this.mockMoCVendorsChanger.address);

        // Set vendors to register with an empty array
        await this.mockMoCVendorsChanger.setVendorsToRegister([]);

        vendorCount = await this.mocVendors.getVendorsCount();
        mocHelper.assertBig(vendorCount, activeVendorCount, 'Active vendor count is incorrect');

        // Unregister vendorAccount3
        await this.mockMoCVendorsChanger.setVendorsToUnregister([vendorAccount3]);
        unregisterVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
        activeVendorCount--;

        vendorCount = await this.mocVendors.getVendorsCount();
        mocHelper.assertBig(vendorCount, activeVendorCount, 'Active vendor count is incorrect');

        const [vendor3UnregisteredEvent] = await mocHelper.findEvents(
          unregisterVendorTx,
          'VendorUnregistered'
        );

        assert(vendor3UnregisteredEvent, 'Event was not emitted');
        assert(vendor3UnregisteredEvent.account === vendorAccount3, 'Vendor account is incorrect');

        // Unregister vendorAccount2
        await this.mockMoCVendorsChanger.setVendorsToUnregister([vendorAccount2]);
        unregisterVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
        activeVendorCount--;

        vendorCount = await this.mocVendors.getVendorsCount();
        mocHelper.assertBig(vendorCount, activeVendorCount, 'Active vendor count is incorrect');

        const [vendor2UnregisteredEvent] = await mocHelper.findEvents(
          unregisterVendorTx,
          'VendorUnregistered'
        );

        assert(vendor2UnregisteredEvent, 'Event was not emitted');
        assert(vendor2UnregisteredEvent.account === vendorAccount2, 'Vendor account is incorrect');

        // Unregister vendorAccount1
        await this.mockMoCVendorsChanger.setVendorsToUnregister([vendorAccount1]);
        unregisterVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
        activeVendorCount--;

        vendorCount = await this.mocVendors.getVendorsCount();
        mocHelper.assertBig(vendorCount, activeVendorCount, 'Active vendor count is incorrect');

        const [vendor1UnregisteredEvent] = await mocHelper.findEvents(
          unregisterVendorTx,
          'VendorUnregistered'
        );

        assert(vendor1UnregisteredEvent, 'Event was not emitted');
        assert(vendor1UnregisteredEvent.account === vendorAccount1, 'Vendor account is incorrect');
      });
    });
    describe('GIVEN vendors can be registered and unregistered via an array in changer contract', function() {
      it('WHEN registering more vendors than allowed THEN an error should be raised', async function() {
        // Using harness contract
        await this.mocVendorsChangerHarness.setVendorsToRegisterEmptyArray();
        await this.mocVendorsChangerHarness.setVendorsToUnregisterEmptyArray();
        await this.governor.executeChange(this.mocVendorsChangerHarness.address);

        const vendorsToRegister = [];

        /* eslint-disable no-await-in-loop */
        // 20 batches of 5 vendors at a time because of out-of-gas errors
        for (let i = 0; i < 20; i++) {
          for (let j = 0; j < 5; j++) {
            const account = web3.utils.randomHex(20);
            vendorsToRegister.push({
              account,
              markup: toContract(((i * j) / 100000) * mocHelper.MOC_PRECISION).toString()
            });
          }

          await this.mocVendorsChangerHarness.setVendorsToRegister(vendorsToRegister);
          await this.governor.executeChange(this.mocVendorsChangerHarness.address);
        }
        /* eslint-enable no-await-in-loop */

        // Add a new vendor - should not be possible
        await this.mocVendorsChangerHarness.setVendorsToRegister(
          await mocHelper.getVendorToRegisterAsArray(web3.utils.randomHex(20), 0.001)
        );

        const registerVendorTx = this.governor.executeChange(this.mocVendorsChangerHarness.address);

        await expectRevert(registerVendorTx, 'vendorsList length must be between 1 and 100');
      });
    });
    describe('GIVEN vendors get their amount paid in MoC reset every time settlement is run', function() {
      it('WHEN settlement runs, then totalPaidInMoC is 0', async function() {
        // Using harness contract
        await this.mocVendorsChangerHarness.setVendorsToRegisterEmptyArray();
        await this.mocVendorsChangerHarness.setVendorsToUnregisterEmptyArray();
        await this.governor.executeChange(this.mocVendorsChangerHarness.address);

        // Register vendor for test
        await this.mocVendorsChangerHarness.setVendorsToRegister(
          await mocHelper.getVendorToRegisterAsArray(vendorAccount5, 0.01)
        );
        await this.governor.executeChange(this.mocVendorsChangerHarness.address);

        const mocAmount = 1000;
        await mocHelper.mintMoCToken(vendorAccount5, mocAmount, owner);
        await mocHelper.approveMoCToken(this.mocVendors.address, mocAmount, vendorAccount5);

        // Add staking
        await this.mocVendors.addStake(toContractBN(mocAmount * mocHelper.MOC_PRECISION), {
          from: vendorAccount5
        });

        // Mint BPRO
        await mocHelper.mintBProAmount(
          userAccount,
          1000,
          vendorAccount5,
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );

        // Enabling Settlement
        await this.mocSettlement.setBlockSpan(1);
        await mocHelper.executeSettlement();

        const totalPaidInMoC = await this.mocVendors.getTotalPaidInMoC(vendorAccount5);

        mocHelper.assertBig(totalPaidInMoC, 0, 'Total paid in MoC is incorrect');
      });
    });
    describe('GIVEN the vendor markup can be changed via an array in changer contract', function() {
      it('WHEN registering said vendor with a different markup value THEN VendorUpdated event is emitted', async function() {
        // Register vendor
        let vendor = await mocHelper.getVendorToRegisterAsArray(vendorAccount1, 0.001);

        // Register vendor using harness contract
        await this.mocVendorsChangerHarness.setVendorsToRegister(vendor);
        await this.mocVendorsChangerHarness.setVendorsToUnregisterEmptyArray();
        await this.governor.executeChange(this.mocVendorsChangerHarness.address);

        // Update markup
        const newMarkup = 0.005;
        vendor = await mocHelper.getVendorToRegisterAsArray(vendorAccount1, newMarkup);

        // Update vendor using harness contract
        await this.mocVendorsChangerHarness.setVendorsToRegister(vendor);
        await this.mocVendorsChangerHarness.setVendorsToUnregisterEmptyArray();
        const updateVendorTx = await this.governor.executeChange(
          this.mocVendorsChangerHarness.address
        );

        const [vendorUpdatedEvent] = await mocHelper.findEvents(updateVendorTx, 'VendorUpdated');

        assert(vendorUpdatedEvent, 'Event was not emitted');
        mocHelper.assertBigRBTC(
          vendorUpdatedEvent.markup,
          newMarkup,
          'Vendor new markup is incorrect'
        );
      });
    });
  });
});
