const testHelperBuilder = require('../mocHelper.js');

let mocHelper;

let BUCKET_X2;
let toContractBN;
let BUCKET_C0;
contract('MoCBucketContainer', function([owner]) {
  const c0CobjInitial = 3;
  const x2CobjInitial = 2;
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.mocState = mocHelper.mocState;
    this.governor = mocHelper.governor;
    this.moc = mocHelper.moc;
    this.bprox = mocHelper.bprox;
    this.mockMoCBucketContainerChanger = mocHelper.mockMoCBucketContainerChanger;
    ({ BUCKET_C0, BUCKET_X2 } = mocHelper);
  });

  describe('GIVEN the Moc contract was created', function() {
    const newC0Cobj = c0CobjInitial + 1;
    const newX2Cobj = x2CobjInitial + 1;

    it(`THEN it exists a C0 bucket with Cobj ${c0CobjInitial}`, async function() {
      const actualC0Cobj = await this.mocState.getBucketCobj(BUCKET_C0);
      mocHelper.assertBigCb(actualC0Cobj, c0CobjInitial, 'Incorrect C0 coverage');
    });
    it(`THEN it exists a X2 bucket with Cobj ${x2CobjInitial}`, async function() {
      const actualX2Cobj = await this.mocState.getBucketCobj(BUCKET_X2);
      mocHelper.assertBigCb(actualX2Cobj, x2CobjInitial, 'Incorrect X2 coverage');
    });

    describe('WHEN the the coverage is tried to be changed through governance', function() {
      before(async function() {
        await this.mockMoCBucketContainerChanger.setCobjBucketC0(
          toContractBN(newC0Cobj * mocHelper.MOC_PRECISION),
          { from: owner }
        );
        await this.mockMoCBucketContainerChanger.setCobjBucketX2(
          toContractBN(newX2Cobj * mocHelper.MOC_PRECISION),
          { from: owner }
        );
        await this.governor.executeChange(this.mockMoCBucketContainerChanger.address, {
          from: owner
        });
      });
      it(`THEN the coverage of C0 bucket changed to ${newC0Cobj}`, async function() {
        const actualC0Cobj = await this.mocState.getBucketCobj(BUCKET_C0);
        mocHelper.assertBigCb(actualC0Cobj, newC0Cobj, 'Incorrect C0 coverage');
      });
      it(`THEN the coverage of X2 bucket changed to ${newX2Cobj}`, async function() {
        const actualX2Cobj = await this.mocState.getBucketCobj(BUCKET_X2);
        mocHelper.assertBigCb(actualX2Cobj, newX2Cobj, 'Incorrect X2 coverage');
      });
    });
  });
});
