const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;

const scenario = {
  params: {
    vendorAccount: '0x9a59f2fb619f192bd10f65cb4d96c7ecd55f9ce0',
    markup: 1000,
    staking: 500
  },
  expect: {
    isActive: true
  }
};

contract('MoC: MoCVendors', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.governor = mocHelper.governor;
    this.mocVendors = mocHelper.mocVendors;
  });
  beforeEach(async function() {
    await mocHelper.revertState();
  });
  describe.only('GIVEN vendors can integrate their platforms with MoC protocol', function() {
    let registerVendor;
    let vendorDetails;
    let registerVendorTx;
    let addStakeTx;
    let removeStakeTx;
    let vendor_in_mapping;

    before(async function() {
      registerVendorTx = await this.mocVendors.registerVendor(
        scenario.params.vendorAccount,
        scenario.params.markup
      );

        vendor_in_mapping = await this.mocVendors.vendors(scenario.params.vendorAccount);
      //mocHelper.consolePrintTestVariables({ vendor_in_mapping });
      console.log(vendor_in_mapping);

      //vendorDetails = await this.mocVendors.getVendorDetails(scenario.params.vendorAccount);

      // chequear el evento emitido con truffle-assert (buscar en test anteriores)

      // var print = {isActive, vendorDetails};
      // mocHelper.consolePrintTestVariables(print);
      //console.log(isActive);
    });
    it('WHEN a vendor is registered THEN VendorRegistered event is emitted', async function() {
      // assert.equal(isActive, scenario.expect.isActive, 'Vendor does not exist or is inactive');
      // assert.equal(
      //   vendorDetails.maxMoCToRedeem,
      //   scenario.expect.maxMoCToRedeem,
      //   `maxMoCToRedeem should be ${scenario.expect.maxMoCToRedeem}`
      // );
      vendor_in_mapping = await this.mocVendors.vendors(scenario.params.vendorAccount);
      //mocHelper.consolePrintTestVariables({ vendor_in_mapping });
      console.log(vendor_in_mapping);

      const [vendorRegisteredEvent] = await mocHelper.findEvents(registerVendorTx, 'VendorRegistered');

      console.log(vendorRegisteredEvent);

      assert(registerVendorTx, 'Event was not emitted');
      //assert.equal(isActive, scenario.expect.isActive, 'Vendor does not exist or is inactive');
    });
    it('WHEN a vendor adds staking THEN VendorStakeAdded event is emitted', async function() {
      // assert.equal(isActive, scenario.expect.isActive, 'Vendor does not exist or is inactive');
      // assert.equal(
      //   vendorDetails.maxMoCToRedeem,
      //   scenario.expect.maxMoCToRedeem,
      //   `maxMoCToRedeem should be ${scenario.expect.maxMoCToRedeem}`
      // );
      vendor_in_mapping = await this.mocVendors.vendors(scenario.params.vendorAccount);
      //mocHelper.consolePrintTestVariables({ vendor_in_mapping });
      console.log(vendor_in_mapping);

      addStakeTx = await this.mocVendors.addStake(
        scenario.params.staking,
        { from: scenario.params.vendorAccount }
      );



      const [vendorStakeAddedEvent] = await mocHelper.findEvents(addStakeTx, 'VendorStakeAdded');

      console.log(vendorStakeAddedEvent);

      assert(addStakeTx, 'Event was not emitted');
      //assert.equal(isActive, scenario.expect.isActive, 'Vendor does not exist or is inactive');
    });
    it('WHEN a vendor removes staking THEN VendorStakeRemoved event is emitted', async function() {
      // assert.equal(isActive, scenario.expect.isActive, 'Vendor does not exist or is inactive');
      // assert.equal(
      //   vendorDetails.maxMoCToRedeem,
      //   scenario.expect.maxMoCToRedeem,
      //   `maxMoCToRedeem should be ${scenario.expect.maxMoCToRedeem}`
      // );
      vendor_in_mapping = await this.mocVendors.vendors(scenario.params.vendorAccount);
      //mocHelper.consolePrintTestVariables({ vendor_in_mapping });
      console.log(vendor_in_mapping);

      removeStakeTx = await this.mocVendors.removeStake(
        scenario.params.staking,
        { from: scenario.params.vendorAccount }
      );

      const [vendorStakeRemovedEvent] = await mocHelper.findEvents(removeStakeTx, 'VendorStakeRemoved');

      console.log(vendorStakeRemovedEvent);

      assert(removeStakeTx, 'Event was not emitted');
      //assert.equal(isActive, scenario.expect.isActive, 'Vendor does not exist or is inactive');
    });
  });
});
