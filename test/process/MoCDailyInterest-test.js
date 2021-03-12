const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let BUCKET_X2;
let BUCKET_C0;

contract('MoC: Daily interests payment', function([owner, account, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.governor = mocHelper.governor;
    ({ BUCKET_C0, BUCKET_X2 } = mocHelper);
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  const scenarios = [
    {
      description:
        'There is money in the inrate bag. Daily function should increase C0 bucket RBTCs',
      // Amount of RBTC to use in bprox mint
      nBProx: 1,
      days: 4,
      expect: {
        nB: '0.000130578938033900'
      }
    },
    {
      description: 'There is no money in the inrate bag. C0 buckets keeps the same',
      // Amount of RBTC to use in bprox mint
      nBProx: 0,
      days: 5,
      expect: {
        nB: 0
      }
    },
    {
      description:
        'There is money in the inrate bag. Daily function should pay complete inrateBag amount to C0 bucket',
      // Amount of RBTC to use in bprox mint
      nBProx: 1,
      days: 0,
      expect: {
        nB: '0.000652894690169500'
      }
    }
  ];
  scenarios.forEach(s => {
    let prevBucketC0State;
    let readyState;
    describe('GIVEN there are minted 0.000652468418693048 RBTCs in the C0 interest bag', function() {
      beforeEach(async function() {
        readyState = mocHelper.getContractReadyState(s);
        await this.mocState.setDaysToSettlement(5 * mocHelper.DAY_PRECISION);
        await mocHelper.mintBProAmount(account, 10, vendorAccount);
        await mocHelper.mintDocAmount(account, 10000, vendorAccount);
        if (s.nBProx) {
          await mocHelper.mintBProxAmount(account, BUCKET_X2, s.nBProx, vendorAccount);
        }
        prevBucketC0State = await mocHelper.getBucketState(BUCKET_C0);
      });
      describe('WHEN daily payment is run', function() {
        let tx;
        beforeEach(async function() {
          // Set testing days
          await this.mocState.setDaysToSettlement(readyState.days);
          tx = await this.moc.dailyInratePayment();
        });
        it(`THEN bucket C0 BTCs should increase in ${s.expect.nB}`, async function() {
          const nBtc = await this.mocState.getBucketNBTC(BUCKET_C0);
          const diff = nBtc.sub(prevBucketC0State.nB);
          mocHelper.assertBigRBTC(diff, s.expect.nB, 'Bucket 0 BTCs did not increase');
        });
        it(`THEN interest bag should decrease in ${s.expect.nB}`, async function() {
          const inrateBag = await this.mocState.getInrateBag(BUCKET_C0);
          const diff = prevBucketC0State.inrateBag.sub(inrateBag);
          mocHelper.assertBigRBTC(diff, s.expect.nB, 'interest bag did not decrease');
        });
        it('THEN InrateDailyPay event is emitted and BitPro Bucket0 checked', async function() {
          const [inrateEvent] = await mocHelper.findEvents(tx, 'InrateDailyPay');
          // TODO: review this operation. Why lB?
          const prevBitProBucket0 = prevBucketC0State.nB.sub(prevBucketC0State.lB);
          const bnBitProBucket0 = new web3.utils.BN(inrateEvent.nReserveBucketC0);
          assert(
            bnBitProBucket0.cmp(prevBitProBucket0) >= 0,
            'BitPro Should be greather than prevBitProBucket0'
          );
        });
        it('THEN InrateDailyPay event is emitted', async function() {
          const [inrateEvent] = await mocHelper.findEvents(tx, 'InrateDailyPay');
          mocHelper.assertBigRBTC(inrateEvent.amount, s.expect.nB, `should be ${s.expect.nB}`);
        });
        it('THEN Daily payment should be disabled', async function() {
          const enabled = await this.moc.isDailyEnabled();
          assert(!enabled, 'Daily payment is still enabled');
        });
      });
    });
  });
});
