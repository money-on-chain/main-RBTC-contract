const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let btcPrice;
let toContractBN;
let BUCKET_X2;
let BUCKET_C0;

contract('MoC : MoCExchange', function([owner, userAccount, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_C0, BUCKET_X2 } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocInrate = mocHelper.mocInrate;
    btcPrice = await mocHelper.getBitcoinPrice();
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('BProx minting', function() {
    const scenarios = [
      {
        params: {
          nBProx: 5
        },
        expect: {
          nBProx: '5',
          nBtc: '5',
          nDoCs: '40000',
          interest: {
            nBtc: '0.000652894690169500'
          }
        }
      },
      {
        params: {
          nBProx: 10
        },
        expect: {
          nBProx: '10',
          nBtc: '10',
          nDoCs: '80000',
          interest: {
            nBtc: '0.002611578760678'
          }
        }
      },
      {
        params: {
          nBProx: 15
        },
        expect: {
          nBProx: '10',
          nBtc: '10',
          nDoCs: '80000',
          interest: {
            nBtc: '0.002611578760678'
          }
        }
      }
    ];

    let c0InitialState;
    let x2InitialState;
    let globalInitialState;

    describe('GIVEN the user have 18 BPro and 8000 DOCs and Bitcoin price falls to 8000 and days to settlement is 2', function() {
      beforeEach(async function() {
        await this.mocState.setDaysToSettlement(toContractBN(2, 'DAY'));
        await mocHelper.mintBProAmount(userAccount, 18, vendorAccount);
        await mocHelper.mintDocAmount(userAccount, 80000, vendorAccount);
        // Move price to change BProx price and make it different
        // from BPro price
        btcPrice = toContractBN(8000 * mocHelper.MOC_PRECISION);
        await mocHelper.setBitcoinPrice(btcPrice);

        // [RES] / [RES]
        globalInitialState = await mocHelper.getGlobalState();
        c0InitialState = await mocHelper.getBucketState(BUCKET_C0);
        x2InitialState = await mocHelper.getBucketState(BUCKET_X2);
      });
      it('THEN there is 5 RBTC in BProx available to mint', async function() {
        const bproBTCMax = await this.mocState.maxBProxBtcValue(BUCKET_X2);

        mocHelper.assertBigRBTC(bproBTCMax, 10, 'The amount of BProx available is incorrect');
      });
      it('AND the BProx price in RBTC should be 1 RBTC', async function() {
        const bprox2BtcPrice = await this.mocState.bucketBProTecPrice(BUCKET_X2);

        mocHelper.assertBigRBTC(bprox2BtcPrice, 1, 'BProx BTC price is incorrect');
      });
      it('AND the BProx price in BPro should be 1.125', async function() {
        const bproxBProPrice = await this.mocState.bproxBProPrice(BUCKET_X2);

        mocHelper.assertBigRBTC(bproxBProPrice, 1.125, 'BProx BPro price is incorrect', {
          significantDigits: 16
        });
      });

      scenarios.forEach(async s => {
        describe(`WHEN a user sends BTC to mint ${s.params.nBProx} Bprox`, function() {
          let txCost;
          let initialBalance;
          beforeEach(async function() {
            x2InitialState = await mocHelper.getBucketState(BUCKET_X2);

            initialBalance = toContractBN(await web3.eth.getBalance(owner));

            const tx = await mocHelper.mintBProxAmount(
              owner,
              BUCKET_X2,
              s.params.nBProx,
              vendorAccount
            );
            txCost = toContractBN(await mocHelper.getTxCost(tx));
          });
          it(`THEN he receives ${s.expect.nBProx} Bprox`, async function() {
            const balance = await mocHelper.getBProxBalance(BUCKET_X2, owner);
            mocHelper.assertBigRBTC(balance, s.expect.nBProx, 'Bprox balance is incorrect');
          });
          it('AND the C0 coverage increases', async function() {
            const { coverage } = await mocHelper.getBucketState(BUCKET_C0);
            const diff = coverage.sub(toContractBN(c0InitialState.coverage));
            assert(diff > 0, 'C0 coverage does not increase');
          });
          it('AND the C0 Docs decreases by the amount transferred', async function() {
            const { nDoc } = await mocHelper.getBucketState(BUCKET_C0);
            const diff = c0InitialState.nDoc.sub(nDoc);
            mocHelper.assertBigDollar(
              diff,
              s.expect.nDoCs,
              `Doc amount does not decrease by ${s.expect.nDoCs}`
            );
          });
          it('AND the X2 Docs increases', async function() {
            const { nDoc } = await mocHelper.getBucketState(BUCKET_X2);
            const diff = nDoc.sub(x2InitialState.nDoc);
            mocHelper.assertBigDollar(diff, s.expect.nDoCs, 'X2 Doc amount does not increase');
          });
          it('AND the X2 coverage maintains in Cobj', async function() {
            const { coverage } = await mocHelper.getBucketState(BUCKET_X2);
            const diff = coverage.sub(x2InitialState.coverage);

            mocHelper.assertBig(diff, 0, 'X2 coverage changed');
          });
          it('AND the Global coverage should not change', async function() {
            const coverage = await this.mocState.globalCoverage();

            const diff = coverage.sub(globalInitialState.coverage);

            mocHelper.assertBig(diff, 0, 'Global coverage changed');
          });
          it('AND he only spent the sale amount', async function() {
            const balance = toContractBN(await web3.eth.getBalance(owner));
            const diff = initialBalance.sub(balance).sub(txCost);
            const expected = toContractBN(s.expect.nBtc, 'BTC').add(
              toContractBN(s.expect.interest.nBtc, 'BTC')
            );
            mocHelper.assertBig(diff, expected, 'The cost of the minting is not correct');
          });
          it('AND the inRateBag increase', async function() {
            const finalInrateBag = (await mocHelper.getBucketState(BUCKET_C0)).inrateBag;
            const diff = finalInrateBag.sub(c0InitialState.inrateBag);
            mocHelper.assertBigDollar(diff, s.expect.interest.nBtc, 'inrateBag does not increase');
          });
        });
      });
    });
  });
});
