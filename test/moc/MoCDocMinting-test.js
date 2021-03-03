const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
const { BN } = web3.utils;
let BUCKET_C0;
contract('MoC', function([owner, userAccount, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_C0 } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocConnector = mocHelper.mocConnector;
  });

  describe('Doc minting', function() {
    beforeEach(async function() {
      await mocHelper.revertState();

      // Register vendor for test
      await mocHelper.registerVendor(vendorAccount, 0, owner);
    });
    describe('GIVEN the coverage is below Cobj', function() {
      beforeEach(async function() {
        await mocHelper.mintBProAmount(userAccount, 1, vendorAccount);
        await mocHelper.mintDocAmount(userAccount, 50000, vendorAccount);
        await mocHelper.setBitcoinPrice(8000 * mocHelper.MOC_PRECISION);
      });
      describe('WHEN he tries to buy 1 DOC', function() {
        it('THEN reverts for having the Coverage below Cobj', async function() {
          const coverage = await this.mocState.globalCoverage();
          const cobj = toContractBN(3 * mocHelper.MOC_PRECISION);
          assert(coverage.lt(cobj), 'Coverage is not below Cobj');

          const promise = mocHelper.mintDocAmount(userAccount, 1, vendorAccount);

          await expectRevert.unspecified(promise);
        });
      });
    });

    describe('GIVEN the max DOC available is 5000', function() {
      beforeEach(async function() {
        await mocHelper.mintBPro(userAccount, 1, vendorAccount);
      });
      describe('WHEN a user tries to mint 10000 Docs', function() {
        let prevBtcBalance;
        let txCost;
        beforeEach(async function() {
          prevBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const tx = await mocHelper.mintDocAmount(userAccount, 10000, vendorAccount);

          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });
        it('THEN he only receives 5000 DOCs', async function() {
          const docBalance = await mocHelper.getDoCBalance(userAccount);
          mocHelper.assertBigDollar(docBalance, 5000, 'Doc Balance is not 5000');
        });
        it('AND only spent 0.5 BTC + fee', async function() {
          const btcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevBtcBalance.sub(toContractBN(btcBalance)).sub(new BN(txCost));
          mocHelper.assertBig(diff, '500000000000000000', 'Balance does not decrease by 0.5 RBTC');
        });
      });
    });

    describe('GIVEN BTC price is 10000', function() {
      let payAmount;
      const btcPrice = 10000;
      [0, 10000].forEach(nDocs => {
        describe(`AND There are ${nDocs} Docs and 6 BTC`, function() {
          [1300, 1200].forEach(docAmount => {
            describe(`WHEN he tries to mint ${docAmount} RBTC`, function() {
              const prev = {};
              let txCost;
              beforeEach(async function() {
                // Load Btc on the contract to increase coverage
                await this.moc.sendTransaction({
                  value: 6 * mocHelper.RESERVE_PRECISION
                });

                if (nDocs) {
                  await mocHelper.mintDocAmount(owner, nDocs, vendorAccount);
                }
                [
                  prev.userBalance,
                  prev.mocBalance,
                  prev.c0DocBalance,
                  prev.c0BTCBalance
                ] = await Promise.all([
                  web3.eth.getBalance(userAccount),
                  web3.eth.getBalance(this.moc.address),
                  this.mocState.getBucketNDoc(BUCKET_C0),
                  this.mocState.getBucketNBTC(BUCKET_C0)
                ]);

                const tx = await mocHelper.mintDocAmount(userAccount, docAmount, vendorAccount);
                payAmount = new BN(docAmount).mul(mocHelper.MOC_PRECISION).div(new BN(btcPrice));

                txCost = await mocHelper.getTxCost(tx);
              });

              // Docs received should be the dollar value of the total BTC sent
              it(`THEN he receives ${docAmount} Docs on his account`, async function() {
                const balance = await mocHelper.getDoCBalance(userAccount);

                mocHelper.assertBigDollar(
                  balance,
                  docAmount,
                  `${docAmount} was not in the first account`
                );
              });

              it('THEN global balance increases by the correct amount of BTCs', async function() {
                const mocBtcBalance = await web3.eth.getBalance(this.moc.address);
                const diff = new BN(mocBtcBalance).sub(new BN(prev.mocBalance));

                mocHelper.assertBig(diff, payAmount, 'Should increase sale total amount');
              });

              it('AND C0 Bucket BTC balance increases by the correct amount of RBTCs', async function() {
                const c0BTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
                const diff = c0BTCBalance.sub(prev.c0BTCBalance);

                mocHelper.assertBig(
                  diff,
                  payAmount,
                  `C0 BTC balance should rise  ${payAmount} BTC`
                );
              });

              it(`AND C0 Bucket Doc balance increases by  ${docAmount} Doc`, async function() {
                const c0DocBalance = await this.mocState.getBucketNDoc(BUCKET_C0);
                const diff = c0DocBalance.sub(prev.c0DocBalance);

                mocHelper.assertBigDollar(
                  diff,
                  docAmount,
                  `C0 Doc balance should rise  ${docAmount} Doc`
                );
              });

              it('AND User Balance decreases by the correct amount of  BTCs (and fees)', async function() {
                const userBalance = await web3.eth.getBalance(userAccount);
                const diff = new BN(prev.userBalance).sub(new BN(userBalance)).sub(new BN(txCost));

                mocHelper.assertBig(
                  diff,
                  payAmount,
                  `Should decrease by Tokens cost, ${payAmount} BTC`
                );
              });
            });
          });
        });
      });
    });
  });
});
