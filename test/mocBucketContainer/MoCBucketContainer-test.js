const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

const BUCKET_NOT_AVAILABLE = 'Bucket is not available';
const NOT_BUCKET_BASE = 'Bucket should not be a base type bucket';
const bucketH8 = web3.utils.asciiToHex('H8', 32);
const bucketC0 = web3.utils.asciiToHex('C0', 32);
let mocHelper;

let BUCKET_X2;
let BUCKET_C0;
contract('MoCBucketContainer', function([owner, account2, vendorAccount]) {
  const c0Cobj = 3;
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    this.mocState = mocHelper.mocState;
    this.moc = mocHelper.moc;
    this.bprox = mocHelper.bprox;
    ({ BUCKET_C0, BUCKET_X2 } = mocHelper);
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('GIVEN the Moc contract was created', function() {
    it(`THEN it exists a C0 bucket with Cobj ${c0Cobj}`, async function() {
      const cobj = await this.mocState.getBucketCobj(BUCKET_C0);
      mocHelper.assertBigCb(cobj, c0Cobj, 'Incorrect C0 coverage');
    });
    it('THEN it exists a X2 bucket with Cobj 2', async function() {
      const cobj = await this.mocState.getBucketCobj(BUCKET_X2);
      mocHelper.assertBigCb(cobj, 2, 'Incorrect X2 coverage');
    });
  });
  describe('GIVEN a user tries to trades BProx', function() {
    describe('AND the bucket C0 is used', function() {
      beforeEach(async function() {
        await mocHelper.mintBProAmount(owner, 100, vendorAccount);
        await mocHelper.mintDocAmount(account2, 10000, vendorAccount);
      });
      it('THEN mintBProx must revert', async function() {
        await expectRevert(
          mocHelper.mintBProx(account2, bucketC0, 1, vendorAccount),
          NOT_BUCKET_BASE
        );
      });
      it('THEN redeemBProx must revert', async function() {
        await expectRevert(
          mocHelper.redeemBProx(account2, bucketC0, 0.5, vendorAccount),
          NOT_BUCKET_BASE
        );
      });
      it('THEN evalBucketLiquidation must revert', async function() {
        await expectRevert(this.moc.evalBucketLiquidation(bucketC0), NOT_BUCKET_BASE);
      });
    });
    describe('AND the bucket H8 does not exists', function() {
      it('THEN mintBProx must revert', async function() {
        await expectRevert(
          mocHelper.mintBProx(account2, bucketH8, 1, vendorAccount),
          BUCKET_NOT_AVAILABLE
        );
      });
      it('THEN redeemBProx must revert', async function() {
        await expectRevert(
          mocHelper.redeemBProx(account2, bucketH8, 0.5, vendorAccount),
          BUCKET_NOT_AVAILABLE
        );
      });
      it('THEN evalBucketLiquidation must revert', async function() {
        await expectRevert(this.moc.evalBucketLiquidation(bucketH8), BUCKET_NOT_AVAILABLE);
      });
    });
  });
});
