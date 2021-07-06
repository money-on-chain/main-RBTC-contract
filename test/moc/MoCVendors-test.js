const { BigNumber } = require('bignumber.js');
const { assert } = require('chai');
const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;

const NOT_AUTHORIZED_CHANGER = 'not_authorized_changer';
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

contract('MoC: MoCVendors', function([
  owner,
  userAccount,
  commissionsAccount,
  inexistentVendorAccount,
  vendorAccount1,
  vendorAccount2,
  vendorAccount3,
  vendorAccount4,
  vendorAccount5,
  vendorAccount6,
  unauthorizedAccount,
  newVendorGuardianAccount,
  ...accounts
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

    await mocHelper.revertState();
  });
  describe('GIVEN vendors can integrate their platforms with MoC protocol', function() {
    const scenarios = [
      // Vendor 1
      {
        params: {
          description: 'Staking is bigger than totalPaidInMoc',
          account: vendorAccount1,
          markup: 0.01,
          staking: 1,
          mocAmount: 10000,
          mintAmount: 10,
          addStakeMessage:
            'WHEN a vendor adds staking of $STAKING$ THEN VendorStakeAdded event is emitted',
          removeStakeMessage:
            'WHEN a vendor removes staking equal to totalPaidInMoc THEN VendorStakeRemoved event is emitted',
          userAccountMocAmount: 0
        },
        expect: {
          totalPaidInMoC: 0.1,
          paidMoC: 0,
          paidRBTC: 0.1,
          stakingAfterAddStake: 1,
          stakingAfterRemoveStake: 0,
          stakingRemoved: 1
        }
      },
      // Vendor 2
      {
        params: {
          description: 'totalPaidInMoc is 0',
          account: vendorAccount2,
          markup: 0.005,
          staking: 0.5,
          mocAmount: 10000,
          mintAmount: 0,
          addStakeMessage:
            'WHEN a vendor adds staking of $STAKING$ THEN VendorStakeAdded event is emitted',
          removeStakeMessage:
            'WHEN a vendor removes staking and totalPaidInMoc is 0 THEN VendorStakeRemoved event is emitted',
          userAccountMocAmount: 0
        },
        expect: {
          totalPaidInMoC: 0,
          paidMoC: 0,
          paidRBTC: 0,
          stakingAfterAddStake: 0.5,
          stakingAfterRemoveStake: 0,
          stakingRemoved: 0.5
        }
      },
      // Vendor 3
      {
        params: {
          description: 'Vendor received commissions in MoC token',
          account: vendorAccount3,
          markup: 0.01,
          staking: 1,
          mocAmount: 10000,
          mintAmount: 10,
          addStakeMessage:
            'WHEN a vendor adds staking and user paid in MoC THEN VendorStakeAdded event is emitted',
          removeStakeMessage:
            'WHEN a vendor removes staking of $STAKING$ THEN VendorStakeRemoved event is emitted',
          userAccountMocAmount: 10000
        },
        expect: {
          totalPaidInMoC: 0.1,
          paidMoC: 0.1,
          paidRBTC: 0,
          stakingAfterAddStake: 1,
          stakingAfterRemoveStake: 0,
          stakingRemoved: 1
        }
      }
    ];

    scenarios.forEach(function(scenario) {
      let registerVendorTx;
      let addStakeTx;
      let removeStakeTx;
      let unregisterVendorTx;
      let vendorInMapping;

      before(async function() {
        // Register vendor for test
        registerVendorTx = await mocHelper.registerVendor(
          scenario.params.account,
          scenario.params.markup,
          owner
        );

        // Mint and approve MoC token to use in the rest of the functions
        await mocHelper.mintMoCToken(scenario.params.account, scenario.params.mocAmount, owner);
        await mocHelper.approveMoCToken(
          this.mocVendors.address,
          scenario.params.mocAmount,
          scenario.params.account
        );
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
          addStakeTx = await this.mocVendors.addStake(
            toContractBN(scenario.params.staking, 'MOC'),
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
            scenario.expect.stakingAfterAddStake,
            'Should increase by staking'
          );
        }
      );
      it(`On scenario: ${scenario.params.description} WHEN a user mints ${scenario.params.mintAmount} BPRO THEN the vendor receives his corresponding fee and VendorReceivedMarkup event is emitted`, async function() {
        await mocHelper.mintMoCToken(userAccount, scenario.params.userAccountMocAmount, owner);
        await mocHelper.approveMoCToken(
          this.moc.address,
          scenario.params.userAccountMocAmount,
          userAccount
        );

        // Make a transaction so that the vendor has something to remove from staking
        const tx = await mocHelper.mintBProAmount(
          userAccount,
          scenario.params.mintAmount,
          scenario.params.account
        );

        const totalPaidInMoC = await this.mocVendors.getTotalPaidInMoC(scenario.params.account);
        if (scenario.params.mintAmount > 0) {
          const [vendorReceivedMarkupEvent] = await mocHelper.findEvents(
            tx,
            'VendorReceivedMarkup'
          );
          const { paidRBTC, paidMoC } = vendorReceivedMarkupEvent;
          mocHelper.assertBigRBTC(paidMoC, scenario.expect.paidMoC, 'paidMoC is incorrect');
          mocHelper.assertBigRBTC(paidRBTC, scenario.expect.paidRBTC, 'paidRBTC is incorrect');
        }

        mocHelper.assertBigRBTC(
          totalPaidInMoC,
          scenario.expect.totalPaidInMoC,
          'totalPaidInMoC is incorrect'
        );
      });
      it('WHEN retrieving vendor from getters, THEN it matches the information from mapping', async function() {
        vendorInMapping = await this.mocVendors.vendors(scenario.params.account);

        const isActive = await this.mocVendors.getIsActive(scenario.params.account);
        const markup = await this.mocVendors.getMarkup(scenario.params.account);
        const totalPaidInMoC = await this.mocVendors.getTotalPaidInMoC(scenario.params.account);
        const staking = await this.mocVendors.getStaking(scenario.params.account);

        assert(vendorInMapping.isActive === isActive, 'isActive is incorrect');
        mocHelper.assertBig(vendorInMapping.markup, markup, 'markup is incorrect');
        mocHelper.assertBig(
          vendorInMapping.totalPaidInMoC,
          totalPaidInMoC,
          'totalPaidInMoC is incorrect'
        );
        mocHelper.assertBig(vendorInMapping.staking, staking, 'staking is incorrect');
      });
      it(
        scenario.params.removeStakeMessage.replace('$STAKING$', scenario.params.staking),
        async function() {
          removeStakeTx = await this.mocVendors.removeStake(
            toContractBN(scenario.params.staking, 'MOC'),
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
            scenario.expect.stakingRemoved,
            'VendorStakeRemoved event emitted an invalid value'
          );
          const staking = await this.mocVendors.getStaking(scenario.params.account);
          mocHelper.assertBigRBTC(
            staking,
            scenario.expect.stakingAfterRemoveStake,
            'Staking in storage is invalid'
          );
        }
      );
      it('WHEN a vendor is unregistered THEN VendorUnregistered event is emitted', async function() {
        unregisterVendorTx = await this.mocVendors.unregisterVendor(scenario.params.account, {
          from: owner
        });

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
          addStakeTx = this.mocVendors.addStake(toContractBN(scenario.params.staking, 'MOC'), {
            from: scenario.params.account
          });

          await expectRevert(addStakeTx, 'Vendor is inexistent or inactive');
        });
        it('WHEN an inactive vendor tries to remove staking THEN an error should be raised', async function() {
          removeStakeTx = this.mocVendors.removeStake(
            toContractBN(scenario.params.staking, 'MOC'),
            { from: scenario.params.account }
          );

          await expectRevert(removeStakeTx, 'Vendor is inexistent or inactive');
        });
      });
    });
  });

  describe('GIVEN a registered vendor with enough MoC tokens', function() {
    before(async function() {
      // Register vendor for test
      await mocHelper.registerVendor(vendorAccount1, 0.001, owner);
      count = await this.mocVendors.getVendorsCount();

      // Mint and approve MoC token to use in the rest of the functions
      await mocHelper.mintMoCToken(vendorAccount1, 100, owner);
      await mocHelper.approveMoCToken(this.mocVendors.address, 10, vendorAccount1);
    });
    it('WHEN vendor tries to add staking 0 THEN an error should be raised', async function() {
      const addStakeTx = this.mocVendors.addStake(toContractBN(0, 'MOC'), {
        from: vendorAccount1
      });
      await expectRevert(addStakeTx, 'Staking should be greater than 0');
    });
    it('WHEN vendor tries to add more staking than what is approved THEN an error should be raised', async function() {
      const addStakeTx = this.mocVendors.addStake(toContractBN(20, 'MOC'), {
        from: vendorAccount1
      });

      await expectRevert(addStakeTx, 'MoC balance or MoC allowance are not enough to add staking');
    });
    it('WHEN vendor tries to remove 0 stake THEN an error should be raised', async function() {
      await this.mocVendors.addStake(toContractBN(10, 'MOC'), {
        from: vendorAccount1
      });
      const removeStakeTx = this.mocVendors.addStake(toContractBN(0, 'MOC'), {
        from: vendorAccount1
      });
      await expectRevert(removeStakeTx, 'Staking should be greater than 0');
    });
  });

  describe('Non-scenario tests', function() {
    beforeEach(async function() {
      await mocHelper.revertState();
    });
    describe('GIVEN an inexistent vendor tries to makes changes', function() {
      it('WHEN an inexistent vendor tries to add staking THEN an error should be raised', async function() {
        const addStakeTx = this.mocVendors.addStake(toContractBN(10, 'MOC'), {
          from: inexistentVendorAccount
        });

        await expectRevert(addStakeTx, 'Vendor is inexistent or inactive');
      });
      it('WHEN an inexistent vendor tries to remove staking THEN an error should be raised', async function() {
        const removeStakeTx = this.mocVendors.removeStake(toContractBN(10, 'MOC'), {
          from: inexistentVendorAccount
        });

        await expectRevert(removeStakeTx, 'Vendor is inexistent or inactive');
      });
    });
    describe('GIVEN there is a maximum markup that can be assigned to a vendor', function() {
      it('WHEN trying to register a vendor with an invalid value THEN an error should be raised', async function() {
        const registerVendorTx = mocHelper.registerVendor(vendorAccount4, 10, owner);

        await expectRevert(registerVendorTx, 'Vendor markup threshold exceeded');
      });
    });
    describe('GIVEN vendors can be registered and unregistered', function() {
      it('WHEN registering and unregistering vendors THEN the correct amount of registered vendors is retrieved', async function() {
        await mocHelper.registerVendor(vendorAccount1, 0.001, owner);
        await mocHelper.registerVendor(vendorAccount2, 0.002, owner);
        await mocHelper.registerVendor(vendorAccount3, 0.003, owner);

        let vendorCount;
        let activeVendorCount = 3;
        let unregisterVendorTx;

        vendorCount = await this.mocVendors.getVendorsCount();
        mocHelper.assertBig(vendorCount, activeVendorCount, 'Active vendor count is incorrect');

        // Unregister vendorAccount3
        unregisterVendorTx = await this.mocVendors.unregisterVendor(vendorAccount3, {
          from: owner
        });
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
        unregisterVendorTx = await this.mocVendors.unregisterVendor(vendorAccount2, {
          from: owner
        });
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
        unregisterVendorTx = await this.mocVendors.unregisterVendor(vendorAccount1, {
          from: owner
        });
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
    describe('GIVEN there is a guardian address for certain functions that can be changed', function() {
      let changeGuardianTx;
      let registerVendorTx;

      before(async function() {
        // Change guardian address
        await this.mockMoCVendorsChanger.setVendorGuardianAddress(newVendorGuardianAccount);
        changeGuardianTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
        registerVendorTx = await mocHelper.registerVendor(
          vendorAccount6,
          0.001,
          newVendorGuardianAccount
        );
      });
      it('WHEN changing this address THEN it should be changed correctly', async function() {
        const [vendorGuardianAddressChangedEvent] = await mocHelper.findEvents(
          changeGuardianTx,
          'VendorGuardianAddressChanged'
        );
        assert(
          vendorGuardianAddressChangedEvent.vendorGuardianAddress === newVendorGuardianAccount,
          'New address is different'
        );
      });
      it('WHEN executing a function using this new address THEN it should execute correctly', async function() {
        const [vendorRegisteredEvent] = await mocHelper.findEvents(
          registerVendorTx,
          'VendorRegistered'
        );

        assert(vendorRegisteredEvent, 'Event was not emitted');
        assert(vendorRegisteredEvent.account === vendorAccount6, 'Vendor account is incorrect');
      });
    });
    describe('GIVEN vendors can be registered and unregistered via guardian address', function() {
      it('WHEN registering more vendors than allowed THEN an error should be raised', async function() {
        let account;
        let index = 0;
        /* eslint-disable no-await-in-loop */
        // 20 batches of 5 vendors at a time because of out-of-gas errors
        for (let i = 0; i < 20; i++) {
          for (let j = 0; j < 5; j++) {
            index++;
            account = accounts[index]; // accounts must be different
            await mocHelper.registerVendor(account, index / 100000, owner);
          }
        }
        /* eslint-enable no-await-in-loop */

        // Add a new vendor - should not be possible
        const registerVendorTx = mocHelper.registerVendor(accounts[index + 1], 0.001, owner);

        await expectRevert(registerVendorTx, 'vendorsList length out of range');
      });
      it('WHEN an unauthorized account wants to register a vendor THEN an error should be raised', async function() {
        const registerVendorTx = mocHelper.registerVendor(
          vendorAccount5,
          0.001,
          unauthorizedAccount
        );

        await expectRevert(registerVendorTx, 'Caller is not vendor guardian address');
      });
      it('WHEN an unauthorized account wants to unregister a vendor THEN an error should be raised', async function() {
        const unregisterVendorTx = this.mocVendors.unregisterVendor(vendorAccount5, {
          from: unauthorizedAccount
        });

        await expectRevert(unregisterVendorTx, 'Caller is not vendor guardian address');
      });
    });
    describe('GIVEN vendors get their amount paid in MoC reset every time settlement is run', function() {
      it('WHEN settlement runs, then totalPaidInMoC is 0', async function() {
        // Register vendor for test
        await mocHelper.registerVendor(vendorAccount5, 0.01, owner);

        const mocAmount = 1000;
        await mocHelper.mintMoCToken(vendorAccount5, mocAmount, owner);
        await mocHelper.approveMoCToken(this.mocVendors.address, mocAmount, vendorAccount5);

        // Add staking
        await this.mocVendors.addStake(toContractBN(mocAmount, 'MOC'), {
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
    describe('GIVEN the vendor markup can be changed', function() {
      it('WHEN registering said vendor with a different markup value THEN VendorUpdated event is emitted', async function() {
        // Register vendor
        await mocHelper.registerVendor(vendorAccount1, 0.001, owner);

        // Update markup
        const newMarkup = 0.005;

        // Update vendor markup
        const updateVendorTx = await this.mocVendors.registerVendor(
          vendorAccount1,
          toContractBN(newMarkup, 'MOC'),
          { from: owner }
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
    describe('GIVEN settlement runs', function() {
      it('WHEN iterating over 100 active vendors THEN amount paid in MoC is reset for each vendor', async function() {
        let account;
        let index = 0;
        const mocAmount = 1000;
        const blockGasLimit = 6000000;

        // Register vendors and set up values for test
        /* eslint-disable no-await-in-loop */
        // 20 batches of 5 vendors at a time because of out-of-gas errors
        for (let i = 0; i < 20; i++) {
          for (let j = 0; j < 5; j++) {
            index++;
            account = accounts[index]; // accounts must be different
            await mocHelper.registerVendor(account, index / 100000, owner);

            // Mint MoC token
            await mocHelper.mintMoCToken(account, mocAmount, owner);
            await mocHelper.approveMoCToken(this.mocVendors.address, mocAmount, account);

            // Add staking
            await this.mocVendors.addStake(toContractBN(mocAmount, 'MOC'), {
              from: account
            });

            // Mint BPRO
            await mocHelper.mintBProAmount(
              userAccount,
              1000,
              account,
              await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
            );
          }
        }
        /* eslint-enable no-await-in-loop */

        // Enabling Settlement
        await this.mocSettlement.setBlockSpan(1);
        const settlementTx = await mocHelper.executeSettlement();
        const receipt = await web3.eth.getTransactionReceipt(settlementTx.tx);

        assert(receipt.cumulativeGasUsed <= blockGasLimit, 'Block gas limit reached');
      });
    });
    describe('GIVEN 100 active vendors are registered', function() {
      it('WHEN one of them changes their markup THEN it updates', async function() {
        let account;
        let index = 0;
        let markup = 0;

        // Register vendors and set up values for test
        /* eslint-disable no-await-in-loop */
        // 20 batches of 5 vendors at a time because of out-of-gas errors
        for (let i = 0; i < 20; i++) {
          for (let j = 0; j < 5; j++) {
            index++;
            account = accounts[index]; // accounts must be different
            markup = index / 100000;
            await mocHelper.registerVendor(account, markup, owner);
          }
        }
        /* eslint-enable no-await-in-loop */

        // The last vendor wants to change their markup
        const newMarkup = 0.002; // arbitrary number
        const updateVendorTx = await mocHelper.registerVendor(account, newMarkup, owner);

        // Find transaction event
        const [vendorUpdatedEvent] = await mocHelper.findEvents(updateVendorTx, 'VendorUpdated');

        mocHelper.assertBig(
          toContractBN(newMarkup, 'MOC').toString(),
          vendorUpdatedEvent.markup,
          `New vendor markup should be ${newMarkup}`
        );
      });
    });
  });

  describe('MoCVendors settings params', function() {
    const scenario = {
      vendorGuardianAddress: inexistentVendorAccount // Any address will do
    };
    describe('GIVEN the default vendorGuardianAddress', function() {
      let tx;

      it(`THEN an unauthorized account ${unauthorizedAccount} tries to change vendorGuardianAddress to ${scenario.vendorGuardianAddress}`, async function() {
        try {
          await this.mocVendors.setVendorGuardianAddress(scenario.vendorGuardianAddress, {
            from: unauthorizedAccount
          });
        } catch (err) {
          assert(
            NOT_AUTHORIZED_CHANGER === err.reason,
            `${unauthorizedAccount} Should not be authorized to set vendorGuardianAddress`
          );
        }
      });
      it('THEN an authorized account proposes to change vendorGuardianAddress to zero address', async function() {
        const proposeChangeAddressTx = this.mockMoCVendorsChanger.setVendorGuardianAddress(
          ZERO_ADDRESS
        );
        await expectRevert(proposeChangeAddressTx, 'vendorGuardianAddress must not be 0x0');
      });
      it(`THEN an authorized contract tries to change vendorGuardianAddress to ${scenario.vendorGuardianAddress}`, async function() {
        await this.mockMoCVendorsChanger.setVendorGuardianAddress(scenario.vendorGuardianAddress);
        tx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
        const newVendorGuardianAddress = await this.mocVendors.getVendorGuardianAddress();

        assert(
          newVendorGuardianAddress === scenario.vendorGuardianAddress,
          `vendorGuardianAddress should be ${scenario.vendorGuardianAddress}`
        );
      });
      it('THEN VendorGuardianAddress event is emitted', async function() {
        const [vendorGuardianAddressChangedEvent] = await mocHelper.findEvents(
          tx,
          'VendorGuardianAddressChanged'
        );
        assert(
          vendorGuardianAddressChangedEvent.vendorGuardianAddress ===
            scenario.vendorGuardianAddress,
          'New address is different'
        );
      });
    });
  });
});
