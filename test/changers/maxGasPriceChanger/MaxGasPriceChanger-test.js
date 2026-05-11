const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;

contract('MoC: MaxGasPriceChanger', function([owner]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    this.moc = mocHelper.moc;
  });

  describe('GIVEN latest MoC implementation with maxGasPrice configured', function() {
    it('THEN transaction reverts when user mints BPro with gas price higher than the limit', async function() {
      const tx = mocHelper.moc.mintBPro(1000, {
        from: owner,
        value: 1000,
        gasPrice: '21000000001'
      });
      await expectRevert(tx, 'gas price is above the max allowed');
    });
  });
});
