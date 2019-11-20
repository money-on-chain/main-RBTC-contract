const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let userAccount;
let BUCKET_X2;

contract('MoC', function([owner]) {
  before(async function() {
    userAccount = owner;
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    ({ BUCKET_X2 } = mocHelper);
  });

  describe('GIVEN the user have 100 BPro and 100000 DOCs', function() {
    before(async function() {
      await this.mocState.setDaysToSettlement(0);
      await mocHelper.mintBProAmount(userAccount, 100);
      await mocHelper.mintDocAmount(userAccount, 1000000);
    });

    describe('WHEN a user mints BProx in sequence', function() {
      [1, 10, 5].forEach(function(nB) {
        it('THEN maxBProx in BTC should drop in every mint', async function() {
          const btcTotal = mocHelper.toContractBN(nB, 'BTC');
          // Max at the start
          const lastBtcMax = await this.mocState.maxBProxBtcValue(BUCKET_X2);
          // First minting
          await this.moc.mintBProx(BUCKET_X2, btcTotal, {
            from: userAccount,
            value: btcTotal
          });

          const newBtcMax = await this.mocState.maxBProxBtcValue(BUCKET_X2);

          mocHelper.assertBig(newBtcMax, lastBtcMax.sub(btcTotal), 'Max BProx does not dropped');
        });
      });
    });
  });
});
