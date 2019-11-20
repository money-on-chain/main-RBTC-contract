const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

const BUCKET_NOT_AVAILABLE = 'Bucket is not available';
const NOT_BUCKET_BASE = 'Bucket should not be a base type bucket';
const bucketH8 = web3.utils.asciiToHex('H8', 32);
const bucketC0 = web3.utils.asciiToHex('C0', 32);
let mocHelper;
let toContractBN;
let BUCKET_X2;
let BUCKET_C0;
contract('MoCBucketContainer', function([owner, account2]) {
  const c0Cobj = 3;
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.mocState = mocHelper.mocState;
    this.moc = mocHelper.moc;
    this.bprox = mocHelper.bprox;
    ({ BUCKET_C0, BUCKET_X2 } = mocHelper);
  });

  beforeEach(function() {
    return mocHelper.revertState();
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
        await mocHelper.mintBProAmount(owner, 100);
        await mocHelper.mintDocAmount(account2, 10000);
      });
      it('THEN mintBProx must revert', async function() {
        await expectRevert(mocHelper.mintBProx(account2, bucketC0, 1), NOT_BUCKET_BASE);
      });
      it('THEN redeemBProx must revert', async function() {
        await expectRevert(
          this.moc.redeemBProx(bucketC0, toContractBN(0.5 * mocHelper.RESERVE_PRECISION)),
          NOT_BUCKET_BASE
        );
      });
      it('THEN evalBucketLiquidation must revert', async function() {
        await expectRevert(this.moc.evalBucketLiquidation(bucketC0), NOT_BUCKET_BASE);
      });
    });
    describe('AND the bucket H8 does not exists', function() {
      it('THEN mintBProx must revert', async function() {
        await expectRevert(mocHelper.mintBProx(account2, bucketH8, 1), BUCKET_NOT_AVAILABLE);
      });
      it('THEN redeemBProx must revert', async function() {
        await expectRevert(
          this.moc.redeemBProx(bucketH8, toContractBN(0.5 * mocHelper.RESERVE_PRECISION)),
          BUCKET_NOT_AVAILABLE
        );
      });
      it('THEN evalBucketLiquidation must revert', async function() {
        await expectRevert(this.moc.evalBucketLiquidation(bucketH8), BUCKET_NOT_AVAILABLE);
      });
    });
  });
});
