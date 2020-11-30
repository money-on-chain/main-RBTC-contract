const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;

const scenario = {
  params: {
    markup: 1000,
    staking: 500,
    totalPaidInMoC: 1000,
    mocAmount: 10000
  },
  expect: {
    staking: 500
  }
};

contract('MoC: MoCVendors', function([owner, unauthorizedAccount, nonExistentVendorAccount, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.governor = mocHelper.governor;
    this.mocVendors = mocHelper.mocVendors;
    this.mockMoCVendorsChanger = mocHelper.mockMoCVendorsChanger;
  });
  beforeEach(async function() {
    //await mocHelper.revertState();
  });
  describe.only('GIVEN vendors can integrate their platforms with MoC protocol', function() {
    let registerVendorTx;
    let addStakeTx;
    let removeStakeTx;
    let unregisterVendorTx;

    let vendor_in_mapping;

    before(async function() {
      await mocHelper.revertState();

      await mocHelper.mintMoCToken(vendorAccount, scenario.params.mocAmount, owner);
      await mocHelper.approveMoCToken(
        this.mocVendors.address,
        scenario.params.mocAmount,
        vendorAccount
      );

      // Vendors for test are set in functionHelper.js
      await this.mockMoCVendorsChanger.setVendorsToRegister(
        await mocHelper.getVendorsToRegisterArray()
      );
      //registerVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
      registerVendorTx = await this.governor.contract.methods.executeChange(this.mockMoCVendorsChanger.address).call();
    });
    it('WHEN a vendor is registered THEN VendorRegistered event is emitted', async function() {
      const [vendorRegisteredEvent] = await mocHelper.findEvents(
        registerVendorTx,
        'VendorRegistered'
      );

      assert(vendorRegisteredEvent, 'Event was not emitted');
      assert(vendorRegisteredEvent.account === vendorAccount, 'Vendor account is incorrect');
    });
    it('WHEN a vendor adds staking THEN VendorStakeAdded event is emitted', async function() {
      addStakeTx = await this.mocVendors.addStake(
        toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
        { from: vendorAccount }
      );

      const [vendorStakeAddedEvent] = await mocHelper.findEvents(addStakeTx, 'VendorStakeAdded');

      assert(vendorStakeAddedEvent, 'Event was not emitted');
      assert(vendorStakeAddedEvent.account === vendorAccount, 'Vendor account is incorrect');
      mocHelper.assertBigRBTC(
        vendorStakeAddedEvent.staking,
        scenario.expect.staking,
        'Should increase by staking'
      );
    });
    it('WHEN a vendor removes staking THEN VendorStakeRemoved event is emitted', async function() {

      vendor_in_mapping = await this.mocVendors.vendors(vendorAccount);
      console.log(vendor_in_mapping);

      removeStakeTx = await this.mocVendors.removeStake(
        toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
        { from: vendorAccount }
      );

      const [vendorStakeRemovedEvent] = await mocHelper.findEvents(
        removeStakeTx,
        'VendorStakeRemoved'
      );

      console.log("vendorStakeRemovedEvent: ", vendorStakeRemovedEvent);

      assert(vendorStakeRemovedEvent, 'Event was not emitted');
      assert(vendorStakeRemovedEvent.account === vendorAccount, 'Vendor account is incorrect');
      mocHelper.assertBigRBTC(
        vendorStakeRemovedEvent.staking,
        scenario.expect.staking,
        'Should decrease by staking'
      );
    });
    before(async function() {
      // Vendors for test are set in functionHelper.js
      await this.mockMoCVendorsChanger.setVendorsToUnregister(
        await mocHelper.getVendorsToUnregisterArray()
      );
      unregisterVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
    });
    it('WHEN a vendor is unregistered THEN VendorUnregistered event is emitted', async function() {
      const [vendorUnregisteredEvent] = await mocHelper.findEvents(
        unregisterVendorTx,
        'VendorUnregistered'
      );

      assert(vendorUnregisteredEvent, 'Event was not emitted');
      assert(vendorUnregisteredEvent.account === vendorAccount, 'Vendor account is incorrect');
    });
    // Unauthorized account
    describe('GIVEN an unauthorized account tries to make changes', function() {

      before(async function() {
        unregisterVendorTx = await this.mocVendors.unregisterVendor(vendorAccount, { from: unauthorizedAccount });
      });
      it('WHEN an unauthorized account tries to unregister a vendor THEN an error should be raised', async function() {
        const [vendorUnregisteredEvent] = await mocHelper.findEvents(
          unregisterVendorTx,
          'VendorUnregistered'
        );

        // change to catch error

        assert(vendorUnregisteredEvent, 'Event was not emitted');
        assert(vendorUnregisteredEvent.account === vendorAccount, 'Vendor account is incorrect');
      });
    });
  });
});
