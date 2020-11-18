const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;

const scenario = {
  params: {
    redeemAddress: '0x9a59f2fb619f192bd10f65cb4d96c7ecd55f9ce0',
    markup: 500,
    maxMoCToRedeem: 1000
  },
  expect: {
    isActive: true,
    maxMoCToRedeem: 1000
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
    let isActive;
    let vendorDetails;

    beforeEach(async function() {
      isActive = await this.mocVendors.registerVendor(
        scenario.params.redeemAddress,
        scenario.params.markup,
        scenario.params.maxMoCToRedeem
      );
      //vendorDetails = await this.mocVendors.getVendorDetails(scenario.params.redeemAddress);

      // chequear el evento emitido con truffle-assert (buscar en test anteriores)

      // var print = {isActive, vendorDetails};
      // mocHelper.consolePrintTestVariables(print);
      console.log(isActive);
    });
    it('WHEN a vendor is registered THEN their details can be retrieved', async function() {
      assert.equal(isActive, scenario.expect.isActive, 'Vendor does not exist or is inactive');
      assert.equal(
        vendorDetails.maxMoCToRedeem,
        scenario.expect.maxMoCToRedeem,
        `maxMoCToRedeem should be ${scenario.expect.maxMoCToRedeem}`
      );
    });
  });
});
