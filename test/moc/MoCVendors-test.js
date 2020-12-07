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
  vendorAccount4
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.governor = mocHelper.governor;
    this.mocVendors = mocHelper.mocVendors;
    this.mockMoCVendorsChanger = mocHelper.mockMoCVendorsChanger;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;

    await mocHelper.revertState();
  });
  beforeEach(async function() {
    // await mocHelper.revertState();
  });
  describe.only('GIVEN vendors can integrate their platforms with MoC protocol', function() {
    const scenarios = [
      // Vendor 1
      {
        params: {
          account: vendorAccount1,
          markup: 0.1,
          staking: 1, // (btcPrice * (mintAmount * markup) / mocPrice)
          mocAmount: 10000,
          mintAmount: 10,
          removeStakeMessage:
            'WHEN a vendor removes staking of $STAKING$ THEN VendorStakeRemoved event is emitted'
        },
        expect: {
          totalPaidInMoC: 1,
          paidMoC: 0,
          paidRBTC: 1,
          staking: 1
        }
      },
      // Vendor 2
      {
        params: {
          account: vendorAccount2,
          markup: 0.5,
          staking: 5,
          mocAmount: 10000,
          mintAmount: 0,
          removeStakeMessage: 'WHEN a vendor cannot remove staking THEN revert is expected'
        },
        expect: {
          totalPaidInMoC: 0,
          paidMoC: 0,
          paidRBTC: 0,
          staking: 5
        }
      }
    ];

    scenarios.forEach(async scenario => {
      let registerVendorTx;
      let addStakeTx;
      let removeStakeTx;
      let unregisterVendorTx;
      let vendorInMapping;

      const activeVendorCount = 1;
      const inactiveVendorCount = 0;

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
      it(`WHEN a vendor adds staking of ${scenario.params.staking} THEN VendorStakeAdded event is emitted`, async function() {
        addStakeTx = await this.mocVendors.addStake(
          toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
          { from: scenario.params.account }
        );

        const [vendorStakeAddedEvent] = await mocHelper.findEvents(addStakeTx, 'VendorStakeAdded');

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
      });
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
      it('WHEN retrieving vendor count, THEN it returns the correct amount of active vendors', async function() {
        const vendorCount = await this.mocVendors.getVendorsCount();

        console.log('vendorCount: ', vendorCount);
        console.log('vendorCount toString: ', vendorCount.toString());

        for (let i = 0; i < vendorCount; i++) {
          console.log(i, this.mocVendors.vendorsList[i]);
        }

        mocHelper.assertBig(vendorCount, activeVendorCount, 'Active vendor count is incorrect');
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
            assert(
              err.reason === 'Vendor total paid is not enough',
              `Vendor ${scenario.params.account} should not be able to remove staking`
            );
          }
        }
      );
      it('GIVEN there are not enough MoCs in system, WHEN a vendor tries to remove staking THEN expect revert', async function() {
        // Set allowance to 0
        await mocHelper.approveMoCToken(this.mocVendors.address, 0, scenario.params.account);

        removeStakeTx = this.mocVendors.removeStake(
          toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
          { from: scenario.params.account }
        );

        await expectRevert(removeStakeTx, 'Not enough MoCs in system');
      });
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
      it('WHEN retrieving vendor count after unregistering vendor, THEN it returns the correct amount of active vendors', async function() {
        const vendorCount = await this.mocVendors.getVendorsCount();

        console.log('vendorCount: ', vendorCount);
        console.log('vendorCount toString: ', vendorCount.toString());

        for (let i = 0; i < vendorCount; i++) {
          console.log(i, this.mocVendors.vendorsList[i]);
        }

        mocHelper.assertBig(vendorCount, inactiveVendorCount, 'Active vendor count is incorrect');
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
  describe.only('GIVEN an unauthorized account tries to make changes', function() {
    it('WHEN an unauthorized account tries to register a vendor THEN an error should be raised', async function() {
      try {
        await this.mocVendors.registerVendor(
          vendorAccount3,
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
        await this.mocVendors.unregisterVendor(vendorAccount3, {
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
  describe.only('GIVEN an inexistent vendor tries to makes changes', function() {
    it('WHEN an inexistent vendor tries to add staking THEN an error should be raised', async function() {
      const addStakeTx = this.mocVendors.addStake(
        toContractBN(10 * mocHelper.MOC_PRECISION),
        { from: inexistentVendorAccount }
      );

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
  describe.only('GIVEN a vendor with zero address is invalid', function() {
    it('WHEN trying to register a vendor with zero address THEN an error should be raised', async function() {
      const vendorToRegister = {
        account: ZERO_ADDRESS,
        markup: toContract(10 * mocHelper.MOC_PRECISION).toString()
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
  describe.only('GIVEN vendors can be registered and unregistered via an array in changer contract', function() {
    let vendorsToRegister;
    let vendorsToUnregister;

    before(async function() {
      for (let i = 0; i <= 100; i++) {
        const account = web3.utils.randomHex(20);
        vendorsToRegister.push({
          account,
          markup: toContract(i * mocHelper.MOC_PRECISION).toString()
        });
        vendorsToUnregister.push(account);
      }

      await this.mockMoCVendorsChanger.setVendorsToRegister(vendorsToRegister);
      await this.mockMoCVendorsChanger.setVendorsToUnregister(vendorsToUnregister);

      await this.governor.executeChange(this.mockMoCVendorsChanger.address);
    });
    it('WHEN registering more vendors than allowed THEN an error should be raised', async function() {
      vendorsToRegister.push({
        account: web3.utils.randomHex(20),
        markup: toContract(101 * mocHelper.MOC_PRECISION).toString()
      });

      await this.mockMoCVendorsChanger.setVendorsToRegister(vendorsToRegister);

      const registerVendorTx = await this.governor.executeChange(
        this.mockMoCVendorsChanger.address
      );

      await expectRevert(registerVendorTx, 'vendorsToRegister length must be between 1 and 100');
    });
    it('WHEN unregistering more vendors than allowed THEN an error should be raised', async function() {
      vendorsToUnregister.push(web3.utils.randomHex(20));

      await this.mockMoCVendorsChanger.setVendorsToUnregister(vendorsToRegister);

      const unregisterVendorTx = await this.governor.executeChange(
        this.mockMoCVendorsChanger.address
      );

      await expectRevert(unregisterVendorTx, 'vendorsToRegister length must be between 1 and 100');
    });
  });
});
