const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;

contract('MoC : MoCExchange', function([owner, userAccount, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocInrate = mocHelper.mocInrate;
    ({ BUCKET_X2 } = mocHelper);
  });

  describe('BProx interest recovery', function() {
    [1, 4, 7].forEach(days => {
      let mintEvent;
      let originalInrate;

      describe(`GIVEN a user mints 5 BProx AND there are ${days} days til next settlement`, function() {
        before(async function() {
          await mocHelper.revertState();

          // Register vendor for test
          await mocHelper.registerVendor(vendorAccount, 0, owner);

          await this.mocState.setDaysToSettlement(toContractBN(days, 'DAY'));
          await mocHelper.mintBPro(userAccount, 18, vendorAccount);
          await mocHelper.mintDoc(userAccount, 80000, vendorAccount);

          originalInrate = await this.mocInrate.btcxInrateAvg(
            BUCKET_X2,
            toContractBN(5, 'BTC'),
            true
          );

          const mintTx = await mocHelper.mintBProx(userAccount, BUCKET_X2, 5, vendorAccount);
          [mintEvent] = mocHelper.findEvents(mintTx, 'RiskProxMint');
        });
        it('THEN the interest taken includes all days to settlement', function() {
          const expected = originalInrate
            .mul(toContractBN(mintEvent.reserveTotal))
            .mul(toContractBN(days))
            .div(mocHelper.MOC_PRECISION);
          mocHelper.assertBig(mintEvent.interests, expected, 'Incorrect Inrate ');
        });

        describe('WHEN he redeems all his BProx', function() {
          let redeemInrate;
          let redeemEvent;
          before(async function() {
            redeemInrate = await this.mocInrate.btcxInrateAvg(
              BUCKET_X2,
              mintEvent.reserveTotal,
              false
            );
            const redeemTx = await mocHelper.redeemBProx(userAccount, BUCKET_X2, 5, vendorAccount);

            [redeemEvent] = mocHelper.findEvents(redeemTx, 'RiskProxRedeem');
          });
          it('THEN user recovers 1 day less of interest', function() {
            const expected = 0;
            mocHelper.assertBig(expected, redeemEvent.interests, 'Incorrect interests');
          });
        });
      });
    });
  });
});
