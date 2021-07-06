const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;
contract('MoC : BTCx operations does not modify global indicators', function([
  owner,
  userAccount,
  vendorAccount
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    ({ toContractBN } = mocHelper);
    ({ BUCKET_X2 } = mocHelper);
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('GIVEN there are 10 BitPro and 50000 Docs in the system', function() {
    const initialValues = {};
    beforeEach(async function() {
      // Set days to settlement to calculate interests
      await this.mocState.setDaysToSettlement(toContractBN(5, 'DAY'));

      await mocHelper.mintBProAmount(userAccount, 10, vendorAccount);
      await mocHelper.mintDocAmount(userAccount, 50000, vendorAccount);
      initialValues.coverage = await this.mocState.globalCoverage();
      initialValues.maxDoc = await this.mocState.globalMaxDoc();
      initialValues.maxBitPro = await this.mocState.globalMaxBPro();
    });
    describe('WHEN user mints 5 BTC2x', function() {
      beforeEach(async function() {
        await mocHelper.mintBProxAmount(userAccount, BUCKET_X2, 5, vendorAccount);
      });
      it('THEN global indicators should not change', async function() {
        const finalCoverage = await this.mocState.globalCoverage();
        const finalMaxDoc = await this.mocState.globalMaxDoc();
        const finalMaxBitPro = await this.mocState.globalMaxBPro();
        mocHelper.assertBig(initialValues.coverage, finalCoverage, 'Global coverage changed');
        mocHelper.assertBig(initialValues.maxDoc, finalMaxDoc, 'MaxDoc changed');
        mocHelper.assertBig(initialValues.maxBitPro, finalMaxBitPro, 'MaxBitPro changed');
      });
      [1, 3, 5].forEach(redValue => {
        describe(`AND user redeems ${redValue}`, function() {
          beforeEach(async function() {
            await mocHelper.redeemBProx(userAccount, BUCKET_X2, redValue, vendorAccount);
          });
          it('THEN global indicators should not change', async function() {
            const finalCoverage = await this.mocState.globalCoverage();
            const finalMaxDoc = await this.mocState.globalMaxDoc();
            const finalMaxBitPro = await this.mocState.globalMaxBPro();
            mocHelper.assertBig(initialValues.coverage, finalCoverage, 'Global coverage changed');
            mocHelper.assertBig(initialValues.maxDoc, finalMaxDoc, 'MaxDoc changed');
            mocHelper.assertBig(initialValues.maxBitPro, finalMaxBitPro, 'MaxBitPro changed');
          });
        });
      });
    });
  });
});
