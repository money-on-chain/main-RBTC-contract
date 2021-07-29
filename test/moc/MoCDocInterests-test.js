const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;
let BUCKET_C0;

contract('MoC', function([owner, userAccount, userAccount2, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_X2, BUCKET_C0 } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocInrate = mocHelper.mocInrate;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('GIVEN the interest rate for 1 day to settlement is 0.00002611578760678', function() {
    beforeEach(async function() {
      await mocHelper.mintBPro(owner, 10, vendorAccount);
      await mocHelper.mintDoc(userAccount, 10000, vendorAccount); // 10000 Btc = all Docs
      await this.mocState.setDaysToSettlement(toContractBN(1, 'DAY'));
    });

    it('THEN the interest rate for redemption the full redemption is 0.00002611578760678', async function() {
      const inrate = await this.mocInrate.docInrateAvg(toContractBN(10000, 'USD'));

      mocHelper.assertBigRate(inrate, 0.00002611578760678, 'Interest rate is incorrect');
    });

    describe('WHEN days to settlement is 6 AND the user redeems all FreeDoc', function() {
      beforeEach(async function() {
        await this.mocState.setDaysToSettlement(toContractBN(6, 'DAY'));
      });

      it('THEN the interest rate for redemption the full redemption is 0.00002611578760678', async function() {
        const inrate = await this.mocInrate.docInrateAvg(toContractBN(10000, 'USD'));

        mocHelper.assertBigRate(inrate, 0.00002611578760678, 'Interest rate is incorrect');
      });

      it('AND the user redeems all the Free Docs THEN the RBTC interests are 0.000156694725640680 RBTC', async function() {
        const redeemTx = await mocHelper.redeemFreeDoc({
          userAccount,
          docAmount: 10000,
          vendorAccount
        });
        const [freeDocRedeemEvent] = mocHelper.findEvents(redeemTx, 'FreeStableTokenRedeem');
        mocHelper.assertBigRBTC(
          freeDocRedeemEvent.interests,
          0.00015669472564068,
          'Interests are incorrect'
        );
      });
    });
  });

  describe('GIVEN a user mints 10000 Docs and they are all available to redeem AND there are 1 day til next settlement', function() {
    const expectedInRate = '0.000130578938033900'; // 5 * 0,00002611578760678
    let prevNB;
    beforeEach(async function() {
      await mocHelper.mintBPro(owner, 10, vendorAccount);
      ({ nB: prevNB } = await mocHelper.getBucketState(BUCKET_C0));
      await mocHelper.mintDoc(userAccount, 1, vendorAccount); // 1 Btc = 10000 Docs
      await this.mocState.setDaysToSettlement(toContractBN(1, 'DAY'));
    });

    it(`THEN the interest rate for redemption the full redemption is ${expectedInRate}`, async function() {
      const inrate = await this.mocInrate.docInrateAvg(toContractBN(10000, 'USD'));
      mocHelper.assertBigRate(inrate, expectedInRate, 'Interest rate is incorrect');
    });

    describe('WHEN the user redeems all his docs', function() {
      let redeemTx;
      beforeEach(async function() {
        redeemTx = await mocHelper.redeemFreeDoc({ userAccount, docAmount: 10000, vendorAccount });
      });

      it(`THEN the RBTC interests are ${expectedInRate} RBTC`, function() {
        const [freeDocRedeemEvent] = mocHelper.findEvents(redeemTx, 'FreeStableTokenRedeem');
        mocHelper.assertBigRBTC(
          freeDocRedeemEvent.interests,
          expectedInRate,
          'Interests are incorrect'
        );
      });
      it('AND recovered RBTC is 1 RBTC minus those interests', function() {
        const [freeDocRedeemEvent] = mocHelper.findEvents(redeemTx, 'FreeStableTokenRedeem');
        mocHelper.assertBigRBTC(
          freeDocRedeemEvent.reserveTotal,
          '0.999869421061966100',
          'btcTotal is incorrect'
        );
      });
      it('AND inrateBag receives those interest', async function() {
        const { inrateBag } = await mocHelper.getBucketState(BUCKET_C0);
        mocHelper.assertBigRBTC(inrateBag, expectedInRate, 'inrateBag value is incorrect');
      });
      it('AND C0 previous NB is restored as before doc minting', async function() {
        const { nB } = await mocHelper.getBucketState(BUCKET_C0);
        mocHelper.assertBig(nB, prevNB, 'C0 nB value is incorrect');
      });
    });
  });

  describe('GIVEN a user mints all Docs and they are all available to redeem AND there are 1 day til next settlement', function() {
    beforeEach(async function() {
      await mocHelper.mintBPro(owner, 10, vendorAccount);
      await mocHelper.mintDoc(userAccount, 10000, vendorAccount);
      await this.mocState.setDaysToSettlement(toContractBN(1, 'DAY'));
    });

    describe('AND another user buys 0.5 BTCx', function() {
      beforeEach(async function() {
        await mocHelper.mintBProxAmount(userAccount2, BUCKET_X2, '0.5', vendorAccount);
      });

      it('THEN the interest rate for redeem the full redemption is 0.00005223157521356', async function() {
        const inrate = await this.mocInrate.docInrateAvg(toContractBN(10000, 'USD'));

        mocHelper.assertBigRate(inrate, '0.00005223157521356', 'Interest rate is incorrect');
      });

      describe('WHEN the user redeems all freeDocs', function() {
        let redeemTx;

        beforeEach(async function() {
          redeemTx = await mocHelper.redeemFreeDoc({
            userAccount,
            docAmount: 10000,
            vendorAccount
          });
        });

        it('THEN the RBTC interests are 0.00005223157521356 RBTC', function() {
          const [freeDocRedeemEvent] = mocHelper.findEvents(redeemTx, 'FreeStableTokenRedeem');
          mocHelper.assertBigRBTC(
            freeDocRedeemEvent.interests,
            '0.00005223157521356',
            'Interests are incorrect'
          );
        });
        it('AND recovered RBTC is 0.99994776842478644 RBTC', function() {
          const [freeDocRedeemEvent] = mocHelper.findEvents(redeemTx, 'FreeStableTokenRedeem');

          mocHelper.assertBigRBTC(
            freeDocRedeemEvent.reserveTotal,
            '0.99994776842478644',
            'Interests are incorrect'
          );
        });
      });
    });
  });
});
